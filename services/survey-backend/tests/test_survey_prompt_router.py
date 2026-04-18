from datetime import datetime, timezone
from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.main import app
from app.persistence.deps import get_survey_prompt_repo


client = TestClient(app)


def _override_prompt_repo(mock_repo: MagicMock) -> None:
    app.dependency_overrides[require_builder_admin] = lambda: None
    app.dependency_overrides[require_builder_csrf] = lambda: None
    app.dependency_overrides[get_survey_prompt_repo] = lambda: mock_repo


def _prompt_doc() -> dict:
    return {
        "promptKey": "clinical_referral_letter:lapan7",
        "name": "Encaminhamento clínico",
        "promptText": "Escreva um encaminhamento clínico.",
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "modifiedAt": datetime.now(timezone.utc).isoformat(),
    }


def test_list_survey_prompts():
    mock_repo = MagicMock()
    mock_repo.list_all.return_value = [_prompt_doc()]
    _override_prompt_repo(mock_repo)

    response = client.get("/api/v1/survey_prompts/")

    assert response.status_code == 200
    assert response.json()[0]["promptKey"] == "clinical_referral_letter:lapan7"
    app.dependency_overrides = {}


def test_create_survey_prompt():
    mock_repo = MagicMock()
    mock_repo.create.return_value = _prompt_doc()
    _override_prompt_repo(mock_repo)

    response = client.post(
        "/api/v1/survey_prompts/",
        json={
            "promptKey": "clinical_referral_letter:lapan7",
            "name": "Encaminhamento clínico",
            "promptText": "Escreva um encaminhamento clínico.",
        },
    )

    assert response.status_code == 201
    assert response.json()["promptKey"] == "clinical_referral_letter:lapan7"
    app.dependency_overrides = {}


def test_create_survey_prompt_rejects_legacy_outcome_type():
    mock_repo = MagicMock()
    _override_prompt_repo(mock_repo)

    response = client.post(
        "/api/v1/survey_prompts/",
        json={
            "promptKey": "clinical_referral_letter:lapan7",
            "name": "Encaminhamento clínico",
            "outcomeType": "clinical_referral_letter",
            "promptText": "Escreva um encaminhamento clínico.",
        },
    )

    assert response.status_code == 422
    app.dependency_overrides = {}


def test_delete_survey_prompt_rejects_in_use():
    mock_repo = MagicMock()
    mock_repo.get_by_key.return_value = _prompt_doc()
    mock_repo.is_in_use.return_value = True
    _override_prompt_repo(mock_repo)

    response = client.delete("/api/v1/survey_prompts/clinical_referral_letter:lapan7")

    assert response.status_code == 409
    assert response.json()["userMessage"] == "Survey prompt is still associated with a questionnaire"
    app.dependency_overrides = {}
