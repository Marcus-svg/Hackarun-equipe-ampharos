"""Cliente HTTP resiliente: timeout, retry com backoff exponencial e limite de taxa."""
from __future__ import annotations

import logging
import threading
import time
from typing import Any

import httpx

from app.core.config import get_settings

log = logging.getLogger(__name__)

RETRYABLE_STATUS = {429, 500, 502, 503, 504}


class ExternalSourceError(RuntimeError):
    """Falha de uma fonte externa (isolada: não deve derrubar as demais)."""


class RateLimiter:
    """Token bucket simples por processo."""

    def __init__(self, max_per_minute: int):
        self.capacity = max(1, max_per_minute)
        self.tokens = float(self.capacity)
        self.rate = self.capacity / 60.0
        self.updated = time.monotonic()
        self.lock = threading.Lock()

    def acquire(self) -> None:
        while True:
            with self.lock:
                now = time.monotonic()
                self.tokens = min(self.capacity, self.tokens + (now - self.updated) * self.rate)
                self.updated = now
                if self.tokens >= 1:
                    self.tokens -= 1
                    return
                wait = (1 - self.tokens) / self.rate
            time.sleep(wait)


class ResilientHttp:
    def __init__(
        self,
        client: httpx.Client | None = None,
        max_retries: int | None = None,
        rate_limiter: RateLimiter | None = None,
        backoff_base: float = 0.5,
    ):
        s = get_settings()
        self.client = client or httpx.Client(
            timeout=s.http_timeout_seconds,
            headers={"User-Agent": s.http_user_agent},
            follow_redirects=True,
        )
        self.max_retries = s.http_max_retries if max_retries is None else max_retries
        self.rate_limiter = rate_limiter
        self.backoff_base = backoff_base

    def request(self, method: str, url: str, **kwargs: Any) -> httpx.Response:
        last_exc: Exception | None = None
        for attempt in range(self.max_retries + 1):
            if self.rate_limiter:
                self.rate_limiter.acquire()
            try:
                resp = self.client.request(method, url, **kwargs)
                if resp.status_code in RETRYABLE_STATUS and attempt < self.max_retries:
                    log.warning("HTTP %s em %s (tentativa %s)", resp.status_code, url, attempt + 1)
                    time.sleep(self.backoff_base * (2**attempt))
                    continue
                return resp
            except (httpx.TimeoutException, httpx.TransportError) as exc:
                last_exc = exc
                log.warning("Erro de transporte em %s: %s (tentativa %s)", url, exc, attempt + 1)
                if attempt < self.max_retries:
                    time.sleep(self.backoff_base * (2**attempt))
        raise ExternalSourceError(f"Falha ao acessar {url}: {last_exc}")
