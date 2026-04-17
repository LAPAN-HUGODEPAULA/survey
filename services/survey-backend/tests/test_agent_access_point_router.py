from datetime import datetime, timezone
from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.main import app
from app.persistence.deps import (
    get_agent_access_point_repo,
    get_persona_skill_repo,
    get_survey_prompt_repo,
    get_survey_repo,
)


client = TestClient(app)


def _override_dependencies(
    *,
    access_point_repo: MagicMock,
    survey_repo: MagicMock | None = None,
    prompt_repo: MagicMock | None = None,
    persona_repo: MagicMock | None = None,
) -> None:
    app.dependency_overrides[require_builder_admin] = lambda: None
    app.dependency_overrides[require_builder_csrf] = lambda: None
    app.dependency_overrides[get_agent_access_point_repo] = lambda: access_point_repo
    app.dependency_overrides[get_survey_repo] = lambda: survey_repo or MagicMock()
    app.dependency_overrides[get_survey_prompt_repo] = lambda: prompt_repo or MagicMock()
    app.dependency_overrides[get_persona_skill_repo] = lambda: persona_repo or MagicMock()


def _access_point_doc() -> dict:
    timestamp = datetime.now(timezone.utc).isoformat()
    return {
        "accessPointKey": "survey_patient.thank_you.auto_analysis",
        "name": "Patient Thank You",
        "sourceApp": "survey-patient",
        "flowKey": "thank_you.auto_analysis",
        "surveyId": "survey-1",
        "promptKey": "clinical_diagnostic_report:test-survey",
        "personaSkillKey": "patient_condition_overview",
        "outputProfile": "patient_condition_overview",
        "createdAt": timestamp,
        "modifiedAt": timestamp,
    }


def test_list_agent_access_points():
    repo = MagicMock()
    repo.list_all.return_value = [_access_point_doc()]
    _override_dependencies(access_point_repo=repo)

    response = client.get("/api/v1/agent_access_points/")

    assert response.status_code == 200
    assert response.json()[0]["accessPointKey"] == "survey_patient.thank_you.auto_analysis"
    app.dependency_overrides = {}


def test_create_agent_access_point_validates_bindings():
    repo = MagicMock()
    repo.create.return_value = _access_point_doc()
    survey_repo = MagicMock()
    survey_repo.get_by_id.return_value = {"_id": "survey-1"}
    prompt_repo = MagicMock()
    prompt_repo.get_by_key.return_value = {
        "promptKey": "clinical_diagnostic_report:test-survey",
        "name": "Test prompt",
    }
    persona_repo = MagicMock()
    persona_repo.get_by_key.return_value = {
        "personaSkillKey": "patient_condition_overview",
        "outputProfile": "patient_condition_overview",
    }
    persona_repo.get_by_output_profile.return_value = {
        "personaSkillKey": "patient_condition_overview",
        "outputProfile": "patient_condition_overview",
    }
    _override_dependencies(
        access_point_repo=repo,
        survey_repo=survey_repo,
        prompt_repo=prompt_repo,
        persona_repo=persona_repo,
    )

    response = client.post(
        "/api/v1/agent_access_points/",
        json={
            "accessPointKey": "survey_patient.thank_you.auto_analysis",
            "name": "Patient Thank You",
            "sourceApp": "survey-patient",
            "flowKey": "thank_you.auto_analysis",
            "surveyId": "survey-1",
            "promptKey": "clinical_diagnostic_report:test-survey",
            "personaSkillKey": "patient_condition_overview",
            "outputProfile": "patient_condition_overview",
        },
    )

    assert response.status_code == 201
    assert response.json()["sourceApp"] == "survey-patient"
    app.dependency_overrides = {}


def test_create_agent_access_point_rejects_missing_prompt():
    repo = MagicMock()
    survey_repo = MagicMock()
    survey_repo.get_by_id.return_value = {"_id": "survey-1"}
    prompt_repo = MagicMock()
    prompt_repo.get_by_key.return_value = None
    persona_repo = MagicMock()
    persona_repo.get_by_key.return_value = {
        "personaSkillKey": "patient_condition_overview",
        "outputProfile": "patient_condition_overview",
    }
    persona_repo.get_by_output_profile.return_value = {
        "personaSkillKey": "patient_condition_overview",
        "outputProfile": "patient_condition_overview",
    }
    _override_dependencies(
        access_point_repo=repo,
        survey_repo=survey_repo,
        prompt_repo=prompt_repo,
        persona_repo=persona_repo,
    )

    response = client.post(
        "/api/v1/agent_access_points/",
        json={
            "accessPointKey": "survey_patient.thank_you.auto_analysis",
            "name": "Patient Thank You",
            "sourceApp": "survey-patient",
            "flowKey": "thank_you.auto_analysis",
            "surveyId": "survey-1",
            "promptKey": "missing",
            "personaSkillKey": "patient_condition_overview",
            "outputProfile": "patient_condition_overview",
        },
    )

    assert response.status_code == 422
    assert response.json()["userMessage"] == "Unknown promptKey: missing"
    app.dependency_overrides = {}
