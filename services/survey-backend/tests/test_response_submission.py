from datetime import datetime, timezone
from unittest.mock import MagicMock

import pytest

from app.domain.models.agent_response_model import AgentResponse
from app.domain.models.screener_access_link_model import ScreenerAccessLinkModel
from app.domain.models.survey_response_model import SurveyResponse
from app.services.response_submission import (
    PatientSubmissionOrchestrator,
    SurveySubmissionOrchestrator,
)


def _survey_response(**overrides) -> SurveyResponse:
    payload = {
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
    payload.update(overrides)
    return SurveyResponse(**payload)


@pytest.mark.asyncio
async def test_patient_submission_orchestrator_defers_thank_you_access_point() -> None:
    response_repo = MagicMock()
    response_repo.create.return_value = {"_id": "response-1"}
    survey_repo = MagicMock()
    survey_repo.get_by_id.return_value = {"_id": "survey-1"}
    persona_repo = MagicMock()
    persona_repo.get_by_key.return_value = None
    persona_repo.get_by_output_profile.return_value = None
    access_point_repo = MagicMock()
    access_point_repo.get_by_key.return_value = {
        "accessPointKey": "survey_patient.thank_you.auto_analysis",
        "promptKey": "resolved-prompt",
    }
    access_point_repo.list_for_runtime.return_value = []
    system_settings_repo = MagicMock()
    system_settings_repo.get_json.return_value = None

    async def _unexpected_agent_runner(*args, **kwargs):
        raise AssertionError("Deferred patient flow must not call the agent inline")

    orchestrator = PatientSubmissionOrchestrator(
        response_repo=response_repo,
        survey_repo=survey_repo,
        persona_repo=persona_repo,
        access_point_repo=access_point_repo,
        system_settings_repo=system_settings_repo,
        agent_runner=_unexpected_agent_runner,
    )

    result = await orchestrator.submit(
        _survey_response(accessPointKey="survey_patient.thank_you.auto_analysis")
    )

    assert result.agent_response is None
    assert result.agent_responses == []
    response_repo.update_fields.assert_not_called()


@pytest.mark.asyncio
async def test_survey_submission_orchestrator_persists_agent_artifacts() -> None:
    response_repo = MagicMock()
    response_repo.create.return_value = {"_id": "response-1"}
    survey_repo = MagicMock()
    survey_repo.get_by_id.return_value = {"_id": "survey-1"}
    persona_repo = MagicMock()
    persona_repo.get_by_key.return_value = None
    persona_repo.get_by_output_profile.return_value = None
    access_point_repo = MagicMock()
    access_point_repo.get_by_key.return_value = {
        "accessPointKey": "survey_frontend.inline.analysis",
        "promptKey": "resolved-prompt",
    }
    access_point_repo.list_for_runtime.return_value = []
    system_settings_repo = MagicMock()
    system_settings_repo.get_json.return_value = None
    access_link_repo = MagicMock()
    screener_repo = MagicMock()

    async def _agent_runner(*args, **kwargs):
        return AgentResponse(ok=True, medicalRecord="Resumo clínico")

    orchestrator = SurveySubmissionOrchestrator(
        response_repo=response_repo,
        survey_repo=survey_repo,
        persona_repo=persona_repo,
        access_point_repo=access_point_repo,
        system_settings_repo=system_settings_repo,
        access_link_repo=access_link_repo,
        screener_repo=screener_repo,
        agent_runner=_agent_runner,
    )

    result = await orchestrator.submit(
        _survey_response(accessPointKey="survey_frontend.inline.analysis")
    )

    assert result.agent_response is not None
    assert result.agent_response.medical_record == "Resumo clínico"
    response_repo.update_fields.assert_called_once()
    updated_fields = response_repo.update_fields.call_args.args[1]
    assert updated_fields["agentResponse"]["medicalRecord"] == "Resumo clínico"
    assert updated_fields["agentResponses"][0]["medicalRecord"] == "Resumo clínico"


@pytest.mark.asyncio
async def test_survey_submission_orchestrator_uses_access_link_override() -> None:
    response_repo = MagicMock()
    response_repo.create.return_value = {"_id": "response-1"}
    survey_repo = MagicMock()
    survey_repo.get_by_id.side_effect = [
        {"_id": "survey-1"},
        {"_id": "survey-1"},
    ]
    persona_repo = MagicMock()
    persona_repo.get_by_key.return_value = None
    persona_repo.get_by_output_profile.return_value = None
    access_point_repo = MagicMock()
    access_point_repo.get_by_key.return_value = None
    access_point_repo.list_for_runtime.return_value = []
    system_settings_repo = MagicMock()
    system_settings_repo.get_json.return_value = None
    access_link_repo = MagicMock()
    access_link_repo.find_by_token.return_value = ScreenerAccessLinkModel(
        _id="token-1",
        screenerId="linked-screener",
        screenerName="Ana",
        surveyId="linked-survey",
        surveyDisplayName="Survey",
        createdAt=datetime.now(timezone.utc),
    )
    screener_repo = MagicMock()
    screener_repo.find_by_id.return_value = {"_id": "linked-screener"}

    async def _agent_runner(*args, **kwargs):
        return AgentResponse(ok=True, medicalRecord="Resumo clínico")

    orchestrator = SurveySubmissionOrchestrator(
        response_repo=response_repo,
        survey_repo=survey_repo,
        persona_repo=persona_repo,
        access_point_repo=access_point_repo,
        system_settings_repo=system_settings_repo,
        access_link_repo=access_link_repo,
        screener_repo=screener_repo,
        agent_runner=_agent_runner,
    )

    result = await orchestrator.submit(
        _survey_response(
            surveyId="ignored-survey",
            screenerId="ignored-screener",
            accessLinkToken="token-1",
        )
    )

    created_payload = response_repo.create.call_args.args[0]
    assert created_payload["surveyId"] == "linked-survey"
    assert created_payload["screenerId"] == "linked-screener"
    assert result.survey_id == "linked-survey"
