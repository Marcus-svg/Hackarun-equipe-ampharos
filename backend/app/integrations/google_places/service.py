"""Serviço Google Places: coleta, cache temporário com expiração e análises agregadas."""
from __future__ import annotations

import logging
import statistics
from datetime import datetime, timedelta, timezone

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.http import ExternalSourceError
from app.core.taxonomy import PLACE_CATEGORIES, DataStatus, ValidationStatus, normalize_text
from app.integrations.google_places.client import GooglePlacesClient
from app.integrations.google_places.review_analysis import analyze_reviews
from app.models import ExternalObservation, PlaceLocation, PlaceObservation, utcnow
from app.repositories.sources import finish_run, get_source, new_observation, start_run

log = logging.getLogger(__name__)

ANCHOR_QUERY = "Capim Dourado Shopping Palmas Tocantins"
ANCHOR_NAME_KEY = "capim dourado"
CITY_SUFFIX = "em Palmas, Tocantins"
ATTRIBUTION = "Dados fornecidos por Google Maps Platform (Places API)."


def _aware(dt: datetime | None) -> datetime | None:
    if dt is None:
        return None
    return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)


def _valid_coords(lat, lng) -> bool:
    return lat is not None and lng is not None and -90 <= lat <= 90 and -180 <= lng <= 180


