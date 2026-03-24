import unittest
from datetime import datetime, timezone

from app.domain.models.survey_response_model import SurveyResponse


class SurveyResponseModelTests(unittest.TestCase):
    def test_allows_missing_patient(self) -> None:
        payload = {
            "surveyId": "survey-1",
            "creatorId": "creator-1",
            "testDate": datetime.now(timezone.utc).isoformat(),
            "screenerId": "screener-1",
            "answers": [{"id": 1, "answer": "A"}],
        }

        response = SurveyResponse.model_validate(payload)

        self.assertIsNone(response.patient)
        self.assertEqual(response.survey_id, "survey-1")

    def test_allows_access_link_token(self) -> None:
        payload = {
            "surveyId": "survey-1",
            "creatorId": "creator-1",
            "testDate": datetime.now(timezone.utc).isoformat(),
            "screenerId": "screener-1",
            "accessLinkToken": "token-123",
            "patient": {
                "name": "Paciente",
                "email": "paciente@example.com",
                "birthDate": "1990-01-01",
                "gender": "F",
                "ethnicity": "X",
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

        response = SurveyResponse.model_validate(payload)

        self.assertEqual(response.access_link_token, "token-123")
        self.assertIsNotNone(response.patient)

    def test_allows_optional_prompt_key(self) -> None:
        payload = {
            "surveyId": "survey-1",
            "creatorId": "creator-1",
            "testDate": datetime.now(timezone.utc).isoformat(),
            "screenerId": "screener-1",
            "promptKey": "clinical_referral_letter:lapan7",
            "answers": [{"id": 1, "answer": "A"}],
        }

        response = SurveyResponse.model_validate(payload)

        self.assertEqual(response.prompt_key, "clinical_referral_letter:lapan7")


if __name__ == "__main__":
    unittest.main()
