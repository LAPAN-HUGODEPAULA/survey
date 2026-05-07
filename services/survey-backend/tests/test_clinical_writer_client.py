import unittest
from unittest.mock import AsyncMock, patch

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


class _ErrorResponse(_FakeResponse):
    def __init__(self, payload: dict, status_code: int, endpoint: str) -> None:
        super().__init__(payload, status_code=status_code)
        self._endpoint = endpoint

    @property
    def text(self) -> str:
        return str(self._payload)

    def raise_for_status(self) -> None:
        if self.status_code >= 400:
            raise httpx.HTTPStatusError(
                "upstream error",
                request=httpx.Request("POST", self._endpoint),
                response=self,
            )


class ClinicalWriterClientTests(unittest.IsolatedAsyncioTestCase):
    async def test_send_to_langgraph_agent_falls_back_to_localhost_when_service_host_is_unreachable(self) -> None:
        calls: list[str] = []

        class _FakeAsyncClient:
            def __init__(self, *, timeout) -> None:
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
            patch(
                "app.integrations.clinical_writer.client._probe_clinical_writer_health",
                new=AsyncMock(return_value={"reachable": False, "status_code": None}),
            ),
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

    async def test_send_to_langgraph_agent_propagates_request_id_header(self) -> None:
        captured: dict[str, dict] = {}

        class _FakeAsyncClient:
            def __init__(self, *, timeout) -> None:
                del timeout

            async def __aenter__(self):
                return self

            async def __aexit__(self, exc_type, exc, tb):
                del exc_type, exc, tb
                return False

            async def post(self, endpoint: str, *, json: dict, headers: dict):
                del endpoint
                captured["json"] = json
                captured["headers"] = headers
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
                {"CLINICAL_WRITER_URL": client.DEFAULT_LANGGRAPH_URL},
                clear=True,
            ),
        ):
            result = await client.send_to_langgraph_agent(
                {"surveyId": "lapan_q7"},
                request_id="req-test-123",
            )

        self.assertTrue(result["ok"])
        self.assertEqual(captured["headers"]["x-request-id"], "req-test-123")
        self.assertEqual(captured["json"]["metadata"]["request_id"], "req-test-123")

    async def test_probe_health_reports_reachable_when_healthz_responds(self) -> None:
        class _ProbeAsyncClient:
            def __init__(self, *, timeout) -> None:
                del timeout

            async def __aenter__(self):
                return self

            async def __aexit__(self, exc_type, exc, tb):
                del exc_type, exc, tb
                return False

            async def get(self, endpoint: str, *, headers: dict):
                del headers
                if endpoint.endswith("/healthz"):
                    return _FakeResponse({"ok": True}, status_code=200)
                raise AssertionError(f"Unexpected probe endpoint: {endpoint}")

        with patch("app.integrations.clinical_writer.client.httpx.AsyncClient", _ProbeAsyncClient):
            probe = await client._probe_clinical_writer_health(
                process_endpoint=client.DEFAULT_LANGGRAPH_URL,
                headers={},
            )

        self.assertTrue(probe["reachable"])
        self.assertEqual(probe["status_code"], 200)
        self.assertTrue(str(probe["endpoint"]).endswith("/healthz"))

    async def test_send_to_langgraph_agent_maps_resource_exhausted_error(self) -> None:
        endpoint = client.DEFAULT_LANGGRAPH_URL

        class _QuotaAsyncClient:
            def __init__(self, *, timeout) -> None:
                del timeout

            async def __aenter__(self):
                return self

            async def __aexit__(self, exc_type, exc, tb):
                del exc_type, exc, tb
                return False

            async def post(self, endpoint: str, *, json: dict, headers: dict):
                del json, headers
                return _ErrorResponse(
                    {
                        "detail": (
                            "Clinical analysis failed: Error calling model "
                            "'gemini-2.5-flash-lite' (RESOURCE_EXHAUSTED): "
                            "Please retry in 33.072173227s."
                        )
                    },
                    status_code=500,
                    endpoint=endpoint,
                )

        with (
            patch("app.integrations.clinical_writer.client.httpx.AsyncClient", _QuotaAsyncClient),
            patch("app.integrations.clinical_writer.client._persist_run_log"),
        ):
            result = await client.send_to_langgraph_agent({"surveyId": "lapan_q7"})

        self.assertEqual(result["error_message"], "AI quota exceeded for clinical analysis")
        self.assertTrue(result["ai_progress"]["retryable"])
        self.assertIn("cota de IA", result["ai_progress"]["userMessage"])

    async def test_send_to_langgraph_agent_maps_reachable_read_timeout(self) -> None:
        endpoint = client.DEFAULT_LANGGRAPH_URL

        class _TimeoutAsyncClient:
            def __init__(self, *, timeout) -> None:
                del timeout

            async def __aenter__(self):
                return self

            async def __aexit__(self, exc_type, exc, tb):
                del exc_type, exc, tb
                return False

            async def post(self, endpoint: str, *, json: dict, headers: dict):
                del json, headers
                raise httpx.ReadTimeout(
                    "timed out waiting for response",
                    request=httpx.Request("POST", endpoint),
                )

        with (
            patch("app.integrations.clinical_writer.client.httpx.AsyncClient", _TimeoutAsyncClient),
            patch("app.integrations.clinical_writer.client._persist_run_log"),
            patch(
                "app.integrations.clinical_writer.client._probe_clinical_writer_health",
                new=AsyncMock(
                    return_value={"reachable": True, "status_code": 200, "latency_ms": 20}
                ),
            ),
        ):
            result = await client.send_to_langgraph_agent({"surveyId": "lapan_q7"}, read_timeout_seconds=0.01)

        self.assertEqual(result["error_message"], "AI analysis timed out before completion")
        self.assertTrue(result["ai_progress"]["retryable"])
        self.assertIn("demorando", result["ai_progress"]["userMessage"])


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
