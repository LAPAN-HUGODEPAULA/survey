from datetime import datetime, timezone
from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.main import app
from app.persistence.deps import (
    get_agent_access_point_repo,
    get_patient_response_repo,
    get_persona_skill_repo,
    get_screener_access_link_repo,
    get_screener_repo,
    get_survey_repo,
    get_survey_response_repo,
)


client = TestClient(app)


def _response_payload() -> dict:
    return {
        "surveyId": "survey-1",
        "creatorId": "creator-1",
        "testDate": datetime.now(timezone.utc).isoformat(),
        "screenerId": "screener-1",
        "patient": {
            "name": "Paciente",
            "email": "paciente@example.com",
            "birthDate": "1990-01-01",
            "gender": "F",
            "ethnicity": "Branca",
            "educationLevel": "Superior",
            "profession": "Docente",
            "medication": [],
            "diagnoses": [],
            "family_history": "",
            "social_history": "",
            "medical_history": "",
            "medication_history": "",
        },
        "answers": [{"id": 1, "answer": "A"}],
    }


def test_create_patient_response_returns_configuration_error_for_stale_persona():
    survey_repo = MagicMock()
    survey_repo.get_by_id.return_value = {
        "_id": "survey-1",
        "personaSkillKey": "deleted_persona",
    }
    persona_repo = MagicMock()
    persona_repo.get_by_key.return_value = None
    persona_repo.get_by_output_profile.return_value = None
    patient_response_repo = MagicMock()
    access_point_repo = MagicMock()
    access_point_repo.get_by_key.return_value = None
    access_point_repo.list_for_runtime.return_value = []

    app.dependency_overrides[get_survey_repo] = lambda: survey_repo
    app.dependency_overrides[get_persona_skill_repo] = lambda: persona_repo
    app.dependency_overrides[get_patient_response_repo] = lambda: patient_response_repo
    app.dependency_overrides[get_agent_access_point_repo] = lambda: access_point_repo

    response = client.post("/api/v1/patient_responses/", json=_response_payload())

    assert response.status_code == 400
    assert response.json()["userMessage"] == (
        "Survey default personaSkillKey references an unknown persona skill: deleted_persona"
    )
    app.dependency_overrides = {}


def test_create_survey_response_returns_configuration_error_for_stale_persona():
    survey_repo = MagicMock()
    survey_repo.get_by_id.return_value = {
        "_id": "survey-1",
        "personaSkillKey": "deleted_persona",
    }
    persona_repo = MagicMock()
    persona_repo.get_by_key.return_value = None
    persona_repo.get_by_output_profile.return_value = None
    survey_response_repo = MagicMock()
    access_link_repo = MagicMock()
    screener_repo = MagicMock()
    access_point_repo = MagicMock()
    access_point_repo.get_by_key.return_value = None
    access_point_repo.list_for_runtime.return_value = []

    app.dependency_overrides[get_survey_repo] = lambda: survey_repo
    app.dependency_overrides[get_persona_skill_repo] = lambda: persona_repo
    app.dependency_overrides[get_survey_response_repo] = lambda: survey_response_repo
    app.dependency_overrides[get_screener_access_link_repo] = lambda: access_link_repo
    app.dependency_overrides[get_screener_repo] = lambda: screener_repo
    app.dependency_overrides[get_agent_access_point_repo] = lambda: access_point_repo

    response = client.post("/api/v1/survey_responses/", json=_response_payload())

    assert response.status_code == 400
    assert response.json()["userMessage"] == (
        "Survey default personaSkillKey references an unknown persona skill: deleted_persona"
    )
    app.dependency_overrides = {}


def test_create_patient_response_uses_access_point_bindings(monkeypatch):
    survey_repo = MagicMock()
    survey_repo.get_by_id.return_value = {
        "_id": "survey-1",
        "prompt": {"promptKey": "survey-default", "name": "Default"},
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
    patient_response_repo = MagicMock()
    patient_response_repo.create.return_value = {"_id": "response-1"}
    access_point_repo = MagicMock()
    access_point_repo.get_by_key.return_value = {
        "accessPointKey": "survey_patient.thank_you.auto_analysis",
        "promptKey": "resolved-prompt",
        "personaSkillKey": "patient_condition_overview",
        "outputProfile": "patient_condition_overview",
    }
    access_point_repo.list_for_runtime.return_value = []

    async def _fake_agent(*args, **kwargs):
        return {
            "ok": True,
            "medicalRecord": "ok",
            "prompt_version": "v1",
        }

    monkeypatch.setattr("app.api.routes.patient_responses.send_to_langgraph_agent", _fake_agent)

    app.dependency_overrides[get_survey_repo] = lambda: survey_repo
    app.dependency_overrides[get_persona_skill_repo] = lambda: persona_repo
    app.dependency_overrides[get_patient_response_repo] = lambda: patient_response_repo
    app.dependency_overrides[get_agent_access_point_repo] = lambda: access_point_repo

    payload = _response_payload()
    payload["accessPointKey"] = "survey_patient.thank_you.auto_analysis"
    response = client.post("/api/v1/patient_responses/", json=payload)

    assert response.status_code == 201
    assert response.json()["promptKey"] == "resolved-prompt"
    assert response.json()["accessPointKey"] == "survey_patient.thank_you.auto_analysis"
    assert response.json()["agentResponse"]["medicalRecord"] == "ok"
    app.dependency_overrides = {}
