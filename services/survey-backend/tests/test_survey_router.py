from fastapi.testclient import TestClient
from unittest.mock import MagicMock
from app.main import app
from app.persistence.deps import get_survey_repo
from app.domain.models.survey_model import Survey

client = TestClient(app)

def test_create_survey():
    mock_repo = MagicMock()
    mock_repo.create.return_value = {
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
            "answers": ["Answer 1"]
        },
        "questions": [],
        "finalNotes": "Final notes."
    }

    app.dependency_overrides[get_survey_repo] = lambda: mock_repo

    response = client.post(
        "/api/v1/surveys/",
        json={
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
                "answers": ["Answer 1"]
            },
            "questions": [],
            "finalNotes": "Final notes."
        }
    )
    assert response.status_code == 200
    assert response.json()["surveyDisplayName"] == "Test Survey"
    app.dependency_overrides = {}

def test_get_surveys():
    mock_repo = MagicMock()
    mock_repo.list_all.return_value = [
        {
            "_id": "60c728efd4c4a4f8b8c8d0d0",
            "surveyDisplayName": "Test Survey 1",
            "surveyName": "test-survey-1",
            "surveyDescription": "A survey for testing 1.",
            "creatorId": "creator123",
            "createdAt": "2023-01-01T12:00:00Z",
            "modifiedAt": "2023-01-01T12:00:00Z",
            "instructions": {
                "preamble": "Preamble text 1",
                "questionText": "Question text 1",
                "answers": ["Answer 1"]
            },
            "questions": [],
            "finalNotes": "Final notes 1."
        },
        {
            "_id": "60c728efd4c4a4f8b8c8d0d1",
            "surveyDisplayName": "Test Survey 2",
            "surveyName": "test-survey-2",
            "surveyDescription": "A survey for testing 2.",
            "creatorId": "creator123",
            "createdAt": "2023-01-01T12:00:00Z",
            "modifiedAt": "2023-01-01T12:00:00Z",
            "instructions": {
                "preamble": "Preamble text 2",
                "questionText": "Question text 2",
                "answers": ["Answer 2"]
            },
            "questions": [],
            "finalNotes": "Final notes 2."
        }
    ]
    app.dependency_overrides[get_survey_repo] = lambda: mock_repo
    response = client.get("/api/v1/surveys/")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]["surveyDisplayName"] == "Test Survey 1"
    app.dependency_overrides = {}

def test_get_survey():
    mock_repo = MagicMock()
    mock_repo.get_by_id.return_value = {
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
            "answers": ["Answer 1"]
        },
        "questions": [],
        "finalNotes": "Final notes."
    }
    app.dependency_overrides[get_survey_repo] = lambda: mock_repo
    response = client.get("/api/v1/surveys/60c728efd4c4a4f8b8c8d0d0")
    assert response.status_code == 200
    assert response.json()["surveyDisplayName"] == "Test Survey"
    app.dependency_overrides = {}

def test_get_survey_not_found():
    mock_repo = MagicMock()
    mock_repo.get_by_id.return_value = None
    app.dependency_overrides[get_survey_repo] = lambda: mock_repo
    response = client.get("/api/v1/surveys/nonexistentid")
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"
    app.dependency_overrides = {}

def test_update_survey():
    mock_repo = MagicMock()
    mock_repo.update.return_value = {
        "_id": "60c728efd4c4a4f8b8c8d0d0",
        "surveyDisplayName": "Updated Survey",
        "surveyName": "test-survey",
        "surveyDescription": "A survey for testing.",
        "creatorId": "creator123",
        "createdAt": "2023-01-01T12:00:00Z",
        "modifiedAt": "2023-01-01T12:00:00Z",
        "instructions": {
            "preamble": "Preamble text",
            "questionText": "Question text",
            "answers": ["Answer 1"]
        },
        "questions": [],
        "finalNotes": "Final notes."
    }
    app.dependency_overrides[get_survey_repo] = lambda: mock_repo
    response = client.put(
        "/api/v1/surveys/60c728efd4c4a4f8b8c8d0d0",
        json={
            "_id": "60c728efd4c4a4f8b8c8d0d0",
            "surveyDisplayName": "Updated Survey",
            "surveyName": "test-survey",
            "surveyDescription": "A survey for testing.",
            "creatorId": "creator123",
            "createdAt": "2023-01-01T12:00:00Z",
            "modifiedAt": "2023-01-01T12:00:00Z",
            "instructions": {
                "preamble": "Preamble text",
                "questionText": "Question text",
                "answers": ["Answer 1"]
            },
            "questions": [],
            "finalNotes": "Final notes."
        }
    )
    assert response.status_code == 200
    assert response.json()["surveyDisplayName"] == "Updated Survey"
    app.dependency_overrides = {}

def test_update_survey_not_found():
    mock_repo = MagicMock()
    mock_repo.update.return_value = None
    app.dependency_overrides[get_survey_repo] = lambda: mock_repo
    response = client.put(
        "/api/v1/surveys/nonexistentid",
        json={
            "_id": "nonexistentid",
            "surveyDisplayName": "Updated Survey",
            "surveyName": "test-survey",
            "surveyDescription": "A survey for testing.",
            "creatorId": "creator123",
            "createdAt": "2023-01-01T12:00:00Z",
            "modifiedAt": "2023-01-01T12:00:00Z",
            "instructions": {
                "preamble": "Preamble text",
                "questionText": "Question text",
                "answers": ["Answer 1"]
            },
            "questions": [],
            "finalNotes": "Final notes."
        }
    )
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"
    app.dependency_overrides = {}

def test_delete_survey():
    mock_repo = MagicMock()
    mock_repo.get_by_id.return_value = {"_id": "60c728efd4c4a4f8b8c8d0d0"} # Simulate survey exists
    mock_repo.delete.return_value = True
    app.dependency_overrides[get_survey_repo] = lambda: mock_repo
    response = client.delete("/api/v1/surveys/60c728efd4c4a4f8b8c8d0d0")
    assert response.status_code == 204
    app.dependency_overrides = {}

def test_delete_survey_not_found():
    mock_repo = MagicMock()
    mock_repo.get_by_id.return_value = None # Simulate survey does not exist
    app.dependency_overrides[get_survey_repo] = lambda: mock_repo
    response = client.delete("/api/v1/surveys/nonexistentid")
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"
    app.dependency_overrides = {}
