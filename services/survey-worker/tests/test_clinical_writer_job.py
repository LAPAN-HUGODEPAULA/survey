import json
import unittest
from datetime import datetime, timezone
from unittest.mock import patch

from bson import ObjectId

from app.jobs.clinical_writer import ClinicalWriterJob


class ClinicalWriterJobTests(unittest.TestCase):
    def test_build_request_payload_serializes_mongo_values(self) -> None:
        job = ClinicalWriterJob()
        payload = {
            "_id": ObjectId("69b83ece5943fe7eaee68e10"),
            "surveyId": "lapan_q7",
            "promptKey": "survey7",
            "testDate": datetime(2026, 3, 25, 12, 0, tzinfo=timezone.utc),
            "patient": {
                "name": "Patient A-01",
                "email": "patient.a01@example.invalid",
            },
        }

        request_payload = job._build_request_payload(payload)
        content = json.loads(request_payload["content"])

        self.assertEqual(request_payload["input_type"], "survey7")
        self.assertEqual(request_payload["prompt_key"], "survey7")
        self.assertEqual(request_payload["metadata"]["patient_ref"], "patient.a01@example.invalid")
        self.assertEqual(content["_id"], "69b83ece5943fe7eaee68e10")
        self.assertEqual(content["testDate"], "2026-03-25T12:00:00+00:00")

    @patch("app.jobs.clinical_writer.settings.processing_stale_after_seconds", 60)
    def test_build_pending_query_retries_stale_processing_documents(self) -> None:
        fixed_now = datetime(2026, 3, 25, 12, 0, tzinfo=timezone.utc)
        job = ClinicalWriterJob()

        with patch("app.jobs.clinical_writer.datetime") as mock_datetime:
            mock_datetime.now.return_value = fixed_now
            query = job._build_pending_query()

        self.assertEqual(
            query["$or"][-1],
            {
                "agentResponseStatus": "processing",
                "agentResponseUpdatedAt": {
                    "$lt": datetime(2026, 3, 25, 11, 59, tzinfo=timezone.utc)
                },
            },
        )

    def test_normalize_agent_response_keeps_backend_shape(self) -> None:
        job = ClinicalWriterJob()
        agent_payload = {
            "ok": True,
            "input_type": "survey7",
            "prompt_version": "mongo_modifiedAt:2026-03-25T12:00:00+00:00",
            "model_version": "test-model",
            "report": {
                "sections": [
                    {
                        "title": "Resumo",
                        "blocks": [
                            {
                                "type": "paragraph",
                                "spans": [{"text": "Conteudo do laudo."}],
                            }
                        ],
                    }
                ]
            },
            "warnings": ["note"],
        }

        normalized = job._normalize_agent_response(agent_payload)

        self.assertTrue(normalized["ok"])
        self.assertEqual(normalized["warnings"], ["note"])
        self.assertEqual(normalized["medicalRecord"], "Resumo\nConteudo do laudo.")


if __name__ == "__main__":
    unittest.main()
