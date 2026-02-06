from fastapi.testclient import TestClient
from unittest.mock import MagicMock

from app.main import app
from app.persistence.deps import (
    get_data_lifecycle_repo,
    get_privacy_request_repo,
    get_security_audit_repo,
)


client = TestClient(app)


def test_create_privacy_request_creates_audit():
    mock_privacy_repo = MagicMock()
    mock_privacy_repo.create.return_value = {
        "_id": "req-1",
        "requestType": "access",
        "subjectType": "patient",
        "subjectId": "patient-1",
        "requesterEmail": "patient@example.com",
        "status": "pending",
    }
    mock_audit_repo = MagicMock()
    mock_audit_repo.get_latest.return_value = {}
    mock_audit_repo.create.return_value = {"_id": "audit-1", "hash": "hash1"}

    app.dependency_overrides[get_privacy_request_repo] = lambda: mock_privacy_repo
    app.dependency_overrides[get_security_audit_repo] = lambda: mock_audit_repo

    response = client.post(
        "/api/v1/privacy/requests",
        json={
            "requestType": "access",
            "subjectType": "patient",
            "subjectId": "patient-1",
            "requesterEmail": "patient@example.com",
        },
    )

    assert response.status_code == 201
    assert response.json()["requestType"] == "access"
    mock_audit_repo.create.assert_called_once()

    app.dependency_overrides = {}


def test_list_privacy_requests_requires_admin_token():
    mock_audit_repo = MagicMock()
    mock_audit_repo.get_latest.return_value = {}
    mock_audit_repo.create.return_value = {"_id": "audit-401", "hash": "hash401"}
    app.dependency_overrides[get_security_audit_repo] = lambda: mock_audit_repo

    response = client.get("/api/v1/privacy/requests")
    assert response.status_code == 401

    app.dependency_overrides = {}


def test_fulfill_privacy_request_creates_lifecycle_job():
    mock_privacy_repo = MagicMock()
    mock_privacy_repo.update.return_value = {
        "_id": "req-2",
        "requestType": "deletion",
        "subjectType": "patient",
        "subjectId": "patient-2",
        "status": "fulfilled",
    }
    mock_audit_repo = MagicMock()
    mock_audit_repo.get_latest.return_value = {}
    mock_audit_repo.create.return_value = {"_id": "audit-2", "hash": "hash2"}
    mock_lifecycle_repo = MagicMock()
    mock_lifecycle_repo.create.return_value = {"_id": "job-1", "requestId": "req-2"}

    app.dependency_overrides[get_privacy_request_repo] = lambda: mock_privacy_repo
    app.dependency_overrides[get_security_audit_repo] = lambda: mock_audit_repo
    app.dependency_overrides[get_data_lifecycle_repo] = lambda: mock_lifecycle_repo

    response = client.patch(
        "/api/v1/privacy/requests/req-2",
        headers={"X-Privacy-Admin-Token": "dev-privacy-token"},
        json={"status": "fulfilled"},
    )

    assert response.status_code == 200
    assert response.json()["status"] == "fulfilled"
    mock_lifecycle_repo.create.assert_called_once()

    app.dependency_overrides = {}
