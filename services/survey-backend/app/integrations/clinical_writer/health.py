"""Health probing and status polling for the Clinical Writer integration."""

from __future__ import annotations

import time
from typing import Any, Callable

import httpx

from lapan_core import SecurityBoundaryError

from .normalizer import AgentResponseNormalizer
from .resolver import ClinicalWriterEndpointResolver

HEALTH_PROBE_PATHS = ("/healthz", "/")


class ClinicalWriterHealthClient:
    """Provides lightweight health diagnostics and run status polling."""

    def __init__(
        self,
        *,
        resolver: ClinicalWriterEndpointResolver | None = None,
        async_client_factory: Callable[..., httpx.AsyncClient] | None = None,
        normalizer: AgentResponseNormalizer | None = None,
    ) -> None:
        self._resolver = resolver or ClinicalWriterEndpointResolver()
        self._async_client_factory = async_client_factory or httpx.AsyncClient
        self._normalizer = normalizer or AgentResponseNormalizer()

    async def probe_health(
        self,
        *,
        process_endpoint: str,
        headers: dict[str, str],
    ) -> dict[str, Any]:
        base_endpoint = self._resolver.to_base_endpoint(process_endpoint)
        probe_timeout = httpx.Timeout(connect=2.0, read=2.0, write=2.0, pool=2.0)
        last_request_error: Exception | None = None

        async with self._async_client_factory(timeout=probe_timeout) as probe_client:
            for path in HEALTH_PROBE_PATHS:
                probe_endpoint = f"{base_endpoint}{path}"
                started_at = time.monotonic()
                try:
                    self._resolver.validate_url(probe_endpoint, process_endpoint)
                    response = await probe_client.get(probe_endpoint, headers=headers)
                    elapsed_ms = int((time.monotonic() - started_at) * 1000)
                    return {
                        "reachable": True,
                        "status_code": response.status_code,
                        "latency_ms": elapsed_ms,
                        "endpoint": probe_endpoint,
                    }
                except (SecurityBoundaryError, httpx.RequestError) as exc:
                    last_request_error = exc
                    continue

        return {
            "reachable": False,
            "status_code": None,
            "latency_ms": None,
            "endpoint": f"{base_endpoint}{HEALTH_PROBE_PATHS[0]}",
            "error_type": type(last_request_error).__name__ if last_request_error else None,
            "error": str(last_request_error) if last_request_error else None,
        }

    async def fetch_status(
        self,
        request_id: str,
        *,
        headers: dict[str, str],
    ) -> dict[str, Any]:
        last_request_error: httpx.RequestError | None = None

        async with self._async_client_factory(timeout=5) as client:
            for endpoint in self._resolver.status_endpoints(request_id):
                try:
                    validated = self._resolver.validate_url(endpoint)
                    response = await client.get(validated, headers=headers)
                    response.raise_for_status()
                    payload = response.json()
                    if isinstance(payload, dict):
                        progress = payload.get("ai_progress")
                        if isinstance(progress, dict):
                            return self._normalizer.normalize_progress(progress)
                        if "stage" in payload:
                            return self._normalizer.normalize_progress(payload)
                except httpx.RequestError as exc:
                    last_request_error = exc
                except httpx.HTTPStatusError:
                    continue

        if last_request_error is not None:
            raise last_request_error
        return {}
