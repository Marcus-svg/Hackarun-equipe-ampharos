"""Modelos ORM.

Toda informação externa gera um registro em ``external_observations`` (ledger de
metadados comuns: fonte, coleta, localidade, categoria, período, status). As
tabelas especializadas guardam os campos específicos e referenciam o ledger 1:1,
evitando duplicação de metadados.
"""
from __future__ import annotations

from datetime import date, datetime, timezone

from sqlalchemy import (
    JSON,
    Boolean,
    Date,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class ExternalSource(Base):
    __tablename__ = "external_sources"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    key: Mapped[str] = mapped_column(String(80), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(200))
    source_type: Mapped[str] = mapped_column(String(40), index=True)  # google_trends|google_places|regional_events|totem
    access_method: Mapped[str] = mapped_column(String(40))  # official_api|official_export_csv|manual_import|ics_feed|jsonld_page|organizer_api
    base_url: Mapped[str | None] = mapped_column(String(500))
    municipality: Mapped[str | None] = mapped_column(String(120))
    terms_notes: Mapped[str | None] = mapped_column(Text)
    enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class CollectionRun(Base):
    __tablename__ = "collection_runs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    source_id: Mapped[int] = mapped_column(ForeignKey("external_sources.id", ondelete="CASCADE"), index=True)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, index=True)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    status: Mapped[str] = mapped_column(String(20), default="running")  # running|success|partial|failed|skipped
    records_received: Mapped[int] = mapped_column(Integer, default=0)
    records_saved: Mapped[int] = mapped_column(Integer, default=0)
    records_rejected: Mapped[int] = mapped_column(Integer, default=0)
    message: Mapped[str | None] = mapped_column(Text)

    source: Mapped[ExternalSource] = relationship()


class ExternalObservation(Base):
    __tablename__ = "external_observations"
    __table_args__ = (
        Index("ix_obs_type_theme", "observation_type", "theme"),
        Index("ix_obs_collected", "collected_at"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    source_id: Mapped[int] = mapped_column(ForeignKey("external_sources.id", ondelete="RESTRICT"), index=True)
    run_id: Mapped[int | None] = mapped_column(ForeignKey("collection_runs.id", ondelete="SET NULL"))
    observation_type: Mapped[str] = mapped_column(String(40))  # trend_point|regional_event|place_snapshot
    theme: Mapped[str | None] = mapped_column(String(40), index=True)
    category: Mapped[str | None] = mapped_column(String(60), index=True)
    locality: Mapped[str | None] = mapped_column(String(120), index=True)
    reference_start: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    reference_end: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    value_numeric: Mapped[float | None] = mapped_column(Float)
    value_text: Mapped[str | None] = mapped_column(Text)
    source_url: Mapped[str | None] = mapped_column(String(1000))
    collection_method: Mapped[str] = mapped_column(String(40))
    data_status: Mapped[str] = mapped_column(String(20), index=True)
    validation_status: Mapped[str] = mapped_column(String(20), index=True)
    quality_score: Mapped[float | None] = mapped_column(Float)  # 0..1
    quality_notes: Mapped[str | None] = mapped_column(Text)
    collected_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), index=True)

    source: Mapped[ExternalSource] = relationship()


class TrendObservation(Base):
    __tablename__ = "trend_observations"
    __table_args__ = (
        UniqueConstraint("series_key", "term", "period_date", name="uq_trend_point"),
        Index("ix_trend_theme_geo_date", "theme", "geo", "period_date"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    observation_id: Mapped[int] = mapped_column(
        ForeignKey("external_observations.id", ondelete="CASCADE"), unique=True
    )
    # Índices do Trends só são comparáveis dentro da mesma consulta/exportação.
    series_key: Mapped[str] = mapped_column(String(120), index=True)
    term: Mapped[str] = mapped_column(String(200), index=True)
    term_group: Mapped[str | None] = mapped_column(String(60), index=True)
    theme: Mapped[str | None] = mapped_column(String(40))
    geo: Mapped[str] = mapped_column(String(20))
    geo_level: Mapped[str] = mapped_column(String(20))  # municipio|estado|pais
    period_date: Mapped[date] = mapped_column(Date)
    granularity: Mapped[str] = mapped_column(String(10))  # day|week|month
    interest_index: Mapped[float] = mapped_column(Float)  # 0..100 relativo
    raw_value: Mapped[str] = mapped_column(String(20))
    below_one: Mapped[bool] = mapped_column(Boolean, default=False)
    limitations: Mapped[str | None] = mapped_column(Text)

    observation: Mapped[ExternalObservation] = relationship()


class RegionalEvent(Base):
    __tablename__ = "regional_events"
    __table_args__ = (
        UniqueConstraint("source_id", "external_id", name="uq_event_source_external"),
        Index("ix_event_start", "start_at"),
        Index("ix_event_category_city", "category", "municipality"),
        Index("ix_event_coords", "latitude", "longitude"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    observation_id: Mapped[int] = mapped_column(
        ForeignKey("external_observations.id", ondelete="CASCADE"), unique=True
    )
    source_id: Mapped[int] = mapped_column(ForeignKey("external_sources.id", ondelete="RESTRICT"), index=True)
    external_id: Mapped[str] = mapped_column(String(300))
    fingerprint: Mapped[str] = mapped_column(String(64), index=True)
    name: Mapped[str] = mapped_column(String(300))
    description: Mapped[str | None] = mapped_column(Text)
    category: Mapped[str | None] = mapped_column(String(60))
    theme: Mapped[str | None] = mapped_column(String(40), index=True)
    start_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    end_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    has_time: Mapped[bool] = mapped_column(Boolean, default=False)
    venue: Mapped[str | None] = mapped_column(String(300))
    municipality: Mapped[str] = mapped_column(String(120))
    state: Mapped[str | None] = mapped_column(String(2))
    address: Mapped[str | None] = mapped_column(String(500))
    latitude: Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    organizer: Mapped[str | None] = mapped_column(String(300))
    price_text: Mapped[str | None] = mapped_column(String(120))
    is_free: Mapped[bool | None] = mapped_column(Boolean)
    source_url: Mapped[str | None] = mapped_column(String(1000))
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    collected_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, onupdate=utcnow)
    cancelled: Mapped[bool] = mapped_column(Boolean, default=False)
    duplicate_of_id: Mapped[int | None] = mapped_column(ForeignKey("regional_events.id", ondelete="SET NULL"))

    observation: Mapped[ExternalObservation] = relationship()
    source: Mapped[ExternalSource] = relationship()


class PlaceLocation(Base):
    """Estabelecimento conhecido. Só o place_id é armazenado indefinidamente."""

    __tablename__ = "place_locations"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    google_place_id: Mapped[str] = mapped_column(String(200), unique=True, index=True)
    category: Mapped[str] = mapped_column(String(40), index=True)
    is_anchor: Mapped[bool] = mapped_column(Boolean, default=False)
    query_used: Mapped[str | None] = mapped_column(String(300))
    first_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    last_refreshed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    # Cache temporário (termos Google: até 30 dias)
    latitude: Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    coordinates_expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class PlaceObservation(Base):
    """Snapshot temporário de conteúdo Places (expira; ver PLACES_CONTENT_CACHE_HOURS).

    Textos de avaliações NUNCA são gravados; apenas contagens agregadas de temas
    e polaridade calculadas sobre a amostra retornada pela API.
    """

    __tablename__ = "place_observations"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    observation_id: Mapped[int] = mapped_column(
        ForeignKey("external_observations.id", ondelete="CASCADE"), unique=True
    )
    place_location_id: Mapped[int] = mapped_column(ForeignKey("place_locations.id", ondelete="CASCADE"), index=True)
    name: Mapped[str | None] = mapped_column(String(300))
    address: Mapped[str | None] = mapped_column(String(500))
    primary_type: Mapped[str | None] = mapped_column(String(80))
    rating: Mapped[float | None] = mapped_column(Float)
    user_rating_count: Mapped[int | None] = mapped_column(Integer)
    google_maps_uri: Mapped[str | None] = mapped_column(String(1000))
    review_sample_size: Mapped[int] = mapped_column(Integer, default=0)
    review_themes: Mapped[dict | None] = mapped_column(JSON)
    sentiment_counts: Mapped[dict | None] = mapped_column(JSON)
    collected_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)

    observation: Mapped[ExternalObservation] = relationship()
    location: Mapped[PlaceLocation] = relationship()


class TotemFeedback(Base):
    """Respostas do totem enviadas pelo app Flutter (dados próprios, anônimos)."""

    __tablename__ = "totem_feedbacks"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    coupon_code: Mapped[str | None] = mapped_column(String(20), unique=True, index=True)
    age_group: Mapped[str] = mapped_column(String(40))
    interest_category: Mapped[str] = mapped_column(String(60))
    theme: Mapped[str | None] = mapped_column(String(40), index=True)
    preferred_event_format: Mapped[str | None] = mapped_column(String(200))
    general_satisfaction: Mapped[str | None] = mapped_column(String(40))
    discount_benefit: Mapped[str | None] = mapped_column(String(60))
    is_redeemed: Mapped[bool] = mapped_column(Boolean, default=False)
    redeemed_store_name: Mapped[str | None] = mapped_column(String(120))
    data_status: Mapped[str] = mapped_column(String(20), default="real")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, index=True)


class IntelligenceIndicator(Base):
    __tablename__ = "intelligence_indicators"
    __table_args__ = (Index("ix_indicator_key_theme", "indicator_key", "theme"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    indicator_key: Mapped[str] = mapped_column(String(60))
    theme: Mapped[str | None] = mapped_column(String(40))
    locality: Mapped[str | None] = mapped_column(String(120))
    period_start: Mapped[date | None] = mapped_column(Date)
    period_end: Mapped[date | None] = mapped_column(Date)
    value: Mapped[float | None] = mapped_column(Float)
    unit: Mapped[str | None] = mapped_column(String(40))
    sample_size: Mapped[int | None] = mapped_column(Integer)
    data_status: Mapped[str] = mapped_column(String(20))
    details: Mapped[dict | None] = mapped_column(JSON)
    sources: Mapped[list | None] = mapped_column(JSON)
    computed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, index=True)


class Opportunity(Base):
    __tablename__ = "opportunities"
    __table_args__ = (Index("ix_opportunity_theme_generated", "theme", "generated_at"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    title: Mapped[str] = mapped_column(String(300))
    theme: Mapped[str] = mapped_column(String(40))
    opportunity_type: Mapped[str] = mapped_column(String(40))  # lacuna_oferta|parceria_ancoragem|demanda_propria
    classification: Mapped[str] = mapped_column(String(30))  # recomendacao|hipotese_a_validar
    description: Mapped[str] = mapped_column(Text)
    locality: Mapped[str] = mapped_column(String(120))
    period_start: Mapped[date | None] = mapped_column(Date)
    period_end: Mapped[date | None] = mapped_column(Date)
    evidence: Mapped[list] = mapped_column(JSON)
    sources: Mapped[list] = mapped_column(JSON)
    justification: Mapped[str] = mapped_column(Text)
    limitations: Mapped[list] = mapped_column(JSON)
    score: Mapped[float | None] = mapped_column(Float)
    score_breakdown: Mapped[dict | None] = mapped_column(JSON)
    data_coverage: Mapped[float] = mapped_column(Float)  # 0..1 dos pesos com dados
    is_current: Mapped[bool] = mapped_column(Boolean, default=True, index=True)
    generated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, index=True)
