from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.main import app
from app.persistence.deps import get_survey_response_repo


client = TestClient(app)


def test_send_report_email_returns_404_when_response_missing() -> None:
    repo = MagicMock()
    repo.get_raw_by_id.return_value = None
    app.dependency_overrides[get_survey_response_repo] = lambda: repo

    response = client.post("/api/v1/survey_responses/response-1/send_report_email")

    assert response.status_code == 404
    assert response.json()["userMessage"] == "Survey response not found."
    app.dependency_overrides = {}


def test_send_report_email_returns_422_when_patient_email_is_missing() -> None:
    repo = MagicMock()
    repo.get_raw_by_id.return_value = {
        "_id": "response-1",
        "patient": {"name": "Paciente sem email"},
    }
    app.dependency_overrides[get_survey_response_repo] = lambda: repo

    response = client.post("/api/v1/survey_responses/response-1/send_report_email")

    assert response.status_code == 422
    assert (
        response.json()["userMessage"]
        == "Survey response does not contain an email address."
    )
    app.dependency_overrides = {}


def test_send_report_email_sends_pdf_to_patient(monkeypatch) -> None:
    repo = MagicMock()
    repo.get_raw_by_id.return_value = {
        "_id": "response-1",
        "patient": {"email": "patient@example.com"},
        "agentResponse": {
            "medical_record": "Resumo clínico gerado",
        },
    }
    app.dependency_overrides[get_survey_response_repo] = lambda: repo

    sent = {}

    async def _fake_send_patient_report_email(*, response_id, recipients, attachment_paths):
        sent["response_id"] = response_id
        sent["recipients"] = recipients
        sent["attachment_paths"] = attachment_paths

    monkeypatch.setattr(
        "app.api.routes.survey_responses.send_patient_report_email",
        _fake_send_patient_report_email,
    )
    monkeypatch.setattr(
        "app.api.routes.survey_responses._generate_report_pdf",
        lambda _report_text: b"%PDF-1.4 fake",
    )
    monkeypatch.setattr(
        "app.api.routes.survey_responses._write_temp_pdf",
        lambda _pdf_bytes, response_id: f"/tmp/{response_id}_report.pdf",
    )

    response = client.post(
        "/api/v1/survey_responses/response-1/send_report_email",
        json={"reportText": "Relatório final customizado"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "sent"
    assert body["responseId"] == "response-1"
    assert sent["response_id"] == "response-1"
    assert sent["recipients"][0] == "patient@example.com"
    assert sent["attachment_paths"][0].endswith("response-1_report.pdf")
    app.dependency_overrides = {}
