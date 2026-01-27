import unittest
from datetime import datetime, timezone

from app.domain.models.survey_response_model import SurveyResponse


class SurveyResponseModelTests(unittest.TestCase):
    def test_allows_missing_patient(self) -> None:
        payload = {
            "surveyId": "survey-1",
            "creatorName": "Creator",
            "creatorContact": "creator@example.com",
            "testDate": datetime.now(timezone.utc).isoformat(),
            "screenerName": "Screener",
            "screenerEmail": "screener@example.com",
            "answers": [{"id": 1, "answer": "A"}],
        }

        response = SurveyResponse.model_validate(payload)

        self.assertIsNone(response.patient)
        self.assertEqual(response.survey_id, "survey-1")

    def test_allows_patient_payload(self) -> None:
        payload = {
            "surveyId": "survey-1",
            "creatorName": "Creator",
            "creatorContact": "creator@example.com",
            "testDate": datetime.now(timezone.utc).isoformat(),
            "screenerName": "Screener",
            "screenerEmail": "screener@example.com",
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

        self.assertIsNotNone(response.patient)
        self.assertEqual(response.patient.name, "Paciente")


if __name__ == "__main__":
    unittest.main()
