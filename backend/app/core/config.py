"""Configuração centralizada (variáveis de ambiente / arquivo .env)."""
from __future__ import annotations

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = "development"
    log_level: str = "INFO"

    # SQLite local por padrão; em produção use PostgreSQL/Supabase:
    # postgresql+psycopg://user:pass@host:5432/postgres
    database_url: str = "sqlite:///./hackarun.db"

    # Protege endpoints de escrita/coleta. Vazio = escrita desabilitada.
    admin_api_token: str = ""

    # Origens liberadas para o Flutter Web (separadas por vírgula).
    cors_origins: str = "*"

    # --- Google Places API (New) ---
    google_places_api_key: str = ""
    places_language_code: str = "pt-BR"
    places_region_code: str = "BR"
    # Centro de busca (viés geográfico) - Palmas/TO. Usado apenas como locationBias.
    places_bias_latitude: float = -10.1844
    places_bias_longitude: float = -48.3336
    places_bias_radius_m: float = 20000.0
    # Termos do Google Maps Platform: só place_id pode ser armazenado indefinidamente;
    # lat/lng até 30 dias. Demais conteúdos ficam em cache temporário com expiração.
    places_content_cache_hours: int = 24
    places_coordinates_cache_days: int = 30
    places_max_requests_per_minute: int = 30

    # --- Sympla (opcional; retorna apenas eventos do organizador dono do token) ---
    sympla_api_token: str = ""
    sympla_api_base_url: str = "https://api.sympla.com.br/public/v1.5.1"

    # --- Coleta de eventos em páginas/feeds públicos configurados ---
    http_user_agent: str = "HackarunBot/1.0 (+contato: equipe Hackarun; inteligencia regional Capim Dourado)"
    http_timeout_seconds: float = 15.0
    http_max_retries: int = 3

    # --- Qualidade de dados ---
    stale_after_days_trends: int = 45
    stale_after_days_events: int = 14

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
