from datetime import datetime, timezone
from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.main import app
from app.persistence.deps import get_persona_skill_repo


client = TestClient(app)


def _override_persona_repo(mock_repo: MagicMock) -> None:
    app.dependency_overrides[require_builder_admin] = lambda: None
    app.dependency_overrides[require_builder_csrf] = lambda: None
    app.dependency_overrides[get_persona_skill_repo] = lambda: mock_repo


def _persona_doc() -> dict:
    return {
        "personaSkillKey": "school_report",
        "name": "School Report Persona",
        "outputProfile": "school_report",
        "instructions": "Use formal school-facing language.",
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "modifiedAt": datetime.now(timezone.utc).isoformat(),
    }


def test_list_persona_skills():
    mock_repo = MagicMock()
    mock_repo.list_all.return_value = [_persona_doc()]
    _override_persona_repo(mock_repo)

    response = client.get("/api/v1/persona_skills/")

    assert response.status_code == 200
    assert response.json()[0]["personaSkillKey"] == "school_report"
    app.dependency_overrides = {}


def test_create_persona_skill():
    mock_repo = MagicMock()
    mock_repo.create.return_value = _persona_doc()
    _override_persona_repo(mock_repo)

    response = client.post(
        "/api/v1/persona_skills/",
        json={
            "personaSkillKey": "school_report",
            "name": "School Report Persona",
            "outputProfile": "school_report",
            "instructions": "Use formal school-facing language.",
        },
    )

    assert response.status_code == 201
    assert response.json()["personaSkillKey"] == "school_report"
    app.dependency_overrides = {}
