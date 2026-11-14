from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.database import get_db
from app.integrations.google_places.service import PlacesService
from app.integrations.google_trends.service import import_trends_csv
from app.models import ExternalObservation, PlaceLocation, RegionalEvent, TrendObservation

router = APIRouter(prefix="/api", tags=["hackarun"])


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
            "region_bias": {"latitude": settings.places_bias_latitude, "longitude": settings.places_bias_longitude, "radius_m": settings.places_bias_radius_m},
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


@router.post("/places/refresh")
def refresh_places(category: str | None = None, db: Session = Depends(get_db)) -> dict[str, Any]:
    settings = get_settings()
    if not settings.google_places_api_key:
        raise HTTPException(status_code=503, detail="GOOGLE_PLACES_API_KEY não configurada; a coleta oficial está indisponível neste ambiente.")

    try:
        service = PlacesService(db)
        if category:
            return service.refresh_category(category)
        return service.refresh_all()
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/dashboard/summary")
def dashboard_summary(db: Session = Depends(get_db)) -> dict[str, Any]:
    trend_points = db.scalar(select(func.count()).select_from(TrendObservation)) or 0
    place_locations = db.scalar(select(func.count()).select_from(PlaceLocation)) or 0
    events = db.scalar(select(func.count()).select_from(RegionalEvent)) or 0
    observations = db.scalar(select(func.count()).select_from(ExternalObservation)) or 0

    return {
        "status": "ok",
        "summary": {
            "observations": observations,
            "trend_points": trend_points,
            "place_locations": place_locations,
            "regional_events": events,
            "source_status": {
                "google_trends": "offline_until_csv_import",
                "google_places": "pending_credentials" if not get_settings().google_places_api_key else "configured",
                "regional_events": "manual_or_public_sources",
            },
        },
    }
