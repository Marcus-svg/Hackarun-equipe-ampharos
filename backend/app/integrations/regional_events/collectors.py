"""Coletores de eventos regionais.

Somente mecanismos permitidos:
- ``ics_feed``: feeds iCalendar publicados por agendas (formato aberto para consumo automatizado).
- ``jsonld_page``: páginas públicas cadastradas explicitamente por um administrador, que
  publicam dados estruturados schema.org/Event (JSON-LD). Respeita robots.txt; não navega
  por links nem faz varredura de sites; não é usado para redes sociais.
- ``organizer_api``: API pública da Sympla (somente eventos do organizador dono do token).
- importação manual/CSV (ver service.py).
"""
from __future__ import annotations

import json
import logging
import re
from typing import Any
from urllib.parse import urljoin, urlparse
from urllib.robotparser import RobotFileParser

from app.core.config import get_settings
from app.core.http import ExternalSourceError, ResilientHttp

log = logging.getLogger(__name__)


class CollectorNotAllowed(ExternalSourceError):
    pass


def _robots_allows(http: ResilientHttp, url: str) -> bool:
    parsed = urlparse(url)
    robots_url = f"{parsed.scheme}://{parsed.netloc}/robots.txt"
    try:
        resp = http.request("GET", robots_url)
    except ExternalSourceError:
        return True  # robots indisponível: padrão do protocolo é permitir
    if resp.status_code >= 400:
        return True
    rp = RobotFileParser()
    rp.parse(resp.text.splitlines())
    return rp.can_fetch(get_settings().http_user_agent, url)


# --------------------------------------------------------------------- ICS
def collect_ics(http: ResilientHttp, url: str) -> list[dict[str, Any]]:
    from icalendar import Calendar

    resp = http.request("GET", url)
    if resp.status_code >= 400:
        raise ExternalSourceError(f"ICS HTTP {resp.status_code} em {url}")
    cal = Calendar.from_ical(resp.content)
    events = []
    for comp in cal.walk("VEVENT"):
        geo = comp.get("GEO")
        cats = comp.get("CATEGORIES")
        cat_value = None
        if cats is not None:
            cat_list = cats if isinstance(cats, list) else [cats]
            try:
                cat_value = str(cat_list[0].cats[0]) if hasattr(cat_list[0], "cats") else str(cat_list[0])
            except (IndexError, AttributeError):
                cat_value = None
        events.append(
            {
                "external_id": str(comp.get("UID") or ""),
                "name": str(comp.get("SUMMARY") or ""),
                "description": str(comp.get("DESCRIPTION") or "") or None,
                "start": comp.decoded("DTSTART") if comp.get("DTSTART") else None,
                "end": comp.decoded("DTEND") if comp.get("DTEND") else None,
                "venue": str(comp.get("LOCATION") or "") or None,
                "latitude": getattr(geo, "latitude", None),
                "longitude": getattr(geo, "longitude", None),
                "category": cat_value,
                "source_url": str(comp.get("URL") or url),
                "cancelled": str(comp.get("STATUS") or "").upper() == "CANCELLED",
            }
        )
    return events


# ----------------------------------------------------------------- JSON-LD
_LD_RE = re.compile(r'<script[^>]+type=["\']application/ld\+json["\'][^>]*>(.*?)</script>', re.S | re.I)


def _iter_ld_nodes(node: Any):
    if isinstance(node, list):
        for n in node:
            yield from _iter_ld_nodes(n)
    elif isinstance(node, dict):
        yield node
        if "@graph" in node:
            yield from _iter_ld_nodes(node["@graph"])


def _is_event(node: dict) -> bool:
    t = node.get("@type")
    types = t if isinstance(t, list) else [t]
    return any(isinstance(x, str) and x.endswith("Event") for x in types)


def _first(v: Any) -> Any:
    return v[0] if isinstance(v, list) and v else v


