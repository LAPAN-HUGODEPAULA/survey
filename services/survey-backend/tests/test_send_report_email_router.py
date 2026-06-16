from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.api.dependencies.response_services import get_report_delivery_service
from app.main import app
from app.persistence.deps import get_patient_response_repo, get_survey_response_repo
from app.services.report_delivery import SendReportResult


client = TestClient(app)


def test_send_patient_report_email_returns_404_when_response_missing() -> None:
    repo = MagicMock()
    repo.get_by_id.return_value = None
    app.dependency_overrides[get_patient_response_repo] = lambda: repo

    response = client.post("/api/v1/patient_responses/response-1/send_report_email")

    assert response.status_code == 404
    assert response.json()["userMessage"] == "Patient response not found."
    app.dependency_overrides = {}


def test_send_patient_report_email_returns_422_when_patient_email_is_missing() -> None:
    repo = MagicMock()
    repo.get_by_id.return_value = {
        "_id": "response-1",
        "patient": {"name": "Paciente sem email"},
    }
    app.dependency_overrides[get_patient_response_repo] = lambda: repo

    response = client.post("/api/v1/patient_responses/response-1/send_report_email")

    assert response.status_code == 422
    assert (
        response.json()["userMessage"]
        == "Patient response does not contain an email address."
    )
    app.dependency_overrides = {}


def test_send_patient_report_email_sends_pdf_to_patient(monkeypatch) -> None:
    repo = MagicMock()
    repo.get_by_id.return_value = {
        "_id": "response-1",
        "patient": {"email": "patient@example.com"},
        "agentResponse": {
            "medicalRecord": "Resumo clínico gerado",
        },
    }
    app.dependency_overrides[get_patient_response_repo] = lambda: repo

    sent = {}

    class _FakeDeliveryService:
        async def execute(self, command):
            sent["command"] = command
            return SendReportResult(
                status="sent",
                response_id=command.response_id,
                recipients=[command.patient_email, "lapan@example.com"],
            )

    app.dependency_overrides[get_report_delivery_service] = lambda: _FakeDeliveryService()

    response = client.post(
        "/api/v1/patient_responses/response-1/send_report_email",
        json={"reportText": "Relatório final customizado"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "sent"
    assert body["responseId"] == "response-1"
    assert sent["command"].response_id == "response-1"
    assert sent["command"].patient_email == "patient@example.com"
    assert sent["command"].report_text == "Relatório final customizado"
    app.dependency_overrides = {}


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


def test_send_report_email_sends_pdf_to_patient() -> None:
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

    class _FakeDeliveryService:
        async def execute(self, command):
            sent["command"] = command
            return SendReportResult(
                status="sent",
                response_id=command.response_id,
                recipients=[command.patient_email, "lapan@example.com"],
            )

    app.dependency_overrides[get_report_delivery_service] = lambda: _FakeDeliveryService()

    response = client.post(
        "/api/v1/survey_responses/response-1/send_report_email",
        json={"reportText": "Relatório final customizado"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "sent"
    assert body["responseId"] == "response-1"
    assert sent["command"].response_id == "response-1"
    assert sent["command"].patient_email == "patient@example.com"
    assert sent["command"].report_text == "Relatório final customizado"
    app.dependency_overrides = {}
