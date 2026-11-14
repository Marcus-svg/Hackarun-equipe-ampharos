"""Serviço Google Trends: importação persistida + análises (tendência, comparação, histórico).

Regras de análise:
- Índices do Trends são relativos (0-100) e reescalados a cada consulta. Comparações
  numéricas entre termos/períodos só são feitas DENTRO da mesma série (``series_key``).
- Nunca convertemos índice em número de pessoas/buscas.
- A geografia é sempre informada; indicadores nacionais são rotulados como contexto.
"""
from __future__ import annotations

import hashlib
import logging
import statistics
from dataclasses import dataclass
from datetime import date, datetime, time, timedelta, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.taxonomy import TREND_GEOS, TREND_GROUPS, THEMES, DataStatus, ValidationStatus, lookup_trend_term
from app.integrations.google_trends.client import TrendsCsvError, parse_trends_csv
from app.models import ExternalObservation, TrendObservation, utcnow
from app.repositories.sources import finish_run, get_source, new_observation, start_run

log = logging.getLogger(__name__)

RISING_PCT = 10.0
FALLING_PCT = -10.0
DEFAULT_WINDOW_DAYS = 90


@dataclass
class ImportResult:
    series_key: str
    run_id: int
    terms: list[str]
    unknown_terms: list[str]
    points_saved: int
    points_skipped: int
    granularity: str
    geo: str
    already_imported: bool = False


def import_trends_csv(
    db: Session,
    content: bytes,
    *,
    geo: str,
    source_url: str | None = None,
    timeframe_label: str | None = None,
) -> ImportResult:
    geo = geo.upper().strip()
    if geo not in TREND_GEOS:
        raise TrendsCsvError(f"Geografia '{geo}' não suportada. Use uma de: {', '.join(TREND_GEOS)}")
    geo_info = TREND_GEOS[geo]
    source = get_source(db, "google_trends_csv")
    run = start_run(db, source)
    try:
        parsed = parse_trends_csv(content)
    except TrendsCsvError as exc:
        finish_run(db, run, received=0, saved=0, rejected=0, message=str(exc), failed=True)
        raise

    series_key = "csv:" + hashlib.sha1(content + geo.encode()).hexdigest()[:16]
    exists = db.scalar(select(func.count()).select_from(TrendObservation).where(TrendObservation.series_key == series_key))
    if exists:
        finish_run(db, run, received=len(parsed.points), saved=0, rejected=0, message="Exportação já importada")
        return ImportResult(series_key, run.id, parsed.terms, [], 0, 0, parsed.granularity, geo, already_imported=True)

    unknown: list[str] = []
    saved = 0
    limitation = geo_info["limitation"] + " Índice relativo (0-100), não é volume absoluto de buscas."
    span = {"day": 1, "week": 7, "month": 30}.get(parsed.granularity, 1)
    for term in parsed.terms:
        if lookup_trend_term(term) is None:
            unknown.append(term)
    for p in parsed.points:
        info = lookup_trend_term(p.term)
        canonical, group, theme = info if info else (p.term, None, None)
        start = datetime.combine(p.period_date, time.min, tzinfo=timezone.utc)
        notes = []
        if p.below_one:
            notes.append("valor '<1' registrado como 0")
        if info is None:
            notes.append("termo fora do catálogo monitorado (sem tema)")
        obs = new_observation(
            db,
            source=source,
            run=run,
            observation_type="trend_point",
            collection_method="official_export_csv",
            data_status=DataStatus.MANUAL_IMPORT,
            validation_status=ValidationStatus.VALID if info else ValidationStatus.INCOMPLETE,
            theme=theme,
            category=group,
            locality=geo,
            reference_start=start,
            reference_end=start + timedelta(days=span),
            value_numeric=p.value,
            value_text=p.raw,
            source_url=source_url or source.base_url,
            quality_score=0.8 if info else 0.5,
            quality_notes="; ".join(notes) or None,
        )
        db.add(
            TrendObservation(
                observation_id=obs.id,
                series_key=series_key,
                term=canonical,
                term_group=group,
                theme=theme,
                geo=geo,
                geo_level=geo_info["level"],
                period_date=p.period_date,
                granularity=parsed.granularity,
                interest_index=p.value,
                raw_value=p.raw,
                below_one=p.below_one,
                limitations=limitation + (f" Período: {timeframe_label}." if timeframe_label else ""),
            )
        )
        saved += 1
    finish_run(
        db,
        run,
        received=len(parsed.points) + parsed.skipped_cells,
        saved=saved,
        rejected=parsed.skipped_cells,
        message=f"Termos fora do catálogo: {unknown}" if unknown else None,
    )
    log.info("Trends: série %s importada (%s pontos, geo=%s)", series_key, saved, geo)
    return ImportResult(series_key, run.id, parsed.terms, unknown, saved, parsed.skipped_cells, parsed.granularity, geo)


