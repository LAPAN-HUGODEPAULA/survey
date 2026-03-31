import unittest
from unittest.mock import patch

import httpx

from app.integrations.clinical_writer import client


class _FakeResponse:
    def __init__(self, payload: dict, status_code: int = 200) -> None:
        self._payload = payload
        self.status_code = status_code

    def raise_for_status(self) -> None:
        return None

    def json(self) -> dict:
        return self._payload


class ClinicalWriterClientTests(unittest.IsolatedAsyncioTestCase):
    async def test_send_to_langgraph_agent_falls_back_to_localhost_when_service_host_is_unreachable(self) -> None:
        calls: list[str] = []

        class _FakeAsyncClient:
            def __init__(self, *, timeout: int) -> None:
                del timeout

            async def __aenter__(self):
                return self

            async def __aexit__(self, exc_type, exc, tb):
                del exc_type, exc, tb
                return False

            async def post(self, endpoint: str, *, json: dict, headers: dict):
                del json, headers
                calls.append(endpoint)
                if endpoint == client.DEFAULT_LANGGRAPH_URL:
                    raise httpx.ConnectError(
                        "Name or service not known",
                        request=httpx.Request("POST", endpoint),
                    )
                return _FakeResponse(
                    {
                        "ok": True,
                        "input_type": "survey7",
                        "prompt_version": "v1",
                        "model_version": "test-model",
                        "report": {"sections": []},
                    }
                )

        with (
            patch("app.integrations.clinical_writer.client.httpx.AsyncClient", _FakeAsyncClient),
            patch("app.integrations.clinical_writer.client._persist_run_log"),
            patch.dict(
                "app.integrations.clinical_writer.client.os.environ",
                {},
                clear=True,
            ),
        ):
            result = await client.send_to_langgraph_agent({"surveyId": "lapan_q7"})

        self.assertTrue(result["ok"])
        self.assertEqual(
            calls,
            [
                client.DEFAULT_LANGGRAPH_URL,
                client.DEFAULT_LOCAL_LANGGRAPH_URL,
            ],
        )


def test_pseudonymize_patient_ref_removes_raw_identifier() -> None:
    raw_identifier = "Patient@example.com"
    pseudonymized = client._pseudonymize_patient_ref(raw_identifier)

    assert pseudonymized is not None
    assert pseudonymized.startswith("pt-")
    assert raw_identifier.lower() not in pseudonymized


def test_infer_patient_ref_prefers_stable_non_pii_identifier() -> None:
    payload = {
        "patient": {
            "medicalRecordId": "MR-12345",
            "email": "patient@example.com",
            "name": "Alice Example",
        }
    }

    inferred = client._infer_patient_ref(payload)

    assert inferred == client._pseudonymize_patient_ref("MR-12345")


if __name__ == "__main__":
    unittest.main()
