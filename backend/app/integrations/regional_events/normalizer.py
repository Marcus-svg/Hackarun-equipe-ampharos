"""Normalização e validação de eventos regionais (comum a todas as fontes)."""
from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass, field
from datetime import date, datetime, time, timedelta, timezone
from typing import Any

from app.core.taxonomy import EVENT_CATEGORIES, guess_event_category, normalize_text, slugify

# Tocantins (America/Araguaina) não adota horário de verão: UTC-3 fixo.
TZ_TO = timezone(timedelta(hours=-3), name="America/Araguaina")

# Caixa aproximada do Tocantins para validar coordenadas
TO_BBOX = {"lat_min": -13.6, "lat_max": -5.0, "lng_min": -50.9, "lng_max": -45.5}

REQUIRED = ("name", "start", "municipality", "source_url")


@dataclass
class NormalizedEvent:
    external_id: str
    fingerprint: str
    name: str
    description: str | None
    category: str | None
    theme: str | None
    start_at: datetime
    end_at: datetime | None
    has_time: bool
    venue: str | None
    municipality: str
    state: str | None
    address: str | None
    latitude: float | None
    longitude: float | None
    organizer: str | None
    price_text: str | None
    is_free: bool | None
    source_url: str | None
    published_at: datetime | None
    cancelled: bool
    issues: list[str] = field(default_factory=list)
    quality_score: float = 0.0
    validation_status: str = "valido"


class EventValidationError(ValueError):
    def __init__(self, issues: list[str]):
        super().__init__("; ".join(issues))
        self.issues = issues


def parse_datetime(value: Any) -> tuple[datetime | None, bool]:
    """Retorna (datetime com tz, possui_horario)."""
    if value is None or value == "":
        return None, False
    if isinstance(value, datetime):
        dt = value if value.tzinfo else value.replace(tzinfo=TZ_TO)
        return dt, True
    if isinstance(value, date):
        return datetime.combine(value, time.min, tzinfo=TZ_TO), False
    s = str(value).strip()
    has_time = bool(re.search(r"\d{1,2}:\d{2}", s))
    try:
        dt = datetime.fromisoformat(s.replace("Z", "+00:00"))
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=TZ_TO)
        return dt, has_time
    except ValueError:
        pass
    for fmt in ("%d/%m/%Y %H:%M", "%d/%m/%Y %Hh%M", "%d/%m/%Y", "%Y-%m-%d %H:%M:%S"):
        try:
            return datetime.strptime(s, fmt).replace(tzinfo=TZ_TO), "%H" in fmt
        except ValueError:
            continue
    return None, False


def _to_float(v: Any) -> float | None:
    if v is None or v == "":
        return None
    try:
        return float(str(v).replace(",", "."))
    except ValueError:
        return None


def _to_bool(v: Any) -> bool | None:
    if v is None or v == "":
        return None
    if isinstance(v, bool):
        return v
    s = normalize_text(str(v))
    if s in {"sim", "true", "1", "yes", "gratuito", "gratis", "s"}:
        return True
    if s in {"nao", "false", "0", "no", "pago", "n"}:
        return False
    return None


def make_fingerprint(name: str, start: datetime, municipality: str) -> str:
    key = f"{normalize_text(name)}|{start.astimezone(TZ_TO).date().isoformat()}|{normalize_text(municipality)}"
    return hashlib.sha1(key.encode()).hexdigest()