# ---------------------------------------------------------------------------
# Análises
# ---------------------------------------------------------------------------


def _latest_series_for_terms(db: Session, geo: str) -> dict[str, str]:
    """Para cada termo, a série mais recentemente coletada naquela geografia."""
    rows = db.execute(
        select(TrendObservation.term, TrendObservation.series_key, func.max(ExternalObservation.collected_at))
        .join(ExternalObservation, ExternalObservation.id == TrendObservation.observation_id)
        .where(TrendObservation.geo == geo)
        .group_by(TrendObservation.term, TrendObservation.series_key)
    ).all()
    best: dict[str, tuple[str, datetime]] = {}
    for term, series_key, collected in rows:
        if term not in best or collected > best[term][1]:
            best[term] = (series_key, collected)
    return {t: v[0] for t, v in best.items()}


def _mean(values: list[float]) -> float | None:
    return round(statistics.fmean(values), 2) if values else None


def term_momentum(points: list[tuple[date, float]], window_days: int = DEFAULT_WINDOW_DAYS) -> dict:
    """Compara a média da janela recente com a janela anterior (mesma série)."""
    if not points:
        return {"status": "sem_dados"}
    points = sorted(points)
    last = points[-1][0]
    recent_start = last - timedelta(days=window_days)
    prev_start = recent_start - timedelta(days=window_days)
    recent = [v for d, v in points if d > recent_start]
    prev = [v for d, v in points if prev_start < d <= recent_start]
    yoy_start, yoy_end = recent_start - timedelta(days=365), last - timedelta(days=365)
    yoy = [v for d, v in points if yoy_start < d <= yoy_end]

    r_mean, p_mean, y_mean = _mean(recent), _mean(prev), _mean(yoy)
    pct = None
    direction = "indefinido"
    if r_mean is not None and p_mean is not None:
        if p_mean > 0:
            pct = round((r_mean - p_mean) / p_mean * 100, 1)
            direction = "alta" if pct >= RISING_PCT else "queda" if pct <= FALLING_PCT else "estavel"
        elif r_mean > 0:
            direction = "alta"
        else:
            direction = "sem_interesse"
    yoy_pct = round((r_mean - y_mean) / y_mean * 100, 1) if (r_mean is not None and y_mean) else None
    return {
        "status": "ok" if pct is not None or direction != "indefinido" else "dados_insuficientes",
        "window_days": window_days,
        "reference_end": last.isoformat(),
        "recent_mean": r_mean,
        "previous_mean": p_mean,
        "change_pct": pct,
        "change_points": round(r_mean - p_mean, 2) if r_mean is not None and p_mean is not None else None,
        "direction": direction,
        "yoy_mean": y_mean,
        "yoy_change_pct": yoy_pct,
        "recent_points": len(recent),
        "previous_points": len(prev),
    }


def _series_points(db: Session, series_key: str, term: str) -> list[tuple[date, float]]:
    rows = db.execute(
        select(TrendObservation.period_date, TrendObservation.interest_index).where(
            TrendObservation.series_key == series_key, TrendObservation.term == term
        )
    ).all()
    return [(d, v) for d, v in rows]


def list_terms(
    db: Session, geo: str = "BR-TO", group: str | None = None, theme: str | None = None, window_days: int = DEFAULT_WINDOW_DAYS
) -> list[dict]:
    settings = get_settings()
    latest = _latest_series_for_terms(db, geo)
    out = []
    for term, series_key in latest.items():
        sample = db.scalars(
            select(TrendObservation).where(TrendObservation.series_key == series_key, TrendObservation.term == term).limit(1)
        ).first()
        if sample is None:
            continue
        if group and sample.term_group != group:
            continue
        if theme and sample.theme != theme:
            continue
        obs = sample.observation
        stale = obs.collected_at.replace(tzinfo=obs.collected_at.tzinfo or timezone.utc) < utcnow() - timedelta(
            days=settings.stale_after_days_trends
        )
        out.append(
            {
                "term": term,
                "group": sample.term_group,
                "theme": sample.theme,
                "geo": geo,
                "geo_level": sample.geo_level,
                "granularity": sample.granularity,
                "series_key": series_key,
                "momentum": term_momentum(_series_points(db, series_key, term), window_days),
                "source": obs.source.name,
                "source_url": obs.source_url,
                "collection_method": obs.collection_method,
                "data_status": obs.data_status,
                "validation_status": ValidationStatus.STALE if stale else obs.validation_status,
                "collected_at": obs.collected_at,
                "limitations": sample.limitations,
            }
        )
    out.sort(key=lambda t: (t["momentum"].get("recent_mean") or 0), reverse=True)
    return out


