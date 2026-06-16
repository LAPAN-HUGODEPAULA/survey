import httpx
import pytest
from unittest.mock import AsyncMock

from app.integrations.clinical_writer.client import ClinicalWriterRunClient
from app.integrations.clinical_writer.normalizer import AgentResponseNormalizer
from app.integrations.clinical_writer.resolver import (
    DEFAULT_LANGGRAPH_URL,
    DEFAULT_LOCAL_LANGGRAPH_URL,
)


class _FakeResponse:
    def __init__(self, payload, status_code: int = 200, endpoint: str = DEFAULT_LANGGRAPH_URL) -> None:
        self._payload = payload
        self.status_code = status_code
        self._endpoint = endpoint

    def raise_for_status(self) -> None:
        if self.status_code >= 400:
            raise httpx.HTTPStatusError(
                "upstream error",
                request=httpx.Request("POST", self._endpoint),
                response=self,
            )

    def json(self):
        return self._payload

    @property
    def text(self) -> str:
        return str(self._payload)


class _RecordingRepo:
    def __init__(self) -> None:
        self.created: list[dict] = []

    def create(self, payload: dict) -> None:
        self.created.append(payload)


class _StubResolver:
    def __init__(self, endpoints: list[str] | None = None) -> None:
        self._endpoints = endpoints or [DEFAULT_LANGGRAPH_URL]

    def process_endpoints(self) -> list[str]:
        return list(self._endpoints)

    def validate_url(self, url: str, *extra_allowed_urls: str | None) -> str:
        del extra_allowed_urls
        return url

    def analysis_endpoint(self) -> str:
        return "http://localhost:9566/analysis"

    def transcription_endpoint(self) -> str:
        return "http://localhost:9566/transcriptions"

    def status_endpoints(self, request_id: str) -> list[str]:
        return [f"http://localhost:9566/status/{request_id}"]


class _StubHealthClient:
    def __init__(self, probe_result: dict | None = None) -> None:
        self.probe_result = probe_result or {"reachable": False, "status_code": None}
        self.probes: list[tuple[str, dict[str, str]]] = []

    async def probe_health(self, *, process_endpoint: str, headers: dict[str, str]) -> dict:
        self.probes.append((process_endpoint, headers))
        return self.probe_result

    async def fetch_status(self, request_id: str, *, headers: dict[str, str]) -> dict:
        del request_id, headers
        return {}


class _FakeAsyncClient:
    def __init__(self, responses):
        self._responses = list(responses)
        self.calls: list[tuple[str, dict, dict]] = []

    async def post(self, endpoint: str, *, json: dict, headers: dict):
        self.calls.append((endpoint, json, headers))
        result = self._responses.pop(0)
        if isinstance(result, Exception):
            raise result
        return result

    async def aclose(self) -> None:
        return None


@pytest.mark.asyncio
async def test_send_to_langgraph_agent_falls_back_to_localhost_when_service_host_is_unreachable() -> None:
    http_client = _FakeAsyncClient(
        [
            httpx.ConnectError(
                "Name or service not known",
                request=httpx.Request("POST", DEFAULT_LANGGRAPH_URL),
            ),
            _FakeResponse(
                {
                    "ok": True,
                    "input_type": "survey7",
                    "prompt_version": "v1",
                    "model_version": "test-model",
                    "report": {"sections": []},
                },
                endpoint=DEFAULT_LOCAL_LANGGRAPH_URL,
            ),
        ]
    )
    repo = _RecordingRepo()
    health = _StubHealthClient({"reachable": False, "status_code": None})
    run_client = ClinicalWriterRunClient(
        http_client=http_client,
        run_log_repository=repo,
        resolver=_StubResolver([DEFAULT_LANGGRAPH_URL, DEFAULT_LOCAL_LANGGRAPH_URL]),
        health_client=health,
    )

    result = await run_client.send_to_langgraph_agent({"surveyId": "lapan_q7"})

    assert result.ok is True
    assert [call[0] for call in http_client.calls] == [
        DEFAULT_LANGGRAPH_URL,
        DEFAULT_LOCAL_LANGGRAPH_URL,
    ]
    assert repo.created[-1]["clinical_writer_status"] == "ok"


@pytest.mark.asyncio
async def test_send_to_langgraph_agent_propagates_request_id_header() -> None:
    http_client = _FakeAsyncClient(
        [
            _FakeResponse(
                {
                    "ok": True,
                    "input_type": "survey7",
                    "prompt_version": "v1",
                    "model_version": "test-model",
                    "report": {"sections": []},
                }
            )
        ]
    )
    run_client = ClinicalWriterRunClient(
        http_client=http_client,
        run_log_repository=_RecordingRepo(),
        resolver=_StubResolver(),
    )

    result = await run_client.send_to_langgraph_agent(
        {"surveyId": "lapan_q7"},
        request_id="req-test-123",
    )

    assert result.ok is True
    _, payload, headers = http_client.calls[0]
    assert headers["x-request-id"] == "req-test-123"
    assert payload["metadata"]["request_id"] == "req-test-123"


