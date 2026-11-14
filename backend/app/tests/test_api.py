from __future__ import annotations

import uuid

from fastapi.testclient import TestClient

from app.main import app


def test_health() -> None:
    with TestClient(app) as client:
        response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_dashboard_summary() -> None:
    with TestClient(app) as client:
        response = client.get("/api/dashboard/summary")
    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "ok"
    assert "summary" in payload


def test_trends_csv_import() -> None:
    suffix = uuid.uuid4().hex[:8]
    csv_bytes = (
        f"Semana,festival gastron\xf4mico demo {suffix}: (Tocantins),shows demo {suffix}: (Tocantins)\n"
        "2025-11-09,12,40\n"
        "2025-11-16,<1,38\n"
    ).encode("utf-8")
    with TestClient(app) as client:
        response = client.post(
            "/api/trends/import",
            files={"file": ("sample.csv", csv_bytes, "text/csv")},
            data={"geo": "BR-TO"},
        )
    assert response.status_code == 200, response.text
    payload = response.json()
    assert payload["status"] == "ok"
    assert payload["result"]["points_saved"] > 0
