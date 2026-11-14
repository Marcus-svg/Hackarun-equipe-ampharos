"""Repositório de fontes, execuções de coleta e ledger de observações."""
from __future__ import annotations

from datetime import datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models import CollectionRun, ExternalObservation, ExternalSource, utcnow

DEFAULT_SOURCES: list[dict] = [
    {
        "key": "google_trends_csv",
        "name": "Google Trends - exportação CSV oficial da interface web",
        "source_type": "google_trends",
        "access_method": "official_export_csv",
        "base_url": "https://trends.google.com/trends/explore",
        "terms_notes": (
            "Arquivo baixado manualmente pelo botão 'Download CSV' do Google Trends. "
            "Índices relativos (0-100) comparáveis apenas dentro da mesma exportação. "
            "Não representa volume absoluto de buscas."
        ),
    },
    {
        "key": "google_trends_api",
        "name": "Google Trends API (alpha)",
        "source_type": "google_trends",
        "access_method": "official_api",
        "base_url": "https://developers.google.com/search/docs/appearance/trends/overview",
        "enabled": False,
        "terms_notes": (
            "API oficial em alpha com acesso mediante candidatura. Desabilitada até "
            "a aprovação; cliente será implementado conforme contrato oficial recebido."
        ),
    },
    {
        "key": "google_places",
        "name": "Google Places API (New)",
        "source_type": "google_places",
        "access_method": "official_api",
        "base_url": "https://places.googleapis.com/v1",
        "terms_notes": (
            "Somente place_id armazenado indefinidamente; lat/lng até 30 dias; demais "
            "conteúdos em cache temporário com expiração. Textos de avaliações não são "
            "persistidos. Máximo de 5 avaliações por local. Exibir atribuição Google."
        ),
    },
    {
        "key": "events_manual",
        "name": "Importação manual/controlada de eventos públicos",
        "source_type": "regional_events",
        "access_method": "manual_import",
        "terms_notes": "Cada evento deve trazer a URL pública de origem.",
    },
    {
        "key": "sympla_organizer",
        "name": "Sympla API pública (eventos do próprio organizador)",
        "source_type": "regional_events",
        "access_method": "organizer_api",
        "base_url": "https://developers.sympla.com.br/api-doc/index.html",
        "terms_notes": (
            "A API retorna apenas eventos da conta dona do token (s_token). Não permite "
            "consultar o catálogo de eventos de terceiros."
        ),
    },
    {
        "key": "totem",
        "name": "Totem Capim Dourado (dados próprios)",
        "source_type": "totem",
        "access_method": "first_party",
        "terms_notes": "Respostas anônimas coletadas no totem com consentimento LGPD.",
    },
]


def ensure_default_sources(db: Session) -> None:
    settings = get_settings()
    for spec in DEFAULT_SOURCES:
        existing = db.scalar(select(ExternalSource).where(ExternalSource.key == spec["key"]))
        enabled = spec.get("enabled", True)
        if spec["key"] == "sympla_organizer":
            enabled = bool(settings.sympla_api_token)
        if spec["key"] == "google_places":
            enabled = bool(settings.google_places_api_key)
        if existing:
            existing.enabled = enabled
            continue
        db.add(ExternalSource(**{**spec, "enabled": enabled}))
    db.commit()


def get_source(db: Session, key: str) -> ExternalSource:
    src = db.scalar(select(ExternalSource).where(ExternalSource.key == key))
    if src is None:
        ensure_default_sources(db)
        src = db.scalar(select(ExternalSource).where(ExternalSource.key == key))
    if src is None:
        raise LookupError(f"Fonte '{key}' não cadastrada")
    return src


def start_run(db: Session, source: ExternalSource) -> CollectionRun:
    run = CollectionRun(source_id=source.id, status="running")
    db.add(run)
    db.flush()
    return run


def finish_run(
    db: Session,
    run: CollectionRun,
    *,
    received: int,
    saved: int,
    rejected: int,
    message: str | None = None,
    failed: bool = False,
) -> CollectionRun:
    run.finished_at = utcnow()
    run.records_received = received
    run.records_saved = saved
    run.records_rejected = rejected
    run.message = message
    if failed:
        run.status = "failed"
    elif rejected and saved:
        run.status = "partial"
    elif rejected and not saved:
        run.status = "failed" if received else "success"
    else:
        run.status = "success"
    db.commit()
    return run


def new_observation(
    db: Session,
    *,
    source: ExternalSource,
    run: CollectionRun | None,
    observation_type: str,
    collection_method: str,
    data_status: str,
    validation_status: str,
    theme: str | None = None,
    category: str | None = None,
    locality: str | None = None,
    reference_start: datetime | None = None,
    reference_end: datetime | None = None,
    value_numeric: float | None = None,
    value_text: str | None = None,
    source_url: str | None = None,
    quality_score: float | None = None,
    quality_notes: str | None = None,
    expires_at: datetime | None = None,
) -> ExternalObservation:
    obs = ExternalObservation(
        source_id=source.id,
        run_id=run.id if run else None,
        observation_type=observation_type,
        collection_method=collection_method,
        data_status=data_status,
        validation_status=validation_status,
        theme=theme,
        category=category,
        locality=locality,
        reference_start=reference_start,
        reference_end=reference_end,
        value_numeric=value_numeric,
        value_text=value_text,
        source_url=source_url,
        quality_score=quality_score,
        quality_notes=quality_notes,
        expires_at=expires_at,
    )
    db.add(obs)
    db.flush()
    return obs
