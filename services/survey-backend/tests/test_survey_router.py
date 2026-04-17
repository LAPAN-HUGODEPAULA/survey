from fastapi.testclient import TestClient
from unittest.mock import MagicMock

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.main import app
from app.persistence.deps import (
    get_persona_skill_repo,
    get_survey_prompt_repo,
    get_survey_repo,
)


client = TestClient(app)


def _override_builder_auth() -> None:
    app.dependency_overrides[require_builder_admin] = lambda: None
    app.dependency_overrides[require_builder_csrf] = lambda: None


def _override_survey_dependencies(
    mock_repo: MagicMock,
    mock_prompt_repo: MagicMock | None = None,
    mock_persona_repo: MagicMock | None = None,
) -> None:
    prompt_repo = mock_prompt_repo or MagicMock()
    persona_repo = mock_persona_repo or MagicMock()
    _override_builder_auth()
    app.dependency_overrides[get_survey_repo] = lambda: mock_repo
    app.dependency_overrides[get_survey_prompt_repo] = lambda: prompt_repo
    app.dependency_overrides[get_persona_skill_repo] = lambda: persona_repo


def _survey_doc(
    *,
    prompt: dict | None,
    persona_skill_key: str | None = None,
    output_profile: str | None = None,
    questions: list[dict] | None = None,
) -> dict:
    return {
        "_id": "60c728efd4c4a4f8b8c8d0d0",
        "surveyDisplayName": "Test Survey",
        "surveyName": "test-survey",
        "surveyDescription": "A survey for testing.",
        "creatorId": "creator123",
        "createdAt": "2023-01-01T12:00:00Z",
        "modifiedAt": "2023-01-01T12:00:00Z",
        "instructions": {
            "preamble": "Preamble text",
            "questionText": "Question text",
            "answers": ["Answer 1"],
        },
        "questions": questions or [],
        "finalNotes": "Final notes.",
        "prompt": prompt,
        "personaSkillKey": persona_skill_key,
        "outputProfile": output_profile,
    }


def _survey_payload(
    *,
    prompt: dict | None,
    persona_skill_key: str | None = None,
    output_profile: str | None = None,
    questions: list[dict] | None = None,
) -> dict:
    return {
        "surveyDisplayName": "Test Survey",
        "surveyName": "test-survey",
        "surveyDescription": "A survey for testing.",
        "creatorId": "creator123",
        "createdAt": "2023-01-01T12:00:00Z",
        "modifiedAt": "2023-01-01T12:00:00Z",
        "instructions": {
            "preamble": "Preamble text",
            "questionText": "Question text",
            "answers": ["Answer 1"],
        },
        "questions": questions or [],
        "finalNotes": "Final notes.",
        "prompt": prompt,
        "personaSkillKey": persona_skill_key,
        "outputProfile": output_profile,
    }


def _question_payload(
    *,
    question_id: int = 1,
    question_text: str | None = None,
    label: str | None = None,
) -> dict:
    return {
        "id": question_id,
        "questionText": question_text or "Texto da pergunta",
        "answers": ["Sim", "Não"],
        **({"label": label} if label is not None else {}),
    }


def test_create_survey():
    mock_repo = MagicMock()
    mock_prompt_repo = MagicMock()
    mock_persona_repo = MagicMock()
    mock_prompt_repo.get_by_key.return_value = {
        "promptKey": "clinical_diagnostic_report:test-survey",
        "name": "Relatório clínico",
    }
    mock_persona_repo.get_by_key.return_value = {
        "personaSkillKey": "school_report",
        "outputProfile": "school_report",
    }
    mock_repo.create.return_value = _survey_doc(
        prompt={
            "promptKey": "clinical_diagnostic_report:test-survey",
            "name": "Relatório clínico",
        },
        persona_skill_key="school_report",
        output_profile="school_report",
    )

    _override_survey_dependencies(mock_repo, mock_prompt_repo, mock_persona_repo)

    response = client.post(
        "/api/v1/surveys/",
        json=_survey_payload(
            prompt={
                "promptKey": "clinical_diagnostic_report:test-survey",
                "name": "Relatório clínico",
            },
            persona_skill_key="school_report",
            output_profile="school_report",
        ),
    )

    assert response.status_code == 201
    assert response.json()["surveyDisplayName"] == "Test Survey"
    assert response.json()["prompt"]["promptKey"] == "clinical_diagnostic_report:test-survey"
    assert response.json()["personaSkillKey"] == "school_report"
    assert response.json()["outputProfile"] == "school_report"
    app.dependency_overrides = {}


