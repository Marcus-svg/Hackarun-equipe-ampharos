"""Taxonomia comum que permite cruzar Trends, Places, eventos e totem.

Cada fonte tem suas próprias categorias; aqui elas são mapeadas para *temas*
canônicos de oportunidade. Os mapeamentos são explícitos e auditáveis.
"""
from __future__ import annotations

import re
import unicodedata
from enum import StrEnum


class DataStatus(StrEnum):
    """Natureza do dado. Obrigatório em toda observação."""

    REAL = "real"                    # coletado automaticamente de fonte oficial
    MANUAL_IMPORT = "manual_import"  # importado manualmente de fonte pública
    ESTIMATED = "estimado"           # derivado/estimado por cálculo
    SIMULATED = "simulado"           # dado fictício (nunca usado como evidência)
    UNAVAILABLE = "indisponivel"     # fonte consultada, dado não disponível


class ValidationStatus(StrEnum):
    VALID = "valido"
    INCOMPLETE = "incompleto"
    INVALID = "invalido"
    STALE = "desatualizado"
    PENDING = "pendente"


# Temas canônicos de oportunidade
THEMES: dict[str, str] = {
    "gastronomia": "Gastronomia",
    "musica": "Música",
    "entretenimento": "Entretenimento",
    "cultura": "Cultura",
    "cultura_geek": "Cultura geek",
    "familia_infancia": "Família e infância",
    "esportes_bem_estar": "Esportes e bem-estar",
    "tecnologia": "Tecnologia",
    "feiras_exposicoes": "Feiras e exposições",
    "institucional": "Eventos institucionais",
    "moda": "Moda",
}

# Categorias de eventos (prompt §7) -> tema
EVENT_CATEGORIES: dict[str, str] = {
    "gastronomia": "gastronomia",
    "musica": "musica",
    "cultura": "cultura",
    "tecnologia": "tecnologia",
    "cultura_geek": "cultura_geek",
    "esportes": "esportes_bem_estar",
    "entretenimento": "entretenimento",
    "infantil": "familia_infancia",
    "feiras_exposicoes": "feiras_exposicoes",
    "institucional": "institucional",
}

# Categorias do totem (Flutter) -> tema
TOTEM_CATEGORIES: dict[str, str] = {
    "gastronomia": "gastronomia",
    "musica": "musica",
    "entretenimento": "entretenimento",
    "tecnologia": "tecnologia",
    "moda": "moda",
    "cultura": "cultura",
    "esportes": "esportes_bem_estar",
}

# Termos monitorados no Google Trends: termo -> (grupo, tema)
TREND_TERMS: dict[str, tuple[str, str]] = {
    "festival gastronômico": ("gastronomia", "gastronomia"),
    "feira gastronômica": ("gastronomia", "gastronomia"),
    "comida regional": ("gastronomia", "gastronomia"),
    "degustação": ("gastronomia", "gastronomia"),
    "shows": ("musica_entretenimento", "musica"),
    "música ao vivo": ("musica_entretenimento", "musica"),
    "festival de música": ("musica_entretenimento", "musica"),
    "cinema": ("musica_entretenimento", "entretenimento"),
    "entretenimento": ("musica_entretenimento", "entretenimento"),
    "cultura geek": ("cultura_lazer", "cultura_geek"),
    "anime": ("cultura_lazer", "cultura_geek"),
    "cosplay": ("cultura_lazer", "cultura_geek"),
    "feira de artesanato": ("cultura_lazer", "cultura"),
    "eventos culturais": ("cultura_lazer", "cultura"),
    "programação infantil": ("familia_infancia", "familia_infancia"),
    "recreação infantil": ("familia_infancia", "familia_infancia"),
    "eventos para famílias": ("familia_infancia", "familia_infancia"),
    "oficinas infantis": ("familia_infancia", "familia_infancia"),
    "corrida de rua": ("esportes_bem_estar", "esportes_bem_estar"),
    "atividades esportivas": ("esportes_bem_estar", "esportes_bem_estar"),
    "dança": ("esportes_bem_estar", "esportes_bem_estar"),
    "bem-estar": ("esportes_bem_estar", "esportes_bem_estar"),
}

TREND_GROUPS: dict[str, str] = {
    "gastronomia": "Gastronomia",
    "musica_entretenimento": "Música e entretenimento",
    "cultura_lazer": "Cultura e lazer",
    "familia_infancia": "Família e infância",
    "esportes_bem_estar": "Esportes e bem-estar",
}

