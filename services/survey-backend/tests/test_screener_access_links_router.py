import unittest
from datetime import datetime, timezone
from unittest.mock import MagicMock, patch

import jwt
from fastapi.testclient import TestClient

from app.config.settings import settings
from app.domain.models.screener_access_link_model import ScreenerAccessLinkModel
from app.domain.models.screener_model import Address, ProfessionalCouncil, ScreenerModel
from app.main import app
from app.persistence.deps import (
    get_screener_access_link_repo,
    get_screener_repo,
    get_survey_repo,
    get_survey_response_repo,
)


def _auth_header(email: str = "ana@example.com") -> dict[str, str]:
    token = jwt.encode({"sub": email}, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return {"Authorization": f"Bearer {token}"}


def _build_screener() -> ScreenerModel:
    return ScreenerModel(
        _id="screener-1",
        cpf="52998224725",
        firstName="Ana",
        surname="Silva",
        email="ana@example.com",
        password="hashed",
        phone="31988447613",
        address=Address(
            postalCode="30140071",
            street="Rua Teste",
            number="123",
            complement=None,
            neighborhood="Centro",
            city="Belo Horizonte",
            state="MG",
        ),
        professionalCouncil=ProfessionalCouncil(type="CRP", registrationNumber="1234"),
        jobTitle="Psicóloga",
        degree="Psicologia",
    )


class ScreenerAccessLinksRouterTests(unittest.TestCase):
    def setUp(self) -> None:
        self.client = TestClient(app)
        app.dependency_overrides = {}

    def tearDown(self) -> None:
        app.dependency_overrides = {}

    def test_create_screener_access_link(self) -> None:
        mock_link_repo = MagicMock()
        mock_screener_repo = MagicMock()
        mock_survey_repo = MagicMock()

        mock_screener_repo.find_by_email.return_value = _build_screener()
        mock_survey_repo.get_by_id.return_value = {
            "_id": "survey-1",
            "surveyDisplayName": "Questionário CHYPS-Br",
        }
        mock_link_repo.create.side_effect = lambda link: link

        app.dependency_overrides[get_screener_access_link_repo] = lambda: mock_link_repo
        app.dependency_overrides[get_screener_repo] = lambda: mock_screener_repo
        app.dependency_overrides[get_survey_repo] = lambda: mock_survey_repo

        response = self.client.post(
            "/api/v1/screener_access_links/",
            json={"surveyId": "survey-1"},
            headers=_auth_header(),
        )

        self.assertEqual(response.status_code, 201)
        data = response.json()
        self.assertEqual(data["screenerId"], "screener-1")
        self.assertEqual(data["surveyId"], "survey-1")
        self.assertTrue(data["token"])

    def test_resolve_missing_screener_access_link_returns_not_found(self) -> None:
        mock_link_repo = MagicMock()
        mock_screener_repo = MagicMock()
        mock_survey_repo = MagicMock()

        mock_link_repo.find_by_token.return_value = None

        app.dependency_overrides[get_screener_access_link_repo] = lambda: mock_link_repo
        app.dependency_overrides[get_screener_repo] = lambda: mock_screener_repo
        app.dependency_overrides[get_survey_repo] = lambda: mock_survey_repo

        response = self.client.get("/api/v1/screener_access_links/token-invalido")

        self.assertEqual(response.status_code, 404)
        self.assertEqual(
            response.json()["detail"],
            "Prepared assessment is no longer available",
        )

    @patch("app.api.routes.survey_responses.send_survey_response_email")
    @patch("app.api.routes.survey_responses.send_to_langgraph_agent")
    def test_create_survey_response_uses_linked_screener(
        self,
        mock_agent,
        mock_email,
    ) -> None:
        del mock_email
        mock_link_repo = MagicMock()
        mock_screener_repo = MagicMock()
        mock_survey_repo = MagicMock()
        mock_response_repo = MagicMock()

        mock_agent.return_value = {"ok": True}
        link = ScreenerAccessLinkModel(
            _id="token-123",
            screenerId="screener-1",
            screenerName="Ana Silva",
            surveyId="survey-1",
            surveyDisplayName="Questionário CHYPS-Br",
            createdAt=datetime.now(timezone.utc),
        )
        mock_link_repo.find_by_token.return_value = link
        mock_screener_repo.find_by_id.return_value = _build_screener()
        mock_survey_repo.get_by_id.return_value = {
            "_id": "survey-1",
            "surveyDisplayName": "Questionário CHYPS-Br",
        }

        captured_doc: dict[str, object] = {}

        def _create(doc: dict) -> dict:
            captured_doc.update(doc)
            return {"_id": "response-1", **doc}

        mock_response_repo.create.side_effect = _create

        app.dependency_overrides[get_screener_access_link_repo] = lambda: mock_link_repo
        app.dependency_overrides[get_screener_repo] = lambda: mock_screener_repo
        app.dependency_overrides[get_survey_repo] = lambda: mock_survey_repo
        app.dependency_overrides[get_survey_response_repo] = lambda: mock_response_repo

        response = self.client.post(
            "/api/v1/survey_responses/",
            json={
                "surveyId": "survey-ignorado",
                "creatorId": "creator-1",
                "testDate": datetime.now(timezone.utc).isoformat(),
                "screenerId": "screener-ignorado",
                "accessLinkToken": "token-123",
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
            },
        )

        self.assertEqual(response.status_code, 201)
        self.assertEqual(captured_doc["screenerId"], "screener-1")
        self.assertEqual(captured_doc["surveyId"], "survey-1")


if __name__ == "__main__":
    unittest.main()