class PlacesService:
    def __init__(self, db: Session, client: GooglePlacesClient | None = None):
        self.db = db
        self.client = client or GooglePlacesClient()
        self.settings = get_settings()

    # ------------------------------------------------------------------ coleta
    def _upsert_location(self, place: dict, category: str, query: str, is_anchor: bool = False) -> PlaceLocation:
        pid = place["id"]
        loc = self.db.scalar(select(PlaceLocation).where(PlaceLocation.google_place_id == pid))
        if loc is None:
            loc = PlaceLocation(google_place_id=pid, category=category, query_used=query, is_anchor=is_anchor)
            self.db.add(loc)
        if is_anchor:
            loc.is_anchor = True
            loc.category = "shopping"
        now = utcnow()
        loc.last_refreshed_at = now
        coords = place.get("location") or {}
        lat, lng = coords.get("latitude"), coords.get("longitude")
        if _valid_coords(lat, lng):
            loc.latitude, loc.longitude = lat, lng
            loc.coordinates_expires_at = now + timedelta(days=self.settings.places_coordinates_cache_days)
        self.db.flush()
        return loc

    def _snapshot(self, loc: PlaceLocation, place: dict, run, source, reviews_analysis: dict | None = None) -> PlaceObservation:
        now = utcnow()
        expires = now + timedelta(hours=self.settings.places_content_cache_hours)
        rating = place.get("rating")
        count = place.get("userRatingCount")
        name = (place.get("displayName") or {}).get("text")
        missing = [f for f, v in (("rating", rating), ("userRatingCount", count), ("displayName", name)) if v is None]
        obs = new_observation(
            self.db,
            source=source,
            run=run,
            observation_type="place_snapshot",
            collection_method="official_api",
            data_status=DataStatus.REAL,
            validation_status=ValidationStatus.INCOMPLETE if missing else ValidationStatus.VALID,
            theme=PLACE_CATEGORIES.get(loc.category, {}).get("theme"),
            category=loc.category,
            locality="Palmas-TO",
            value_numeric=rating,
            source_url=place.get("googleMapsUri"),
            quality_score=0.9 if not missing else 0.6,
            quality_notes=f"campos ausentes: {missing}" if missing else None,
            expires_at=expires,
        )
        snap = PlaceObservation(
            observation_id=obs.id,
            place_location_id=loc.id,
            name=name,
            address=place.get("formattedAddress"),
            primary_type=place.get("primaryType"),
            rating=rating,
            user_rating_count=count,
            google_maps_uri=place.get("googleMapsUri"),
            review_sample_size=(reviews_analysis or {}).get("sample_size", 0),
            review_themes=(reviews_analysis or {}).get("themes"),
            sentiment_counts=(reviews_analysis or {}).get("sentiment_counts"),
            collected_at=now,
            expires_at=expires,
        )
        self.db.add(snap)
        self.db.flush()
        return snap

    def refresh_category(self, category: str, max_results: int = 20) -> dict:
        if category not in PLACE_CATEGORIES:
            raise ValueError(f"Categoria inválida: {category}")
        source = get_source(self.db, "google_places")
        run = start_run(self.db, source)
        query = f"{PLACE_CATEGORIES[category]['query']} {CITY_SUFFIX}"
        try:
            data = self.client.search_text(query, page_size=max_results)
        except Exception as exc:  # isolamento de falha por fonte
            finish_run(self.db, run, received=0, saved=0, rejected=0, message=str(exc), failed=True)
            raise
        places = data.get("places", [])
        saved = 0
        for p in places:
            if not p.get("id"):
                continue
            is_anchor = ANCHOR_NAME_KEY in normalize_text((p.get("displayName") or {}).get("text", ""))
            loc = self._upsert_location(p, category, query, is_anchor=is_anchor)
            self._snapshot(loc, p, run, source)
            saved += 1
        finish_run(self.db, run, received=len(places), saved=saved, rejected=len(places) - saved)
        return {"category": category, "query": query, "received": len(places), "saved": saved, "run_id": run.id}

    def refresh_anchor(self) -> dict:
        """Localiza o Capim Dourado Shopping e coleta detalhes + amostra de avaliações."""
        source = get_source(self.db, "google_places")
        run = start_run(self.db, source)
        try:
            data = self.client.search_text(ANCHOR_QUERY, page_size=5)
            candidates = [
                p for p in data.get("places", []) if ANCHOR_NAME_KEY in normalize_text((p.get("displayName") or {}).get("text", ""))
            ]
            if not candidates:
                finish_run(self.db, run, received=len(data.get("places", [])), saved=0, rejected=0,
                           message="Capim Dourado Shopping não encontrado na busca", failed=True)
                return {"found": False}
            details = self.client.place_details(candidates[0]["id"], include_reviews=True)
        except Exception as exc:
            finish_run(self.db, run, received=0, saved=0, rejected=0, message=str(exc), failed=True)
            raise
        analysis = analyze_reviews(details.get("reviews", []))
        loc = self._upsert_location(details, "shopping", ANCHOR_QUERY, is_anchor=True)
        snap = self._snapshot(loc, details, run, source, reviews_analysis=analysis)
        finish_run(self.db, run, received=1, saved=1, rejected=0)
        return {"found": True, "place_id": loc.google_place_id, "snapshot_id": snap.id, "review_sample": analysis["sample_size"]}

    def refresh_all(self, max_results: int = 20) -> dict:
        """Atualiza âncora e categorias; falha de uma categoria não interrompe as demais."""
        results: dict[str, dict] = {}
        for key, fn in [("anchor", self.refresh_anchor)] + [
            (c, (lambda c=c: self.refresh_category(c, max_results))) for c in PLACE_CATEGORIES
        ]:
            try:
                results[key] = fn()
            except (ExternalSourceError, Exception) as exc:  # noqa: BLE001
                log.error("Places: falha em %s: %s", key, exc)
                results[key] = {"error": str(exc)}
        return results

    # -------------------------------------------------------------- retenção
    def purge_expired(self) -> dict:
        now = utcnow()
        expired_ids = self.db.scalars(select(PlaceObservation.observation_id).where(PlaceObservation.expires_at < now)).all()
        if expired_ids:
            self.db.execute(delete(PlaceObservation).where(PlaceObservation.observation_id.in_(expired_ids)))
            self.db.execute(delete(ExternalObservation).where(ExternalObservation.id.in_(expired_ids)))
        coords = 0
        for loc in self.db.scalars(select(PlaceLocation).where(PlaceLocation.coordinates_expires_at < now)).all():
            loc.latitude = loc.longitude = loc.coordinates_expires_at = None
            coords += 1
        self.db.commit()
        return {"snapshots_removed": len(expired_ids), "coordinates_cleared": coords}

    # -------------------------------------------------------------- consultas
    def _latest_valid_snapshots(self, category: str | None = None) -> list[PlaceObservation]:
        now = utcnow()
        q = select(PlaceObservation).join(PlaceLocation).where(PlaceObservation.expires_at >= now)
        if category:
            q = q.where(PlaceLocation.category == category)
        latest: dict[int, PlaceObservation] = {}
        for s in self.db.scalars(q.order_by(PlaceObservation.collected_at)).all():
            latest[s.place_location_id] = s
        return list(latest.values())

    def list_places(self, category: str | None = None, limit: int = 50, offset: int = 0) -> dict:
        snaps = sorted(self._latest_valid_snapshots(category), key=lambda s: (not s.location.is_anchor, -(s.user_rating_count or 0)))
        items = [self._serialize(s) for s in snaps[offset : offset + limit]]
        return {"total": len(snaps), "items": items, "attribution": ATTRIBUTION}

    def _serialize(self, s: PlaceObservation) -> dict:
        loc = s.location
        coords_ok = loc.coordinates_expires_at and _aware(loc.coordinates_expires_at) >= utcnow()
        return {
            "place_id": loc.google_place_id,
            "name": s.name,
            "address": s.address,
            "category": loc.category,
            "category_label": PLACE_CATEGORIES.get(loc.category, {}).get("label", loc.category),
            "is_anchor": loc.is_anchor,
            "primary_type": s.primary_type,
            "rating": s.rating,
            "user_rating_count": s.user_rating_count,
            "latitude": loc.latitude if coords_ok else None,
            "longitude": loc.longitude if coords_ok else None,
            "google_maps_uri": s.google_maps_uri,
            "collected_at": s.collected_at,
            "expires_at": s.expires_at,
            "data_status": s.observation.data_status,
            "validation_status": s.observation.validation_status,
            "source": "Google Places API (New)",
        }

    def categories_summary(self) -> list[dict]:
        snaps = self._latest_valid_snapshots()
        by_cat: dict[str, list[PlaceObservation]] = {}
        for s in snaps:
            by_cat.setdefault(s.location.category, []).append(s)
        out = []
        for cat, meta in PLACE_CATEGORIES.items():
            items = by_cat.get(cat, [])
            rated = [s for s in items if s.rating is not None]
            total_reviews = sum(s.user_rating_count or 0 for s in rated)
            weighted = (
                round(sum(s.rating * (s.user_rating_count or 0) for s in rated) / total_reviews, 2) if total_reviews else None
            )
            out.append(
                {
                    "category": cat,
                    "label": meta["label"],
                    "theme": meta["theme"],
                    "places": len(items),
                    "places_with_rating": len(rated),
                    "mean_rating": round(statistics.fmean([s.rating for s in rated]), 2) if rated else None,
                    "weighted_mean_rating": weighted,
                    "total_user_ratings": total_reviews,
                    "data_status": DataStatus.REAL if items else DataStatus.UNAVAILABLE,
                }
            )
        return out

    def insights(self, include_live_reviews: bool = False) -> dict:
        snaps = self._latest_valid_snapshots()
        anchor = next((s for s in snaps if s.location.is_anchor), None)
        summary = self.categories_summary()
        theme_totals: dict[str, dict[str, int]] = {}
        sample_total = 0
        for s in snaps:
            sample_total += s.review_sample_size or 0
            for theme, counts in (s.review_themes or {}).items():
                agg = theme_totals.setdefault(theme, {"positiva": 0, "neutra": 0, "negativa": 0, "total": 0})
                for k in agg:
                    agg[k] += counts.get(k, 0)
        comparison = []
        if anchor and anchor.rating is not None:
            for c in summary:
                if c["mean_rating"] is not None and c["category"] != "shopping":
                    comparison.append(
                        {
                            "category": c["category"],
                            "label": c["label"],
                            "category_mean_rating": c["mean_rating"],
                            "anchor_rating": anchor.rating,
                            "difference": round(anchor.rating - c["mean_rating"], 2),
                        }
                    )
        result = {
            "anchor": self._serialize(anchor) if anchor else None,
            "anchor_review_analysis": (
                {
                    "sample_size": anchor.review_sample_size,
                    "sentiment_counts": anchor.sentiment_counts,
                    "themes": anchor.review_themes,
                    "sufficient_for_sentiment": (anchor.review_sample_size or 0) >= 3,
                }
                if anchor
                else None
            ),
            "categories": summary,
            "recurring_review_themes": dict(sorted(theme_totals.items(), key=lambda kv: -kv[1]["total"])),
            "review_sample_total": sample_total,
            "anchor_vs_categories": comparison,
            "limitations": [
                "A Places API retorna no máximo 5 avaliações por local, selecionadas por relevância; não representam a opinião geral.",
                "Polaridade derivada da nota em estrelas de cada avaliação; temas por palavras-chave.",
                f"Conteúdo Google mantido em cache temporário por {self.settings.places_content_cache_hours}h; apenas place_id é permanente.",
                "Notas médias são comparáveis apenas como contexto; categorias têm públicos e propósitos diferentes.",
            ],
            "attribution": ATTRIBUTION,
            "data_status": DataStatus.REAL if snaps else DataStatus.UNAVAILABLE,
        }
        if include_live_reviews and anchor:
            # Exibição ao vivo com atribuição; o texto NÃO é persistido.
            details = self.client.place_details(anchor.location.google_place_id, include_reviews=True)
            result["live_reviews"] = [
                {
                    "rating": r.get("rating"),
                    "text": (r.get("text") or {}).get("text"),
                    "relative_time": r.get("relativePublishTimeDescription"),
                    "author": (r.get("authorAttribution") or {}).get("displayName"),
                    "author_uri": (r.get("authorAttribution") or {}).get("uri"),
                    "google_maps_uri": r.get("googleMapsUri"),
                }
                for r in details.get("reviews", [])
            ]
        return result