# Categorias de estabelecimentos (Places) -> consulta textual e tipos Google
PLACE_CATEGORIES: dict[str, dict] = {
    "shopping": {"label": "Shoppings", "query": "shopping center", "theme": None},
    "restaurante": {"label": "Restaurantes", "query": "restaurante", "theme": "gastronomia"},
    "entretenimento": {"label": "Espaços de entretenimento", "query": "espaço de entretenimento", "theme": "entretenimento"},
    "cinema": {"label": "Cinemas", "query": "cinema", "theme": "entretenimento"},
    "centro_cultural": {"label": "Centros culturais", "query": "centro cultural", "theme": "cultura"},
    "parque": {"label": "Parques", "query": "parque", "theme": "esportes_bem_estar"},
    "lazer": {"label": "Espaços de lazer", "query": "espaço de lazer", "theme": "familia_infancia"},
    "local_eventos": {"label": "Locais de eventos", "query": "espaço de eventos", "theme": None},
    "gastronomico": {"label": "Espaços gastronômicos", "query": "espaço gastronômico food park", "theme": "gastronomia"},
}

# Geografias aceitas para séries temporais do Trends. Palmas não é selecionável
# como região de série temporal no Trends para o Brasil; o menor recorte
# disponível é o estado (BR-TO), usado como proxy regional e assim rotulado.
TREND_GEOS: dict[str, dict] = {
    "BR-TO": {
        "label": "Tocantins",
        "level": "estado",
        "limitation": (
            "Recorte estadual (Tocantins). Palmas não é selecionável como região de série "
            "temporal no Google Trends; usado como proxy regional, não como indicador municipal."
        ),
    },
    "BR": {
        "label": "Brasil",
        "level": "pais",
        "limitation": "Indicador nacional: apenas contexto comparativo; não representa Palmas nem o Tocantins.",
    },
}


def normalize_text(value: str) -> str:
    """Minúsculas, sem acentos, só alfanuméricos e espaços simples."""
    value = unicodedata.normalize("NFKD", value or "")
    value = "".join(c for c in value if not unicodedata.combining(c)).lower()
    value = re.sub(r"[^a-z0-9]+", " ", value)
    return re.sub(r"\s+", " ", value).strip()


def slugify(value: str) -> str:
    return normalize_text(value).replace(" ", "_")


_TREND_TERMS_NORM = {normalize_text(k): k for k in TREND_TERMS}


def lookup_trend_term(term: str) -> tuple[str, str, str] | None:
    """Retorna (termo_canonico, grupo, tema) ou None."""
    key = _TREND_TERMS_NORM.get(normalize_text(term))
    if key is None:
        return None
    group, theme = TREND_TERMS[key]
    return key, group, theme


def totem_category_to_theme(category: str) -> str | None:
    return TOTEM_CATEGORIES.get(slugify(category))


def event_category_to_theme(category: str) -> str | None:
    return EVENT_CATEGORIES.get(slugify(category))


# Palavras-chave para classificar eventos sem categoria explícita
EVENT_KEYWORDS: dict[str, list[str]] = {
    "cultura_geek": ["geek", "anime", "cosplay", "otaku", "games", "nerd", "k-pop", "kpop"],
    "gastronomia": ["gastronom", "food", "culinari", "degusta", "comida", "cerveja", "chef"],
    "musica": ["show", "musica", "festival de musica", "banda", "sertanej", "rock", "samba", "pagode", "forro", "concerto"],
    "infantil": ["infantil", "criança", "crianca", "kids", "familia"],
    "esportes": ["corrida", "maratona", "esporte", "futebol", "ciclismo", "beach", "volei", "danca", "yoga", "bem-estar"],
    "tecnologia": ["tecnologia", "hackathon", "startup", "inovacao", "programacao", "dev", "inteligencia artificial"],
    "feiras_exposicoes": ["feira", "exposicao", "expo", "salao", "mostra"],
    "cultura": ["teatro", "cultural", "artesanato", "literatura", "cinema", "museu", "danca"],
    "institucional": ["prefeitura", "governo", "audiencia publica", "conferencia", "seminario"],
    "entretenimento": ["stand up", "standup", "humor", "circo", "festa", "balada"],
}


def guess_event_category(*texts: str) -> str | None:
    blob = normalize_text(" ".join(t for t in texts if t))
    for category, words in EVENT_KEYWORDS.items():
        for w in words:
            if normalize_text(w) in blob:
                return category
    return None