def parse_jsonld_events(html: str, page_url: str) -> list[dict[str, Any]]:
    events = []
    for block in _LD_RE.findall(html):
        try:
            data = json.loads(block.strip())
        except json.JSONDecodeError:
            continue
        for node in _iter_ld_nodes(data):
            if not _is_event(node):
                continue
            loc = _first(node.get("location")) or {}
            addr = loc.get("address") if isinstance(loc, dict) else None
            addr = _first(addr) or {}
            if isinstance(addr, str):
                addr = {"streetAddress": addr}
            geo = (loc.get("geo") if isinstance(loc, dict) else None) or {}
            org = _first(node.get("organizer")) or {}
            offers = _first(node.get("offers")) or {}
            price = offers.get("price") if isinstance(offers, dict) else None
            status = str(node.get("eventStatus") or "")
            events.append(
                {
                    "external_id": node.get("@id") or node.get("url") or None,
                    "name": node.get("name"),
                    "description": node.get("description"),
                    "start": node.get("startDate"),
                    "end": node.get("endDate"),
                    "venue": loc.get("name") if isinstance(loc, dict) else None,
                    "address": ", ".join(
                        str(x) for x in (addr.get("streetAddress"), addr.get("addressLocality")) if x
                    ) or None,
                    "municipality": addr.get("addressLocality"),
                    "state": addr.get("addressRegion"),
                    "latitude": geo.get("latitude"),
                    "longitude": geo.get("longitude"),
                    "organizer": org.get("name") if isinstance(org, dict) else (org or None),
                    "price_text": (f"{price} {offers.get('priceCurrency', '')}".strip() if price not in (None, "") else None),
                    "is_free": node.get("isAccessibleForFree") if node.get("isAccessibleForFree") is not None
                    else (True if str(price) in {"0", "0.0", "0.00"} else None),
                    "source_url": urljoin(page_url, node.get("url")) if node.get("url") else page_url,
                    "cancelled": status.endswith("EventCancelled"),
                }
            )
    return events


def collect_jsonld(http: ResilientHttp, url: str) -> list[dict[str, Any]]:
    if not _robots_allows(http, url):
        raise CollectorNotAllowed(f"robots.txt não permite a coleta de {url}")
    resp = http.request("GET", url, headers={"Accept": "text/html"})
    if resp.status_code >= 400:
        raise ExternalSourceError(f"HTTP {resp.status_code} em {url}")
    return parse_jsonld_events(resp.text, url)


# ------------------------------------------------------------------ Sympla
def collect_sympla_organizer(http: ResilientHttp, token: str, base_url: str, max_pages: int = 10) -> list[dict[str, Any]]:
    """Eventos publicados da conta dona do token (API pública Sympla, header ``s_token``)."""
    if not token:
        raise ExternalSourceError("SYMPLA_API_TOKEN não configurado")
    out: list[dict[str, Any]] = []
    page = 1
    while page <= max_pages:
        resp = http.request(
            "GET",
            f"{base_url.rstrip('/')}/events",
            headers={"s_token": token},
            params={"page": page, "page_size": 100, "published": "true"},
        )
        if resp.status_code >= 400:
            raise ExternalSourceError(f"Sympla HTTP {resp.status_code}")
        payload = resp.json()
        for e in payload.get("data", []):
            addr = e.get("address") or {}
            out.append(
                {
                    "external_id": str(e.get("id")),
                    "name": e.get("name"),
                    "description": e.get("detail"),
                    "start": e.get("start_date"),
                    "end": e.get("end_date"),
                    "venue": addr.get("name"),
                    "address": ", ".join(str(x) for x in (addr.get("address"), addr.get("address_num"), addr.get("neighborhood")) if x) or None,
                    "municipality": addr.get("city"),
                    "state": addr.get("state"),
                    "latitude": addr.get("lat"),
                    "longitude": addr.get("lon"),
                    "organizer": (e.get("host") or {}).get("name"),
                    "category": (e.get("category_prim") or {}).get("name"),
                    "source_url": e.get("url"),
                    "cancelled": bool(e.get("cancelled")),
                }
            )
        if not (payload.get("pagination") or {}).get("has_next"):
            break
        page += 1
    return out
