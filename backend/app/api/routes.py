from __future__ import annotations

import random
from typing import Any

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy import func, select, text
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.database import get_db
from app.core.taxonomy import totem_category_to_theme
from app.integrations.google_places.service import PlacesService
from app.integrations.google_trends.service import (
    categories_summary as trends_categories_summary,
    import_trends_csv,
    list_terms as trends_list_terms,
)
from app.models import (
    ExternalObservation,
    PlaceLocation,
    RegionalEvent,
    TotemFeedback,
    TrendObservation,
)

router = APIRouter(prefix="/api", tags=["hackarun"])


class TotemFeedbackCreate(BaseModel):
    code: str | None = None
    age_group: str
    interest_category: str
    preferred_event_format: str
    general_satisfaction: str
    discount_benefit: str = "10% OFF"


class CouponRedeemRequest(BaseModel):
    store_name: str


def _ensure_totem_columns(db: Session) -> None:
    """Garante compatibilidade caso a tabela totem_feedbacks já exista no hackarun.db sem as colunas de resgate."""
    try:
        cols = [row[1] for row in db.execute(text("PRAGMA table_info(totem_feedbacks)")).fetchall()]
        if "is_redeemed" not in cols:
            db.execute(text("ALTER TABLE totem_feedbacks ADD COLUMN is_redeemed BOOLEAN DEFAULT 0"))
        if "redeemed_store_name" not in cols:
            db.execute(text("ALTER TABLE totem_feedbacks ADD COLUMN redeemed_store_name VARCHAR(120)"))
        db.commit()
    except Exception:
        db.rollback()


@router.get("/health")
def health() -> dict[str, Any]:
    settings = get_settings()
    return {
        "status": "ok",
        "app": "Hackarun Intelligence",
        "environment": settings.app_env,
        "database": settings.database_url,
        "note": "Backend operational. Real API calls require credentials and valid source configuration.",
    }


@router.get("/integrations/status")
def integrations_status() -> dict[str, Any]:
    settings = get_settings()
    return {
        "google_trends": {
            "status": "functional",
            "method": "official_export_csv",
            "documentation": "Google Trends CSV import performed through the official web export; no scraping or private endpoints used.",
            "geo": "BR-TO",
            "requires_credentials": False,
        },
        "google_places": {
            "status": "configured" if settings.google_places_api_key else "pending_credentials",
            "method": "official_places_api",
            "requires_credentials": True,
            "api_key_configured": bool(settings.google_places_api_key),
            "region_bias": {
                "latitude": settings.places_bias_latitude,
                "longitude": settings.places_bias_longitude,
                "radius_m": settings.places_bias_radius_m,
            },
        },
        "regional_events": {
            "status": "manual_or_public_sources",
            "method": "public feeds, manual import, and organizer-authorized APIs when available",
            "requires_credentials": "optional for Sympla organizer token",
            "deduplication": "enabled",
        },
    }


@router.post("/trends/import")
async def import_trends_endpoint(
    file: UploadFile = File(...),
    geo: str = Form("BR-TO"),
    source_url: str | None = Form(default=None),
    timeframe_label: str | None = Form(default=None),
    db: Session = Depends(get_db),
) -> dict[str, Any]:
    if not file.filename or not file.filename.lower().endswith(".csv"):
        raise HTTPException(status_code=400, detail="Arquivo CSV do Google Trends é obrigatório.")

    try:
        content = await file.read()
        result = import_trends_csv(db, content, geo=geo, source_url=source_url, timeframe_label=timeframe_label)
        return {"status": "ok", "result": result.__dict__}
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/trends/summary")
def get_trends_summary(geo: str = "BR-TO", db: Session = Depends(get_db)) -> dict[str, Any]:
    return {
        "status": "ok",
        "geo": geo,
        "categories": trends_categories_summary(db, geo=geo),
        "terms": trends_list_terms(db, geo=geo),
    }


@router.post("/places/refresh")
def refresh_places(category: str | None = None, db: Session = Depends(get_db)) -> dict[str, Any]:
    settings = get_settings()
    if not settings.google_places_api_key:
        raise HTTPException(
            status_code=503,
            detail="GOOGLE_PLACES_API_KEY não configurada; a coleta oficial está indisponível neste ambiente.",
        )

    try:
        service = PlacesService(db)
        if category:
            return service.refresh_category(category)
        return service.refresh_all()
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/places/insights")
def get_places_insights(db: Session = Depends(get_db)) -> dict[str, Any]:
    service = PlacesService(db)
    return {"status": "ok", "insights": service.insights()}


