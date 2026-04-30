from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.main import app
from app.persistence.deps import get_survey_repo, get_system_settings_repo

client = TestClient(app)


def _override_dependencies(*, survey_repo: MagicMock, settings_repo: MagicMock) -> None:
    app.dependency_overrides[get_survey_repo] = lambda: survey_repo
    app.dependency_overrides[get_system_settings_repo] = lambda: settings_repo
    app.dependency_overrides[require_builder_admin] = lambda: None
    app.dependency_overrides[require_builder_csrf] = lambda: None


def _survey_doc(
    survey_id: str = "67f42f93c6d5fd1db95f7ca0",
    display_name: str = "CHYPS-V Br Q20",
) -> dict:
    return {
        "_id": survey_id,
        "surveyDisplayName": display_name,
        "surveyName": display_name,
    }


def test_get_screener_settings_returns_configured_default() -> None:
    survey_repo = MagicMock()
    settings_repo = MagicMock()
    settings_repo.get_value.return_value = "67f42f93c6d5fd1db95f7ca0"
    survey_repo.get_by_id.return_value = _survey_doc()
    _override_dependencies(survey_repo=survey_repo, settings_repo=settings_repo)

    response = client.get("/api/v1/settings/screener")

    assert response.status_code == 200
    assert response.json() == {
        "defaultQuestionnaireId": "67f42f93c6d5fd1db95f7ca0",
        "defaultQuestionnaireName": "CHYPS-V Br Q20",
    }
    settings_repo.set_value.assert_not_called()
    app.dependency_overrides = {}


def test_get_screener_settings_applies_chyps_fallback() -> None:
    survey_repo = MagicMock()
    settings_repo = MagicMock()
    settings_repo.get_value.return_value = None
    survey_repo.list_all.return_value = [
        _survey_doc("67f42f93c6d5fd1db95f7ca0", "CHYPS-V Br Q20"),
    ]
    _override_dependencies(survey_repo=survey_repo, settings_repo=settings_repo)

    response = client.get("/api/v1/settings/screener")

    assert response.status_code == 200
    assert response.json() == {
        "defaultQuestionnaireId": "67f42f93c6d5fd1db95f7ca0",
        "defaultQuestionnaireName": "CHYPS-V Br Q20",
    }
    settings_repo.set_value.assert_called_once_with(
        "screener_default_questionnaire_id",
        "67f42f93c6d5fd1db95f7ca0",
    )
    app.dependency_overrides = {}


def test_update_screener_settings_rejects_invalid_questionnaire() -> None:
    survey_repo = MagicMock()
    settings_repo = MagicMock()
    survey_repo.get_by_id.return_value = None
    _override_dependencies(survey_repo=survey_repo, settings_repo=settings_repo)

    response = client.put(
        "/api/v1/settings/screener",
        json={"defaultQuestionnaireId": "missing"},
    )

    assert response.status_code == 422
    assert response.json()["userMessage"] == "Unknown defaultQuestionnaireId: missing"
    settings_repo.set_value.assert_not_called()
    app.dependency_overrides = {}


def test_update_screener_settings_persists_default() -> None:
    survey_repo = MagicMock()
    settings_repo = MagicMock()
    survey_repo.get_by_id.side_effect = [
        _survey_doc("67f42f93c6d5fd1db95f7ca0", "CHYPS-V Br Q20"),
        _survey_doc("67f42f93c6d5fd1db95f7ca0", "CHYPS-V Br Q20"),
    ]
    settings_repo.get_value.return_value = "67f42f93c6d5fd1db95f7ca0"
    _override_dependencies(survey_repo=survey_repo, settings_repo=settings_repo)

    response = client.put(
        "/api/v1/settings/screener",
        json={"defaultQuestionnaireId": "67f42f93c6d5fd1db95f7ca0"},
    )

    assert response.status_code == 200
    assert response.json() == {
        "defaultQuestionnaireId": "67f42f93c6d5fd1db95f7ca0",
        "defaultQuestionnaireName": "CHYPS-V Br Q20",
    }
    settings_repo.set_value.assert_called_once_with(
        "screener_default_questionnaire_id",
        "67f42f93c6d5fd1db95f7ca0",
    )
    app.dependency_overrides = {}
