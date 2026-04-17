from datetime import timedelta
from unittest.mock import MagicMock

import bcrypt
from fastapi.testclient import TestClient

from app.api.dependencies.builder_auth import create_builder_session_token
from app.domain.models.screener_model import Address, ProfessionalCouncil, ScreenerModel
from app.main import app
from app.persistence.deps import get_screener_repo, get_survey_prompt_repo


client = TestClient(app)


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


def _screener(*, is_builder_admin: bool) -> ScreenerModel:
    password_hash = bcrypt.hashpw(b'StrongPassword123', bcrypt.gensalt()).decode('utf-8')
    return ScreenerModel(
        _id='60c728efd4c4a4f8b8c8d0d0',
        cpf='11111111111',
        firstName='Maria',
        surname='Admin',
        email='maria@example.com',
        password=password_hash,
        phone='31999999999',
        address=Address(
            postalCode='30110000',
            street='Rua A',
            number='10',
            complement='Sala 1',
            neighborhood='Centro',
            city='Belo Horizonte',
            state='MG',
        ),
        professionalCouncil=ProfessionalCouncil(type='none', registrationNumber=''),
        jobTitle='Psicóloga',
        degree='Psicologia',
        isBuilderAdmin=is_builder_admin,
    )


def _prompt_doc() -> dict:
    return {
        'promptKey': 'clinical_referral_letter:lapan7',
        'name': 'Encaminhamento clínico',
        'promptText': 'Escreva um encaminhamento clínico.',
        'createdAt': '2026-04-16T00:00:00Z',
        'modifiedAt': '2026-04-16T00:00:00Z',
    }


def test_builder_routes_reject_unauthenticated_access():
    prompt_repo = MagicMock()
    prompt_repo.list_all.return_value = [_prompt_doc()]
    app.dependency_overrides[get_survey_prompt_repo] = lambda: prompt_repo
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(_screener(is_builder_admin=True))

    response = client.get('/api/v1/survey_prompts/')

    assert response.status_code == 401
    assert response.json()['code'] == 'BUILDER_LOGIN_REQUIRED'
    app.dependency_overrides = {}
    client.cookies.clear()


def test_builder_login_rejects_non_admin_screener():
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(_screener(is_builder_admin=False))

    response = client.post(
        '/api/v1/builder/login',
        json={'email': 'maria@example.com', 'password': 'StrongPassword123'},
    )

    assert response.status_code == 403
    assert response.json()['code'] == 'BUILDER_ADMIN_REQUIRED'
    app.dependency_overrides = {}
    client.cookies.clear()


def test_builder_login_bootstraps_session_and_csrf():
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(_screener(is_builder_admin=True))

    response = client.post(
        '/api/v1/builder/login',
        json={'email': 'maria@example.com', 'password': 'StrongPassword123'},
    )

    assert response.status_code == 200
    assert response.json()['profile']['isBuilderAdmin'] is True
    assert response.json()['csrfToken']

    session_response = client.get('/api/v1/builder/session')
    assert session_response.status_code == 200
    assert session_response.json()['profile']['email'] == 'maria@example.com'

    app.dependency_overrides = {}
    client.cookies.clear()


def test_builder_route_denies_revoked_admin_after_login():
    repo = FakeScreenerRepo(_screener(is_builder_admin=True))
    prompt_repo = MagicMock()
    prompt_repo.list_all.return_value = [_prompt_doc()]
    app.dependency_overrides[get_screener_repo] = lambda: repo
    app.dependency_overrides[get_survey_prompt_repo] = lambda: prompt_repo

    login = client.post(
        '/api/v1/builder/login',
        json={'email': 'maria@example.com', 'password': 'StrongPassword123'},
    )
    assert login.status_code == 200

    repo.screener.isBuilderAdmin = False
    response = client.get('/api/v1/survey_prompts/')

    assert response.status_code == 403
    assert response.json()['code'] == 'BUILDER_ADMIN_REVOKED'

    app.dependency_overrides = {}
    client.cookies.clear()


def test_builder_write_requires_valid_csrf():
    repo = FakeScreenerRepo(_screener(is_builder_admin=True))
    prompt_repo = MagicMock()
    prompt_repo.create.return_value = _prompt_doc()
    app.dependency_overrides[get_screener_repo] = lambda: repo
    app.dependency_overrides[get_survey_prompt_repo] = lambda: prompt_repo

    login = client.post(
        '/api/v1/builder/login',
        json={'email': 'maria@example.com', 'password': 'StrongPassword123'},
    )
    csrf_token = login.json()['csrfToken']

    missing_csrf = client.post(
        '/api/v1/survey_prompts/',
        json={
            'promptKey': 'clinical_referral_letter:lapan7',
            'name': 'Encaminhamento clínico',
            'promptText': 'Escreva um encaminhamento clínico.',
        },
    )
    assert missing_csrf.status_code == 403
    assert missing_csrf.json()['code'] == 'BUILDER_CSRF_INVALID'

    created = client.post(
        '/api/v1/survey_prompts/',
        headers={'X-Builder-CSRF': csrf_token},
        json={
            'promptKey': 'clinical_referral_letter:lapan7',
            'name': 'Encaminhamento clínico',
            'promptText': 'Escreva um encaminhamento clínico.',
        },
    )
    assert created.status_code == 201

    app.dependency_overrides = {}
    client.cookies.clear()


def test_builder_logout_clears_session_cookie():
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(_screener(is_builder_admin=True))

    login = client.post(
        '/api/v1/builder/login',
        json={'email': 'maria@example.com', 'password': 'StrongPassword123'},
    )
    assert login.status_code == 200

    logout = client.post('/api/v1/builder/logout')
    assert logout.status_code == 204

    session_response = client.get('/api/v1/builder/session')
    assert session_response.status_code == 401

    app.dependency_overrides = {}
    client.cookies.clear()


def test_builder_session_reports_expired_cookie():
    screener = _screener(is_builder_admin=True)
    app.dependency_overrides[get_screener_repo] = lambda: FakeScreenerRepo(screener)

    client.cookies.set(
        'survey_builder_session',
        create_builder_session_token(screener.id or '', expires_delta=timedelta(minutes=-1)),
    )

    response = client.get('/api/v1/builder/session')

    assert response.status_code == 401
    assert response.json()['code'] == 'BUILDER_SESSION_EXPIRED'

    app.dependency_overrides = {}
    client.cookies.clear()
