"""Logging, segurança simples (token admin) e utilidades transversais."""
from __future__ import annotations

import logging
import secrets
import sys

from fastapi import Header, HTTPException, status

from app.core.config import get_settings


def configure_logging() -> None:
    level = get_settings().log_level.upper()
    logging.basicConfig(
        level=level,
        stream=sys.stdout,
        format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
    )


def require_admin(x_admin_token: str | None = Header(default=None)) -> None:
    """Exige o header X-Admin-Token para operações de escrita/coleta."""
    expected = get_settings().admin_api_token
    if not expected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="ADMIN_API_TOKEN não configurado; operações de escrita desabilitadas.",
        )
    if not x_admin_token or not secrets.compare_digest(x_admin_token, expected):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token administrativo inválido.")
