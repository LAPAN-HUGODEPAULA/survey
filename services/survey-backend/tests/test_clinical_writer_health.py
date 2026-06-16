import httpx
import pytest

from app.integrations.clinical_writer.health import ClinicalWriterHealthClient
from app.integrations.clinical_writer.resolver import DEFAULT_LANGGRAPH_URL


class _FakeResponse:
    def __init__(self, payload: dict, status_code: int = 200) -> None:
        self._payload = payload
        self.status_code = status_code

    def raise_for_status(self) -> None:
        return None

    def json(self) -> dict:
        return self._payload


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


class _NoRequestClient:
    def __init__(self, *, timeout) -> None:
        del timeout

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc, tb):
        del exc_type, exc, tb
        return False

    async def get(self, endpoint: str, *, headers: dict):
        del endpoint, headers
        raise AssertionError("Unexpected outbound probe")


class _StatusAsyncClient:
    def __init__(self, *, timeout) -> None:
        del timeout

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc, tb):
        del exc_type, exc, tb
        return False

    async def get(self, endpoint: str, *, headers: dict):
        del headers
        if endpoint.endswith("/status/req-1"):
            return _FakeResponse(
                {
                    "ai_progress": {
                        "user_message": "Processando",
                        "stage_label": "Analisando",
                    }
                }
            )
        raise AssertionError(f"Unexpected status endpoint: {endpoint}")


class _StatusErrorResponse(_FakeResponse):
    def raise_for_status(self) -> None:
        raise httpx.HTTPStatusError(
            "upstream error",
            request=httpx.Request("GET", "http://localhost/status/req-1"),
            response=httpx.Response(503, request=httpx.Request("GET", "http://localhost/status/req-1")),
        )


@pytest.mark.asyncio
async def test_probe_health_reports_reachable_when_healthz_responds() -> None:
    health = ClinicalWriterHealthClient(async_client_factory=_ProbeAsyncClient)

    probe = await health.probe_health(process_endpoint=DEFAULT_LANGGRAPH_URL, headers={})

    assert probe["reachable"] is True
    assert probe["status_code"] == 200
    assert str(probe["endpoint"]).endswith("/healthz")


@pytest.mark.asyncio
async def test_probe_health_rejects_metadata_endpoint_without_request() -> None:
    health = ClinicalWriterHealthClient(async_client_factory=_NoRequestClient)

    probe = await health.probe_health(
        process_endpoint="http://169.254.169.254/process",
        headers={},
    )

    assert probe["reachable"] is False
    assert probe["error_type"] == "SecurityBoundaryError"


@pytest.mark.asyncio
async def test_fetch_status_normalizes_ai_progress_payload() -> None:
    health = ClinicalWriterHealthClient(async_client_factory=_StatusAsyncClient)

    status = await health.fetch_status("req-1", headers={})

    assert status["userMessage"] == "Processando"
    assert status["stageLabel"] == "Analisando"


@pytest.mark.asyncio
async def test_fetch_status_returns_empty_when_only_http_errors_occur() -> None:
    class _HttpErrorClient:
        def __init__(self, *, timeout) -> None:
            del timeout

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb):
            del exc_type, exc, tb
            return False

        async def get(self, endpoint: str, *, headers: dict):
            del endpoint, headers
            response = httpx.Response(503, request=httpx.Request("GET", "http://localhost/status/req-1"))
            raise httpx.HTTPStatusError("bad status", request=response.request, response=response)

    health = ClinicalWriterHealthClient(async_client_factory=_HttpErrorClient)

    status = await health.fetch_status("req-1", headers={})

    assert status == {}
