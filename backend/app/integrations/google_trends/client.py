"""Leitura do CSV oficial exportado pela interface do Google Trends.

Por que CSV? A API oficial do Google Trends está em alpha com acesso restrito
(candidatura). Bibliotecas como ``pytrends`` usam endpoints não documentados e
não são utilizadas. O botão "Download CSV" da interface é um recurso oficial; o
arquivo é importado de forma controlada, com metadados de geografia e período.

Formatos suportados (cabeçalhos em PT ou EN)::

    Categoria: Todas as categorias
    <linha vazia>
    Semana,festival gastronômico: (Tocantins),shows: (Tocantins)
    2025-11-09,12,40
    2025-11-16,<1,38

ou simplesmente ``Time,termo1,termo2`` / ``Mês,termo``.
"""
from __future__ import annotations

import csv
import io
import re
from dataclasses import dataclass, field
from datetime import date, datetime

DATE_HEADERS = {"semana", "week", "mes", "mês", "month", "dia", "day", "data", "date", "time", "tempo", "hora"}


class TrendsCsvError(ValueError):
    pass


@dataclass
class TrendPoint:
    term: str
    period_date: date
    value: float
    raw: str
    below_one: bool


@dataclass
class TrendsCsv:
    terms: list[str]
    header_geo_labels: dict[str, str | None]
    granularity: str
    points: list[TrendPoint] = field(default_factory=list)
    skipped_cells: int = 0


def _parse_date(value: str) -> date | None:
    v = value.strip()
    if not v:
        return None
    # Intervalos ("2025-11-09 - 2025-11-15"): usa o início
    v = re.split(r"\s+[-–]\s+", v)[0].strip()
    for fmt in ("%Y-%m-%d", "%Y-%m", "%d/%m/%Y", "%m/%Y", "%Y-%m-%dT%H", "%Y-%m-%dT%H:%M:%S"):
        try:
            d = datetime.strptime(v, fmt)
            return d.date()
        except ValueError:
            continue
    return None


def _parse_value(raw: str) -> tuple[float, bool] | None:
    v = raw.strip()
    if v == "":
        return None
    if v.startswith("<"):
        # "<1": interesse abaixo de 1 na escala relativa. Registrado como 0 + flag.
        return 0.0, True
    try:
        return float(v.replace(",", ".")), False
    except ValueError:
        return None


def _split_header(cell: str) -> tuple[str, str | None]:
    cell = cell.strip()
    if ":" in cell:
        term, geo = cell.rsplit(":", 1)
        geo = geo.strip().strip("()").strip() or None
        return term.strip(), geo
    return cell, None


def _infer_granularity(dates: list[date]) -> str:
    if len(dates) < 2:
        return "unknown"
    deltas = sorted((b - a).days for a, b in zip(dates, dates[1:]))
    median = deltas[len(deltas) // 2]
    if median <= 1:
        return "day"
    if median <= 8:
        return "week"
    return "month"


def parse_trends_csv(content: bytes | str) -> TrendsCsv:
    text = content.decode("utf-8-sig") if isinstance(content, bytes) else content.lstrip("\ufeff")
    sample = text[:2048]
    try:
        dialect = csv.Sniffer().sniff(sample, delimiters=",;\t")
    except csv.Error:
        dialect = csv.excel
    rows = [r for r in csv.reader(io.StringIO(text), dialect)]

    header_idx = None
    for i, row in enumerate(rows):
        if len(row) < 2:
            continue
        first = row[0].strip().lower()
        nxt = next((r for r in rows[i + 1 :] if r and any(c.strip() for c in r)), None)
        if first in DATE_HEADERS or (nxt and _parse_date(nxt[0]) and not _parse_date(row[0])):
            header_idx = i
            break
    if header_idx is None:
        raise TrendsCsvError("Cabeçalho de série temporal não encontrado no CSV do Google Trends.")

    header = rows[header_idx]
    terms: list[str] = []
    geos: dict[str, str | None] = {}
    for cell in header[1:]:
        term, geo = _split_header(cell)
        if not term:
            continue
        terms.append(term)
        geos[term] = geo
    if not terms:
        raise TrendsCsvError("Nenhum termo encontrado no cabeçalho.")

    points: list[TrendPoint] = []
    dates: list[date] = []
    skipped = 0
    for row in rows[header_idx + 1 :]:
        if not row or not row[0].strip():
            continue
        d = _parse_date(row[0])
        if d is None:
            skipped += 1
            continue
        dates.append(d)
        for term, cell in zip(terms, row[1:]):
            parsed = _parse_value(cell)
            if parsed is None:
                skipped += 1
                continue
            val, below = parsed
            if not 0 <= val <= 100:
                skipped += 1
                continue
            points.append(TrendPoint(term=term, period_date=d, value=val, raw=cell.strip(), below_one=below))
    if not points:
        raise TrendsCsvError("CSV sem pontos válidos.")
    return TrendsCsv(
        terms=terms,
        header_geo_labels=geos,
        granularity=_infer_granularity(sorted(set(dates))),
        points=points,
        skipped_cells=skipped,
    )