@router.get("/totem/feedbacks")
def list_totem_feedbacks(db: Session = Depends(get_db)) -> dict[str, Any]:
    _ensure_totem_columns(db)
    rows = db.scalars(select(TotemFeedback).order_by(TotemFeedback.created_at.desc())).all()
    return {
        "status": "ok",
        "items": [
            {
                "code": r.coupon_code or f"CD-{r.id:04d}",
                "age_group": r.age_group,
                "interest_category": r.interest_category,
                "preferred_event_format": r.preferred_event_format or "",
                "general_satisfaction": r.general_satisfaction or "Excelentes",
                "discount_benefit": r.discount_benefit or "10% OFF",
                "created_at": r.created_at.isoformat() if r.created_at else None,
                "is_redeemed": bool(r.is_redeemed),
                "redeemed_store_name": r.redeemed_store_name,
            }
            for r in rows
        ],
    }


@router.post("/totem/feedbacks")
def create_totem_feedback(payload: TotemFeedbackCreate, db: Session = Depends(get_db)) -> dict[str, Any]:
    _ensure_totem_columns(db)
    code = (payload.code or f"CD-{random.randint(1000, 9999)}").strip().upper()
    row = TotemFeedback(
        coupon_code=code,
        age_group=payload.age_group,
        interest_category=payload.interest_category,
        theme=totem_category_to_theme(payload.interest_category),
        preferred_event_format=payload.preferred_event_format,
        general_satisfaction=payload.general_satisfaction,
        discount_benefit=payload.discount_benefit,
        is_redeemed=False,
        redeemed_store_name=None,
        data_status="real",
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return {
        "status": "ok",
        "item": {
            "code": row.coupon_code,
            "age_group": row.age_group,
            "interest_category": row.interest_category,
            "preferred_event_format": row.preferred_event_format,
            "general_satisfaction": row.general_satisfaction,
            "discount_benefit": row.discount_benefit,
            "created_at": row.created_at.isoformat() if row.created_at else None,
            "is_redeemed": bool(row.is_redeemed),
            "redeemed_store_name": row.redeemed_store_name,
        },
    }


@router.patch("/totem/feedbacks/{code}/redeem")
def redeem_totem_coupon(code: str, payload: CouponRedeemRequest, db: Session = Depends(get_db)) -> dict[str, Any]:
    _ensure_totem_columns(db)
    normalized = code.strip().upper()
    row = db.scalar(select(TotemFeedback).where(TotemFeedback.coupon_code == normalized))
    if row is None:
        raise HTTPException(
            status_code=404,
            detail=f'Código de cupom "{normalized}" não encontrado no banco de dados.',
        )
    row.is_redeemed = True
    row.redeemed_store_name = payload.store_name
    db.commit()
    db.refresh(row)
    return {
        "status": "ok",
        "item": {
            "code": row.coupon_code,
            "age_group": row.age_group,
            "interest_category": row.interest_category,
            "preferred_event_format": row.preferred_event_format,
            "general_satisfaction": row.general_satisfaction,
            "discount_benefit": row.discount_benefit,
            "created_at": row.created_at.isoformat() if row.created_at else None,
            "is_redeemed": bool(row.is_redeemed),
            "redeemed_store_name": row.redeemed_store_name,
        },
    }


@router.get("/dashboard/summary")
def dashboard_summary(db: Session = Depends(get_db)) -> dict[str, Any]:
    _ensure_totem_columns(db)
    trend_points = db.scalar(select(func.count()).select_from(TrendObservation)) or 0
    place_locations = db.scalar(select(func.count()).select_from(PlaceLocation)) or 0
    events = db.scalar(select(func.count()).select_from(RegionalEvent)) or 0
    observations = db.scalar(select(func.count()).select_from(ExternalObservation)) or 0
    totem_count = db.scalar(select(func.count()).select_from(TotemFeedback)) or 0
    redeemed_count = (
        db.scalar(select(func.count()).select_from(TotemFeedback).where(TotemFeedback.is_redeemed.is_(True))) or 0
    )

    return {
        "status": "ok",
        "summary": {
            "observations": observations,
            "trend_points": trend_points,
            "place_locations": place_locations,
            "regional_events": events,
            "totem_feedbacks": totem_count,
            "totem_redeemed": redeemed_count,
            "source_status": {
                "google_trends": "active" if trend_points > 0 else "offline_until_csv_import",
                "google_places": "pending_credentials" if not get_settings().google_places_api_key else "configured",
                "regional_events": "manual_or_public_sources",
                "totem_first_party": "active",
            },
        },
    }