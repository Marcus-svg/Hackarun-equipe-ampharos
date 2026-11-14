"""Cliente da Google Places API (New) - endpoints oficiais documentados.

- Text Search:  POST https://places.googleapis.com/v1/places:searchText
- Place Details: GET  https://places.googleapis.com/v1/places/{place_id}

Autenticação via header ``X-Goog-Api-Key`` e seleção de campos via
``X-Goog-FieldMask`` (obrigatório; também define o SKU cobrado).
"""
from __future__ import annotations

import logging
from typing import Any

from app.core.config import get_settings
from app.core.http import ExternalSourceError, RateLimiter, ResilientHttp

log = logging.getLogger(__name__)

BASE_URL = "https://places.googleapis.com/v1"

SEARCH_FIELDS = ",".join(
    f"places.{f}"
    for f in (
        "id",
        "displayName",
        "formattedAddress",
        "location",
        "primaryType",
        "types",
        "rating",
        "userRatingCount",
        "googleMapsUri",
    )
) + ",nextPageToken"

DETAIL_FIELDS = "id,displayName,formattedAddress,location,primaryType,types,rating,userRatingCount,googleMapsUri"
DETAIL_FIELDS_WITH_REVIEWS = DETAIL_FIELDS + ",reviews"


class PlacesNotConfigured(RuntimeError):
    pass


class GooglePlacesClient:
    def __init__(self, api_key: str | None = None, http: ResilientHttp | None = None):
        s = get_settings()
        self.api_key = api_key if api_key is not None else s.google_places_api_key
        self.settings = s
        self.http = http or ResilientHttp(rate_limiter=RateLimiter(s.places_max_requests_per_minute))

    def _headers(self, field_mask: str) -> dict[str, str]:
        if not self.api_key:
            raise PlacesNotConfigured("GOOGLE_PLACES_API_KEY não configurada.")
        return {"X-Goog-Api-Key": self.api_key, "X-Goog-FieldMask": field_mask, "Content-Type": "application/json"}

    @staticmethod
    def _check(resp) -> dict[str, Any]:
        if resp.status_code >= 400:
            try:
                msg = resp.json().get("error", {}).get("message", resp.text[:200])
            except ValueError:
                msg = resp.text[:200]
            raise ExternalSourceError(f"Places API HTTP {resp.status_code}: {msg}")
        return resp.json()

    def search_text(self, query: str, page_size: int = 20, page_token: str | None = None) -> dict[str, Any]:
        body: dict[str, Any] = {
            "textQuery": query,
            "languageCode": self.settings.places_language_code,
            "regionCode": self.settings.places_region_code,
            "pageSize": max(1, min(page_size, 20)),
            "locationBias": {
                "circle": {
                    "center": {
                        "latitude": self.settings.places_bias_latitude,
                        "longitude": self.settings.places_bias_longitude,
                    },
                    "radius": self.settings.places_bias_radius_m,
                }
            },
        }
        if page_token:
            body["pageToken"] = page_token
        resp = self.http.request("POST", f"{BASE_URL}/places:searchText", headers=self._headers(SEARCH_FIELDS), json=body)
        return self._check(resp)

    def place_details(self, place_id: str, include_reviews: bool = False) -> dict[str, Any]:
        mask = DETAIL_FIELDS_WITH_REVIEWS if include_reviews else DETAIL_FIELDS
        resp = self.http.request(
            "GET",
            f"{BASE_URL}/places/{place_id}",
            headers=self._headers(mask),
            params={"languageCode": self.settings.places_language_code, "regionCode": self.settings.places_region_code},
        )
        return self._check(resp)