def categories_summary(db: Session, geo: str = "BR-TO", window_days: int = DEFAULT_WINDOW_DAYS) -> list[dict]:
    """Agrega por grupo (categorias do prompt) e por tema, usando a mediana das variações."""
    terms = list_terms(db, geo=geo, window_days=window_days)
    groups: dict[str, list[dict]] = {}
    for t in terms:
        groups.setdefault(t["group"] or "sem_grupo", []).append(t)
    result = []
    for g, items in groups.items():
        changes = [i["momentum"]["change_pct"] for i in items if i["momentum"].get("change_pct") is not None]
        result.append(
            {
                "group": g,
                "label": TREND_GROUPS.get(g, g),
                "geo": geo,
                "terms": [i["term"] for i in items],
                "terms_rising": sum(1 for i in items if i["momentum"].get("direction") == "alta"),
                "terms_falling": sum(1 for i in items if i["momentum"].get("direction") == "queda"),
                "median_change_pct": round(statistics.median(changes), 1) if changes else None,
                "comparable_terms": len(changes),
                "note": "Mediana das variações por termo (cada termo comparado dentro da própria série).",
            }
        )
    return result


def theme_signals(db: Session, geo: str = "BR-TO", window_days: int = DEFAULT_WINDOW_DAYS) -> dict[str, dict]:
    """Sinal de interesse por tema canônico (usado pelo motor de inteligência)."""
    terms = list_terms(db, geo=geo, window_days=window_days)
    by_theme: dict[str, list[dict]] = {}
    for t in terms:
        if t["theme"]:
            by_theme.setdefault(t["theme"], []).append(t)
    signals = {}
    for theme, items in by_theme.items():
        changes = [i["momentum"]["change_pct"] for i in items if i["momentum"].get("change_pct") is not None]
        if not changes:
            continue
        median = round(statistics.median(changes), 1)
        signals[theme] = {
            "theme": theme,
            "theme_label": THEMES.get(theme, theme),
            "geo": geo,
            "geo_level": items[0]["geo_level"],
            "median_change_pct": median,
            "direction": "alta" if median >= RISING_PCT else "queda" if median <= FALLING_PCT else "estavel",
            "terms": [
                {
                    "term": i["term"],
                    "change_pct": i["momentum"].get("change_pct"),
                    "series_key": i["series_key"],
                    "reference_end": i["momentum"].get("reference_end"),
                }
                for i in items
            ],
            "stale": any(i["validation_status"] == ValidationStatus.STALE for i in items),
            "limitations": items[0]["limitations"],
            "source_url": items[0]["source_url"],
            "collected_at": max(i["collected_at"] for i in items),
        }
    return signals


def history(
    db: Session,
    term: str,
    geo: str = "BR-TO",
    start: date | None = None,
    end: date | None = None,
    series_key: str | None = None,
) -> dict:
    info = lookup_trend_term(term)
    canonical = info[0] if info else term
    if series_key is None:
        series_key = _latest_series_for_terms(db, geo).get(canonical)
    if series_key is None:
        return {"term": canonical, "geo": geo, "series_key": None, "points": [], "available_series": []}
    q = select(TrendObservation).where(TrendObservation.series_key == series_key, TrendObservation.term == canonical)
    if start:
        q = q.where(TrendObservation.period_date >= start)
    if end:
        q = q.where(TrendObservation.period_date <= end)
    rows = db.scalars(q.order_by(TrendObservation.period_date)).all()
    all_series = db.scalars(
        select(TrendObservation.series_key).where(TrendObservation.term == canonical, TrendObservation.geo == geo).distinct()
    ).all()
    return {
        "term": canonical,
        "geo": geo,
        "series_key": series_key,
        "granularity": rows[0].granularity if rows else None,
        "limitations": rows[0].limitations if rows else None,
        "points": [
            {"date": r.period_date.isoformat(), "interest_index": r.interest_index, "raw": r.raw_value, "below_one": r.below_one}
            for r in rows
        ],
        "available_series": list(all_series),
    }


def compare_periods(
    db: Session, term: str, geo: str, a_start: date, a_end: date, b_start: date, b_end: date
) -> dict:
    """Compara dois períodos dentro da mesma série (mais recente)."""
    h = history(db, term, geo)
    pts = [(date.fromisoformat(p["date"]), p["interest_index"]) for p in h["points"]]
    a = [v for d, v in pts if a_start <= d <= a_end]
    b = [v for d, v in pts if b_start <= d <= b_end]
    ma, mb = _mean(a), _mean(b)
    return {
        "term": h["term"],
        "geo": geo,
        "series_key": h["series_key"],
        "period_a": {"start": a_start, "end": a_end, "mean": ma, "points": len(a)},
        "period_b": {"start": b_start, "end": b_end, "mean": mb, "points": len(b)},
        "change_pct": round((mb - ma) / ma * 100, 1) if ma and mb is not None else None,
        "limitations": h.get("limitations"),
    }