def test_create_survey_preserves_question_labels():
    mock_repo = MagicMock()
    question = _question_payload(label="Luzes pulsantes")
    mock_repo.create.return_value = _survey_doc(
        prompt=None,
        questions=[question],
    )
    _override_survey_dependencies(mock_repo)

    response = client.post(
        "/api/v1/surveys/",
        json=_survey_payload(prompt=None, questions=[question]),
    )

    assert response.status_code == 201
    assert response.json()["questions"][0]["label"] == "Luzes pulsantes"
    app.dependency_overrides = {}


def test_create_survey_accepts_null_prompt():
    mock_repo = MagicMock()
    mock_repo.create.return_value = _survey_doc(prompt=None)
    _override_survey_dependencies(mock_repo)

    response = client.post(
        "/api/v1/surveys/",
        json=_survey_payload(prompt=None),
    )

    assert response.status_code == 201
    assert response.json()["prompt"] is None
    app.dependency_overrides = {}


def test_get_surveys():
    mock_repo = MagicMock()
    mock_repo.list_all.return_value = [
        _survey_doc(prompt=None),
        {
            **_survey_doc(prompt={"promptKey": "one", "name": "Prompt One"}),
            "_id": "60c728efd4c4a4f8b8c8d0d1",
            "surveyDisplayName": "Test Survey 2",
            "surveyName": "test-survey-2",
        },
    ]
    _override_survey_dependencies(mock_repo)

    response = client.get("/api/v1/surveys/")

    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]["surveyDisplayName"] == "Test Survey"
    app.dependency_overrides = {}


def test_get_survey():
    mock_repo = MagicMock()
    mock_repo.get_by_id.return_value = _survey_doc(prompt=None)
    _override_survey_dependencies(mock_repo)

    response = client.get("/api/v1/surveys/60c728efd4c4a4f8b8c8d0d0")

    assert response.status_code == 200
    assert response.json()["surveyDisplayName"] == "Test Survey"
    app.dependency_overrides = {}


def test_get_survey_not_found():
    mock_repo = MagicMock()
    mock_repo.get_by_id.return_value = None
    _override_survey_dependencies(mock_repo)

    response = client.get("/api/v1/surveys/nonexistentid")

    assert response.status_code == 404
    assert response.json()["code"] == "NOT_FOUND"
    assert response.json()["userMessage"] == "Survey not found"
    app.dependency_overrides = {}


def test_update_survey():
    mock_repo = MagicMock()
    mock_prompt_repo = MagicMock()
    mock_persona_repo = MagicMock()
    mock_prompt_repo.get_by_key.return_value = {
        "promptKey": "clinical_diagnostic_report:test-survey",
        "name": "Relatório clínico",
    }
    mock_persona_repo.get_by_key.return_value = {
        "personaSkillKey": "school_report",
        "outputProfile": "school_report",
    }
    mock_repo.update.return_value = {
        **_survey_doc(
            prompt={
                "promptKey": "clinical_diagnostic_report:test-survey",
                "name": "Relatório clínico",
            },
            persona_skill_key="school_report",
            output_profile="school_report",
        ),
        "surveyDisplayName": "Updated Survey",
    }
    _override_survey_dependencies(mock_repo, mock_prompt_repo, mock_persona_repo)

    response = client.put(
        "/api/v1/surveys/60c728efd4c4a4f8b8c8d0d0",
        json={
            **_survey_payload(
                prompt={
                    "promptKey": "clinical_diagnostic_report:test-survey",
                    "name": "Relatório clínico",
                },
                persona_skill_key="school_report",
                output_profile="school_report",
            ),
            "_id": "60c728efd4c4a4f8b8c8d0d0",
            "surveyDisplayName": "Updated Survey",
        },
    )

    assert response.status_code == 200
    assert response.json()["surveyDisplayName"] == "Updated Survey"
    app.dependency_overrides = {}
