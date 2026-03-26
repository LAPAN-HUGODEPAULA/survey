from fastapi.testclient import TestClient
from unittest.mock import MagicMock

from app.main import app
from app.persistence.deps import get_survey_prompt_repo, get_survey_repo


client = TestClient(app)


def _override_survey_dependencies(
    mock_repo: MagicMock,
    mock_prompt_repo: MagicMock | None = None,
) -> None:
    prompt_repo = mock_prompt_repo or MagicMock()
    app.dependency_overrides[get_survey_repo] = lambda: mock_repo
    app.dependency_overrides[get_survey_prompt_repo] = lambda: prompt_repo


def _survey_doc(*, prompt: dict | None) -> dict:
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
        "questions": [],
        "finalNotes": "Final notes.",
        "prompt": prompt,
    }


def _survey_payload(*, prompt: dict | None) -> dict:
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
        "questions": [],
        "finalNotes": "Final notes.",
        "prompt": prompt,
    }


def test_create_survey():
    mock_repo = MagicMock()
    mock_prompt_repo = MagicMock()
    mock_prompt_repo.get_by_key.return_value = {
        "promptKey": "clinical_diagnostic_report:test-survey",
        "name": "Relatório clínico",
    }
    mock_repo.create.return_value = _survey_doc(
        prompt={
            "promptKey": "clinical_diagnostic_report:test-survey",
            "name": "Relatório clínico",
        }
    )

    _override_survey_dependencies(mock_repo, mock_prompt_repo)

    response = client.post(
        "/api/v1/surveys/",
        json=_survey_payload(
            prompt={
                "promptKey": "clinical_diagnostic_report:test-survey",
                "name": "Relatório clínico",
            }
        ),
    )

    assert response.status_code == 201
    assert response.json()["surveyDisplayName"] == "Test Survey"
    assert response.json()["prompt"]["promptKey"] == "clinical_diagnostic_report:test-survey"
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
    assert response.json()["detail"] == "Survey not found"
    app.dependency_overrides = {}


def test_update_survey():
    mock_repo = MagicMock()
    mock_prompt_repo = MagicMock()
    mock_prompt_repo.get_by_key.return_value = {
        "promptKey": "clinical_diagnostic_report:test-survey",
        "name": "Relatório clínico",
    }
    mock_repo.update.return_value = {
        **_survey_doc(
            prompt={
                "promptKey": "clinical_diagnostic_report:test-survey",
                "name": "Relatório clínico",
            }
        ),
        "surveyDisplayName": "Updated Survey",
    }
    _override_survey_dependencies(mock_repo, mock_prompt_repo)

    response = client.put(
        "/api/v1/surveys/60c728efd4c4a4f8b8c8d0d0",
        json={
            **_survey_payload(
                prompt={
                    "promptKey": "clinical_diagnostic_report:test-survey",
                    "name": "Relatório clínico",
                }
            ),
            "_id": "60c728efd4c4a4f8b8c8d0d0",
            "surveyDisplayName": "Updated Survey",
        },
    )

    assert response.status_code == 200
    assert response.json()["surveyDisplayName"] == "Updated Survey"
    app.dependency_overrides = {}


def test_update_survey_not_found():
    mock_repo = MagicMock()
    mock_prompt_repo = MagicMock()
    mock_prompt_repo.get_by_key.return_value = {
        "promptKey": "clinical_diagnostic_report:test-survey",
        "name": "Relatório clínico",
    }
    mock_repo.update.return_value = None
    _override_survey_dependencies(mock_repo, mock_prompt_repo)

    response = client.put(
        "/api/v1/surveys/nonexistentid",
        json={
            **_survey_payload(
                prompt={
                    "promptKey": "clinical_diagnostic_report:test-survey",
                    "name": "Relatório clínico",
                }
            ),
            "_id": "nonexistentid",
            "surveyDisplayName": "Updated Survey",
        },
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"
    app.dependency_overrides = {}


def test_delete_survey():
    mock_repo = MagicMock()
    mock_repo.get_by_id.return_value = {"_id": "60c728efd4c4a4f8b8c8d0d0"}
    mock_repo.delete.return_value = True
    _override_survey_dependencies(mock_repo)

    response = client.delete("/api/v1/surveys/60c728efd4c4a4f8b8c8d0d0")

    assert response.status_code == 204
    app.dependency_overrides = {}


def test_delete_survey_not_found():
    mock_repo = MagicMock()
    mock_repo.get_by_id.return_value = None
    _override_survey_dependencies(mock_repo)

    response = client.delete("/api/v1/surveys/nonexistentid")

    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"
    app.dependency_overrides = {}


def test_create_survey_rejects_unknown_prompt_key():
    mock_repo = MagicMock()
    mock_prompt_repo = MagicMock()
    mock_prompt_repo.get_by_key.return_value = None
    _override_survey_dependencies(mock_repo, mock_prompt_repo)

    response = client.post(
        "/api/v1/surveys/",
        json=_survey_payload(
            prompt={
                "promptKey": "missing",
                "name": "Missing prompt",
            }
        ),
    )

    assert response.status_code == 422
    assert response.json()["detail"] == "Unknown promptKey: missing"
    app.dependency_overrides = {}


def test_create_survey_rejects_legacy_prompt_associations():
    mock_repo = MagicMock()
    _override_survey_dependencies(mock_repo)

    response = client.post(
        "/api/v1/surveys/",
        json={
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
            "questions": [],
            "finalNotes": "Final notes.",
            "promptAssociations": [],
        },
    )

    assert response.status_code == 422
    app.dependency_overrides = {}
