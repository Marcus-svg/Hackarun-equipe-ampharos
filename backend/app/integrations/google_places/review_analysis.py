"""Análise transparente de avaliações (sem IA generativa).

- Polaridade: derivada da nota em estrelas da própria avaliação
  (>=4 positiva, 3 neutra, <=2 negativa). Critério simples e auditável.
- Temas: correspondência de palavras-chave (léxico abaixo) no texto normalizado.
- Amostra: a Places API devolve no máximo 5 avaliações, selecionadas por
  relevância pelo Google. Resultados NÃO representam a opinião geral.
"""
from __future__ import annotations

from app.core.taxonomy import normalize_text

MIN_REVIEWS_FOR_SENTIMENT = 3

REVIEW_THEMES: dict[str, list[str]] = {
    "estacionamento": ["estacionamento", "vaga", "vagas", "estacionar"],
    "atendimento": ["atendimento", "atendente", "funcionario", "funcionarios", "educado", "simpatic"],
    "limpeza": ["limpeza", "limpo", "limpos", "sujo", "banheiro", "banheiros"],
    "preco": ["preco", "precos", "caro", "cara", "barato", "valor"],
    "alimentacao": ["praca de alimentacao", "comida", "restaurante", "lanchonete", "gastronom", "alimentacao"],
    "cinema_lazer": ["cinema", "filme", "lazer", "diversao", "brinquedo", "parque"],
    "eventos_atracoes": ["evento", "eventos", "show", "shows", "atracao", "atracoes", "programacao", "feira"],
    "familia_criancas": ["crianca", "criancas", "familia", "infantil", "kids"],
    "conforto_climatizacao": ["climatizado", "ar condicionado", "confortavel", "conforto", "calor", "frio"],
    "seguranca": ["seguranca", "seguro", "segura", "policiamento"],
    "lojas_variedade": ["loja", "lojas", "variedade", "opcoes", "marcas"],
    "acessibilidade": ["acessibilidade", "acessivel", "cadeirante", "elevador", "rampa"],
    "lotacao_filas": ["lotado", "cheio", "fila", "filas", "movimentado"],
}


def polarity_from_rating(rating: float | None) -> str | None:
    if rating is None:
        return None
    if rating >= 4:
        return "positiva"
    if rating <= 2:
        return "negativa"
    return "neutra"


def analyze_reviews(reviews: list[dict]) -> dict:
    sentiment = {"positiva": 0, "neutra": 0, "negativa": 0}
    themes: dict[str, dict[str, int]] = {}
    analyzed = 0
    for r in reviews or []:
        text = ((r.get("text") or {}).get("text")) or ((r.get("originalText") or {}).get("text")) or ""
        pol = polarity_from_rating(r.get("rating"))
        if pol is None:
            continue
        analyzed += 1
        sentiment[pol] += 1
        norm = f" {normalize_text(text)} "
        for theme, words in REVIEW_THEMES.items():
            if any(f" {normalize_text(w)}" in norm for w in words):
                bucket = themes.setdefault(theme, {"positiva": 0, "neutra": 0, "negativa": 0, "total": 0})
                bucket[pol] += 1
                bucket["total"] += 1
    return {
        "sample_size": analyzed,
        "sentiment_counts": sentiment,
        "themes": themes,
        "sufficient_for_sentiment": analyzed >= MIN_REVIEWS_FOR_SENTIMENT,
        "method": "polaridade pela nota em estrelas; temas por palavras-chave",
        "limitation": (
            "Amostra de no máximo 5 avaliações selecionadas por relevância pelo Google; "
            "não representa a opinião geral dos visitantes."
        ),
    }