@pytest.mark.asyncio
async def test_send_to_langgraph_agent_maps_resource_exhausted_error() -> None:
    http_client = _FakeAsyncClient(
        [
            _FakeResponse(
                {
                    "detail": (
                        "Clinical analysis failed: Error calling model "
                        "'gemini-2.5-flash-lite' (RESOURCE_EXHAUSTED): "
                        "Please retry in 33.072173227s."
                    )
                },
                status_code=500,
            )
        ]
    )
    run_client = ClinicalWriterRunClient(
        http_client=http_client,
        run_log_repository=_RecordingRepo(),
        resolver=_StubResolver(),
    )

    result = await run_client.send_to_langgraph_agent({"surveyId": "lapan_q7"})

    assert result.error_message == "AI quota exceeded for clinical analysis"
    assert result.ai_progress["retryable"] is True
    assert "cota de IA" in result.ai_progress["userMessage"]


@pytest.mark.asyncio
async def test_send_to_langgraph_agent_maps_reachable_read_timeout() -> None:
    http_client = _FakeAsyncClient(
        [
            httpx.ReadTimeout(
                "timed out waiting for response",
                request=httpx.Request("POST", DEFAULT_LANGGRAPH_URL),
            )
        ]
    )
    run_client = ClinicalWriterRunClient(
        http_client=http_client,
        run_log_repository=_RecordingRepo(),
        resolver=_StubResolver(),
        health_client=_StubHealthClient({"reachable": True, "status_code": 200, "latency_ms": 20}),
    )

    result = await run_client.send_to_langgraph_agent(
        {"surveyId": "lapan_q7"},
        read_timeout_seconds=0.01,
    )

    assert result.error_message == "AI analysis timed out before completion"
    assert result.ai_progress["retryable"] is True
    assert "demorando" in result.ai_progress["userMessage"]


@pytest.mark.asyncio
async def test_send_to_langgraph_agent_returns_invalid_format_for_non_json_response() -> None:
    http_client = _FakeAsyncClient([_FakeResponse(["not", "an", "object"])])
    run_client = ClinicalWriterRunClient(
        http_client=http_client,
        run_log_repository=_RecordingRepo(),
        resolver=_StubResolver(),
    )

    result = await run_client.send_to_langgraph_agent({"surveyId": "lapan_q7"})

    assert result.error_message == "Invalid agent response format"


@pytest.mark.asyncio
async def test_send_to_langgraph_agent_fills_medical_record_from_partial_report() -> None:
    http_client = _FakeAsyncClient(
        [
            _FakeResponse(
                {
                    "ok": True,
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
                    "warnings": None,
                }
            )
        ]
    )
    run_client = ClinicalWriterRunClient(
        http_client=http_client,
        run_log_repository=_RecordingRepo(),
        resolver=_StubResolver(),
    )

    result = await run_client.send_to_langgraph_agent({"surveyId": "lapan_q7"})

    assert result.medical_record == "Resumo\nConteudo do laudo."
    assert result.warnings == []


def test_pseudonymize_patient_ref_removes_raw_identifier() -> None:
    raw_identifier = "Patient@example.com"
    pseudonymized = AgentResponseNormalizer.pseudonymize_patient_ref(raw_identifier)

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

    inferred = AgentResponseNormalizer().infer_patient_ref(payload)

    assert inferred == AgentResponseNormalizer.pseudonymize_patient_ref("MR-12345")


@pytest.mark.asyncio
async def test_send_analysis_and_transcription_use_resolved_endpoints() -> None:
    http_client = _FakeAsyncClient(
        [
            _FakeResponse({"ok": True}, endpoint="http://localhost:9566/analysis"),
            _FakeResponse({"ok": True}, endpoint="http://localhost:9566/transcriptions"),
        ]
    )
    run_client = ClinicalWriterRunClient(
        http_client=http_client,
        resolver=_StubResolver(),
    )

    analysis = await run_client.send_analysis({"content": "a"})
    transcription = await run_client.send_transcription({"content": "b"})

    assert analysis == {"ok": True}
    assert transcription == {"ok": True}
    assert http_client.calls[0][0] == "http://localhost:9566/analysis"
    assert http_client.calls[1][0] == "http://localhost:9566/transcriptions"


@pytest.mark.asyncio
async def test_fetch_status_delegates_to_health_client() -> None:
    health = _StubHealthClient()
    health.fetch_status = AsyncMock(return_value={"stage": "queued"})
    run_client = ClinicalWriterRunClient(
        http_client=_FakeAsyncClient([]),
        resolver=_StubResolver(),
        health_client=health,
    )

    status = await run_client.fetch_status("req-123")

    assert status == {"stage": "queued"}
    health.fetch_status.assert_awaited_once()


def test_build_request_body_maps_provider_specific_ai_fields() -> None:
    request_body = ClinicalWriterRunClient._build_request_body(
        content="{}",
        input_type="survey7",
        prompt_key="prompt",
        persona_skill_key="persona",
        output_profile="profile",
        ai_config={
            "primaryProvider": "gemini",
            "primaryModel": "gemini-2.5-flash",
            "temperature": 0.3,
            "doSample": True,
            "reasoningEffort": "medium",
            "enableCaching": True,
        },
        system_prompt_override="system",
        format_prompt_override="format",
        source_app="survey-frontend",
        request_id="req-1",
        patient_ref="pt-123",
    )

    assert request_body["gemini_model"] == "gemini-2.5-flash"
    assert request_body["glm_model"] is None
    assert request_body["temperature"] == 0.3
    assert request_body["metadata"]["request_id"] == "req-1"


def test_failure_kind_reports_reachable_error_without_timeout() -> None:
    request = httpx.Request("POST", DEFAULT_LANGGRAPH_URL)
    exc = httpx.ConnectError("failed", request=request)

    assert (
        ClinicalWriterRunClient._failure_kind(exc, {"reachable": True})
        == "reachable_error"
    )
