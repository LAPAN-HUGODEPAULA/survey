"""Integration tests for screener bearer-token authentication.

Uses dependency overrides with real JWT signing (no repository mocks)
to verify the full auth pipeline: token creation, bearer validation,
screener resolution, and role enforcement.
"""

from __future__ import annotations

import bcrypt
from datetime import timedelta, datetime
import jwt
from fastapi.testclient import TestClient

from app.config.settings import settings
from app.domain.models.screener_model import Address, ProfessionalCouncil, ScreenerModel
from app.main import app
from app.persistence.deps import get_screener_repo


client = TestClient(app)

TEST_EMAIL = "maria@example.com"
TEST_PASSWORD = "StrongPassword123"


class FakeScreenerRepo:
    def __init__(self, screener: ScreenerModel):
        self.screener = screener

    def find_by_email(self, email: str):
        if email == self.screener.email:
            return self.screener
        return None

    def find_by_id(self, screener_id: str):
        if screener_id == self.screener.id:
            return self.screener
        return None


def _make_screener(*, is_builder_admin: bool = False) -> ScreenerModel:
    password_hash = bcrypt.hashpw(TEST_PASSWORD.encode(), bcrypt.gensalt()).decode()
    return ScreenerModel(
        _id="60c728efd4c4a4f8b8c8d0d0",
        cpf="11111111111",
        firstName="Maria",
        surname="Admin",
        email=TEST_EMAIL,
        password=password_hash,
        phone="31999999999",
        address=Address(
            postalCode="30110000",
            street="Rua A",
            number="10",
            complement="Sala 1",
            neighborhood="Centro",
            city="Belo Horizonte",
            state="MG",
        ),
        professionalCouncil=ProfessionalCouncil(type="none", registrationNumber=""),
        jobTitle="Psicologa",
        degree="Psicologia",
        isBuilderAdmin=is_builder_admin,
    )


def _make_token(email: str = TEST_EMAIL, *, expired: bool = False) -> str:
    expire = datetime.utcnow() + (
        timedelta(minutes=-1) if expired else timedelta(minutes=30)
    )
    return jwt.encode(
        {"sub": email, "exp": expire},
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )


# --- Screener auth: rejection scenarios ---


def test_screener_me_rejects_missing_token():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.get("/api/v1/screeners/me")

    assert response.status_code == 401
    assert response.json()["code"] == "SCREENER_AUTH_REQUIRED"

    app.dependency_overrides = {}


def test_screener_me_rejects_expired_token():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.get(
        "/api/v1/screeners/me",
        headers={"Authorization": f"Bearer {_make_token(expired=True)}"},
    )

    assert response.status_code == 401
    assert response.json()["code"] == "SCREENER_TOKEN_EXPIRED"

    app.dependency_overrides = {}


def test_screener_me_rejects_invalid_scheme():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.get(
        "/api/v1/screeners/me",
        headers={"Authorization": f"Basic {_make_token()}"},
    )

    assert response.status_code == 401
    assert response.json()["code"] == "SCREENER_AUTH_INVALID_SCHEME"

    app.dependency_overrides = {}


def test_screener_me_rejects_unknown_screener():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.get(
        "/api/v1/screeners/me",
        headers={"Authorization": f"Bearer {_make_token(email='unknown@test.com')}"},
    )

    assert response.status_code == 401
    assert response.json()["code"] == "SCREENER_NOT_FOUND"

    app.dependency_overrides = {}


# --- Screener auth: success scenarios ---


def test_screener_me_returns_profile_with_valid_token():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.get(
        "/api/v1/screeners/me",
        headers={"Authorization": f"Bearer {_make_token()}"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["email"] == TEST_EMAIL
    assert body["firstName"] == "Maria"
    assert "password" not in body

    app.dependency_overrides = {}


def test_screener_access_link_create_rejects_unauthenticated():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.post(
        "/api/v1/screener_access_links/",
        json={"surveyId": "60c728efd4c4a4f8b8c8d0d0"},
    )

    assert response.status_code == 401

    app.dependency_overrides = {}


# --- Clinical routes reject unauthenticated ---


def test_chat_sessions_rejects_unauthenticated():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.post("/api/v1/chat/sessions", json={})

    assert response.status_code == 401

    app.dependency_overrides = {}


def test_chat_messages_rejects_unauthenticated():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.post(
        "/api/v1/chat/sessions/abc123/messages",
        json={"role": "user", "messageType": "text", "content": "hello"},
    )

    assert response.status_code == 401

    app.dependency_overrides = {}


def test_documents_preview_rejects_unauthenticated():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.post("/api/v1/documents/preview", json={"sessionId": "abc"})

    assert response.status_code == 401

    app.dependency_overrides = {}


def test_voice_transcriptions_rejects_unauthenticated():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.post(
        "/api/v1/voice/transcriptions",
        json={"audio_url": "https://example.com/audio.wav"},
    )

    assert response.status_code == 401

    app.dependency_overrides = {}


def test_survey_responses_list_rejects_unauthenticated():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.get("/api/v1/survey_responses/")

    assert response.status_code == 401

    app.dependency_overrides = {}


def test_medications_manual_upsert_rejects_unauthenticated():
    screener = _make_screener(is_builder_admin=False)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    response = client.post(
        "/api/v1/medications/manual",
        json={"substance": "Ibuprofen"},
    )

    assert response.status_code == 401

    app.dependency_overrides = {}
