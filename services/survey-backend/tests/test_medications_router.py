from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.main import app
from app.persistence.deps import get_reference_medication_repo

client = TestClient(app)


def _override_repo(repo: MagicMock) -> None:
    app.dependency_overrides[get_reference_medication_repo] = lambda: repo


def test_list_medications_returns_catalog() -> None:
    repo = MagicMock()
    repo.list_all.return_value = [
        MagicMock(substance="Fluoxetina", category="ansiolítico", trade_names=[]),
    ]
    _override_repo(repo)

    response = client.get("/api/v1/medications")

    assert response.status_code == 200
    assert response.json() == {
        "results": [
            {
                "substance": "Fluoxetina",
                "category": "ansiolítico",
                "trade_names": [],
            }
        ]
    }
    app.dependency_overrides = {}


def test_upsert_manual_medication_returns_item() -> None:
    repo = MagicMock()
    repo.upsert_manual.return_value = MagicMock(
        substance="Medicação livre",
        category="manual",
        trade_names=[],
    )
    _override_repo(repo)

    response = client.post(
        "/api/v1/medications/manual",
        json={"substance": "Medicação livre"},
    )

    assert response.status_code == 200
    assert response.json() == {
        "substance": "Medicação livre",
        "category": "manual",
        "trade_names": [],
    }
    repo.upsert_manual.assert_called_once_with("Medicação livre")
    app.dependency_overrides = {}