def normalize_event(raw: dict[str, Any], *, default_municipality: str | None = None, now: datetime | None = None) -> NormalizedEvent:
    now = now or datetime.now(timezone.utc)
    issues: list[str] = []
    data = dict(raw)
    if not data.get("municipality") and default_municipality:
        data["municipality"] = default_municipality

    name = (data.get("name") or "").strip()
    start, has_time = parse_datetime(data.get("start"))
    end, _ = parse_datetime(data.get("end"))
    municipality = (data.get("municipality") or "").strip()
    source_url = (data.get("source_url") or "").strip() or None

    fatal: list[str] = []
    if not name:
        fatal.append("nome ausente")
    if data.get("start") and start is None:
        fatal.append(f"data de início inválida: {data.get('start')!r}")
    elif start is None:
        fatal.append("data de início ausente")
    if not municipality:
        fatal.append("município ausente")
    if not source_url:
        fatal.append("URL da fonte original ausente")
    elif not re.match(r"^https?://", source_url):
        fatal.append("URL da fonte inválida")
    if data.get("end") and end is None:
        fatal.append(f"data de término inválida: {data.get('end')!r}")
    if start and end and end < start:
        fatal.append("data de término anterior ao início")
    if start and not (datetime(2000, 1, 1, tzinfo=timezone.utc) <= start <= now + timedelta(days=3 * 365)):
        fatal.append("data de início fora do intervalo plausível")
    if fatal:
        raise EventValidationError(fatal)

    lat, lng = _to_float(data.get("latitude")), _to_float(data.get("longitude"))
    if (lat is None) != (lng is None):
        issues.append("coordenada incompleta descartada")
        lat = lng = None
    if lat is not None and lng is not None:
        if not (-90 <= lat <= 90 and -180 <= lng <= 180) or (lat == 0 and lng == 0):
            issues.append("coordenadas inválidas descartadas")
            lat = lng = None
        elif not (TO_BBOX["lat_min"] <= lat <= TO_BBOX["lat_max"] and TO_BBOX["lng_min"] <= lng <= TO_BBOX["lng_max"]):
            issues.append("coordenadas fora do Tocantins descartadas")
            lat = lng = None

    category = slugify(data.get("category") or "") or None
    if category and category not in EVENT_CATEGORIES:
        issues.append(f"categoria '{category}' não reconhecida; classificada por palavras-chave")
        category = None
    if category is None:
        category = guess_event_category(name, data.get("description") or "")
        if category:
            issues.append("categoria inferida por palavras-chave")
        else:
            issues.append("categoria não identificada")

    state = (data.get("state") or "").strip().upper()[:2] or None
    published, _ = parse_datetime(data.get("published_at"))

    optional = {
        "description": data.get("description"),
        "category": category,
        "venue": data.get("venue"),
        "address": data.get("address"),
        "coordinates": lat,
        "organizer": data.get("organizer"),
        "price": data.get("price_text") or _to_bool(data.get("is_free")) is not None,
        "published_at": published,
    }
    filled = sum(1 for v in optional.values() if v)
    quality = round(0.5 + 0.5 * filled / len(optional), 2)
    fp = make_fingerprint(name, start, municipality)
    validation = "valido" if category and (data.get("venue") or data.get("address")) else "incompleto"
    if validation == "incompleto":
        issues.append("registro incompleto (categoria ou local ausente)")

    return NormalizedEvent(
        external_id=str(data.get("external_id") or fp),
        fingerprint=fp,
        name=name[:300],
        description=(data.get("description") or None),
        category=category,
        theme=EVENT_CATEGORIES.get(category) if category else None,
        start_at=start,
        end_at=end,
        has_time=has_time,
        venue=(data.get("venue") or None),
        municipality=municipality,
        state=state or ("TO" if normalize_text(municipality) == "palmas" else None),
        address=(data.get("address") or None),
        latitude=lat,
        longitude=lng,
        organizer=(data.get("organizer") or None),
        price_text=(str(data.get("price_text")) if data.get("price_text") not in (None, "") else None),
        is_free=_to_bool(data.get("is_free")),
        source_url=source_url,
        published_at=published,
        cancelled=bool(_to_bool(data.get("cancelled"))),
        issues=issues,
        quality_score=quality,
        validation_status=validation,
    )


def event_status(start: datetime, end: datetime | None, cancelled: bool, has_time: bool, now: datetime | None = None) -> str:
    now = now or datetime.now(timezone.utc)
    if cancelled:
        return "cancelado"
    start = start if start.tzinfo else start.replace(tzinfo=timezone.utc)
    if end is not None:
        end = end if end.tzinfo else end.replace(tzinfo=timezone.utc)
    else:
        local_start = start.astimezone(TZ_TO)
        end = datetime.combine(local_start.date(), time.max, tzinfo=TZ_TO) if not has_time else start + timedelta(hours=4)
    if now < start:
        return "futuro"
    if now <= end:
        return "em_andamento"
    return "encerrado"


# Aliases de colunas para importação CSV (pt-BR)
CSV_ALIASES = {
    "nome": "name", "titulo": "name", "descricao": "description", "categoria": "category",
    "inicio": "start", "data_inicio": "start", "fim": "end", "data_fim": "end", "termino": "end",
    "local": "venue", "municipio": "municipality", "cidade": "municipality", "uf": "state", "estado": "state",
    "endereco": "address", "lat": "latitude", "lng": "longitude", "lon": "longitude",
    "organizador": "organizer", "preco": "price_text", "gratuito": "is_free", "url": "source_url",
    "url_fonte": "source_url", "publicado_em": "published_at", "data_publicacao": "published_at",
    "id_externo": "external_id", "cancelado": "cancelled",
}


def map_csv_row(row: dict[str, Any]) -> dict[str, Any]:
    out: dict[str, Any] = {}
    for k, v in row.items():
        if k is None:
            continue
        key = slugify(k)
        out[CSV_ALIASES.get(key, key)] = v.strip() if isinstance(v, str) else v
    return out
