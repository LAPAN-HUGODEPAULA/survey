"""Endpoint resolution and outbound policy for the Clinical Writer integration."""

from __future__ import annotations

import os

from app.config.settings import settings
from lapan_core import validate_outbound_url

DEFAULT_LANGGRAPH_URL = "http://clinical_writer_agent:8000/process"
DEFAULT_LOCAL_LANGGRAPH_URL = "http://localhost:9566/process"
DEFAULT_LOOPBACK_LANGGRAPH_URL = "http://127.0.0.1:9566/process"
DEFAULT_LANGGRAPH_ANALYSIS_URL = "http://localhost:9566/analysis"
DEFAULT_LANGGRAPH_TRANSCRIPTION_URL = "http://localhost:9566/transcriptions"


class ClinicalWriterEndpointResolver:
    """Resolve Clinical Writer endpoints for local and containerized environments."""

    def __init__(self) -> None:
        self._langgraph_url = os.getenv("LANGGRAPH_URL")

    def process_endpoints(self) -> list[str]:
        configured_env_url = os.getenv("CLINICAL_WRITER_URL")
        configured_endpoint = (
            configured_env_url
            or self._langgraph_url
            or settings.clinical_writer_url
            or DEFAULT_LANGGRAPH_URL
        )
        endpoints = [configured_endpoint]

        if (
            not configured_env_url
            and not self._langgraph_url
            and configured_endpoint == DEFAULT_LANGGRAPH_URL
        ):
            endpoints.extend([DEFAULT_LOCAL_LANGGRAPH_URL, DEFAULT_LOOPBACK_LANGGRAPH_URL])
        elif configured_endpoint == DEFAULT_LOCAL_LANGGRAPH_URL:
            endpoints.append(DEFAULT_LOOPBACK_LANGGRAPH_URL)

        return self._deduplicate(endpoints)

    def status_endpoints(self, request_id: str) -> list[str]:
        return [self.to_status_endpoint(endpoint, request_id) for endpoint in self.process_endpoints()]

    def analysis_endpoint(self) -> str:
        configured = os.getenv("LANGGRAPH_ANALYSIS_URL")
        if not configured and settings.clinical_writer_url:
            configured = settings.clinical_writer_url.replace("/process", "/analysis")
        return configured or DEFAULT_LANGGRAPH_ANALYSIS_URL

    def transcription_endpoint(self) -> str:
        configured = (
            os.getenv("LANGGRAPH_TRANSCRIPTION_URL")
            or settings.clinical_writer_transcription_url
        )
        if not configured and settings.clinical_writer_url:
            configured = settings.clinical_writer_url.replace("/process", "/transcriptions")
        return configured or DEFAULT_LANGGRAPH_TRANSCRIPTION_URL

    def allowed_hosts(self, *extra_urls: str | None) -> list[str]:
        urls = [
            os.getenv("CLINICAL_WRITER_URL"),
            self._langgraph_url,
            settings.clinical_writer_url,
            DEFAULT_LANGGRAPH_URL,
            DEFAULT_LOCAL_LANGGRAPH_URL,
            DEFAULT_LOOPBACK_LANGGRAPH_URL,
            DEFAULT_LANGGRAPH_ANALYSIS_URL,
            DEFAULT_LANGGRAPH_TRANSCRIPTION_URL,
            settings.clinical_writer_transcription_url,
            os.getenv("LANGGRAPH_ANALYSIS_URL"),
            os.getenv("LANGGRAPH_TRANSCRIPTION_URL"),
            *extra_urls,
        ]
        return [url for url in urls if url]

    def validate_url(self, url: str, *extra_allowed_urls: str | None) -> str:
        return validate_outbound_url(
            url,
            self.allowed_hosts(*extra_allowed_urls),
            allow_loopback=not settings.is_production,
        )

    @staticmethod
    def to_base_endpoint(process_endpoint: str) -> str:
        normalized = process_endpoint.rstrip("/")
        if normalized.endswith("/process"):
            return normalized[: -len("/process")]
        return normalized

    @classmethod
    def to_status_endpoint(cls, process_endpoint: str, request_id: str) -> str:
        return f"{cls.to_base_endpoint(process_endpoint)}/status/{request_id}"

    @staticmethod
    def _deduplicate(endpoints: list[str]) -> list[str]:
        deduplicated: list[str] = []
        for endpoint in endpoints:
            if endpoint and endpoint not in deduplicated:
                deduplicated.append(endpoint)
        return deduplicated
