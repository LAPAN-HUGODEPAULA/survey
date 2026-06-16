"""Service helpers for interacting with the Clinical Writer agent."""

from __future__ import annotations

import json
import os
import time
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Callable

import httpx

from app.config.logging_config import logger
from app.config.settings import settings
from app.domain.models.agent_response_model import AgentResponse
from app.persistence.mongo.client import get_db
from app.persistence.repositories.clinical_writer_run_log_repo import (
    ClinicalWriterRunLogRepository,
)

from .health import ClinicalWriterHealthClient
from .normalizer import AgentResponseNormalizer
from .resolver import ClinicalWriterEndpointResolver

LANGGRAPH_TOKEN = os.getenv("LANGGRAPH_API_TOKEN")


@dataclass
class _RunContext:
    content: str
    headers: dict[str, str]
    input_type: str
    prompt_key: str
    persona_skill_key: str | None
    output_profile: str | None
    source_app: str | None
    patient_ref: str | None
    request_id: str
    timestamp: datetime
    start_time: float
    request_body: dict[str, Any]


class ClinicalWriterRunClient:
    """Orchestrates submission, retries, normalization, and run logging."""

    def __init__(
        self,
        *,
        http_client: httpx.AsyncClient | Any | None = None,
        async_client_factory: Callable[..., httpx.AsyncClient] | None = None,
        run_log_repository: ClinicalWriterRunLogRepository | None = None,
        resolver: ClinicalWriterEndpointResolver | None = None,
        health_client: ClinicalWriterHealthClient | None = None,
        normalizer: AgentResponseNormalizer | None = None,
    ) -> None:
        self._http_client = http_client
        self._async_client_factory = async_client_factory or httpx.AsyncClient
        self._run_log_repository = run_log_repository
        self._resolver = resolver or ClinicalWriterEndpointResolver()
        self._normalizer = normalizer or AgentResponseNormalizer()
        self._health_client = health_client or ClinicalWriterHealthClient(
            resolver=self._resolver,
            async_client_factory=self._async_client_factory,
            normalizer=self._normalizer,
        )

    async def send_to_langgraph_agent(
        self,
        payload: Any,
        *,
        input_type: str | None = None,
        prompt_key: str | None = None,
        persona_skill_key: str | None = None,
        output_profile: str | None = None,
        ai_config: dict[str, Any] | None = None,
        system_prompt_override: str | None = None,
        format_prompt_override: str | None = None,
        source_app: str | None = None,
        patient_ref: str | None = None,
        request_id: str | None = None,
        read_timeout_seconds: float | None = None,
    ) -> AgentResponse:
        context = self._build_run_context(
            payload=payload,
            input_type=input_type,
            prompt_key=prompt_key,
            persona_skill_key=persona_skill_key,
            output_profile=output_profile,
            ai_config=ai_config,
            system_prompt_override=system_prompt_override,
            format_prompt_override=format_prompt_override,
            source_app=source_app,
            patient_ref=patient_ref,
            request_id=request_id,
        )
        try:
            return await self._send_with_fallback(context, read_timeout_seconds)
        except httpx.HTTPStatusError as exc:
            return self._handle_http_status_error(context, exc)
        except httpx.RequestError as exc:
            return self._handle_request_error(context, exc, None, None)
        except ValueError as exc:
            return self._handle_invalid_response(context, exc)
        except Exception as exc:  # pragma: no cover
            return self._handle_unexpected_error(context, exc)

    async def send_analysis(self, payload: dict[str, Any]) -> dict[str, Any]:
        headers = self._build_headers()
        endpoint = self._resolver.validate_url(self._resolver.analysis_endpoint())
        async with self._request_client(timeout=10) as client:
            response = await client.post(endpoint, json=payload, headers=headers)
            response.raise_for_status()
            return response.json()

    async def fetch_status(self, request_id: str) -> dict[str, Any]:
        return await self._health_client.fetch_status(
            request_id,
            headers=self._build_headers(),
        )

    async def send_transcription(self, payload: dict[str, Any]) -> dict[str, Any]:
        headers = self._build_headers()
        endpoint = self._resolver.validate_url(self._resolver.transcription_endpoint())
        async with self._request_client(timeout=30) as client:
            response = await client.post(endpoint, json=payload, headers=headers)
            response.raise_for_status()
            return response.json()

    def _build_headers(self) -> dict[str, str]:
        headers: dict[str, str] = {}
        token = settings.clinical_writer_token or LANGGRAPH_TOKEN
        if token:
            headers["Authorization"] = f"Bearer {token}"
        return headers

    def _build_run_context(
        self,
        *,
        payload: Any,
        input_type: str | None,
        prompt_key: str | None,
        persona_skill_key: str | None,
        output_profile: str | None,
        ai_config: dict[str, Any] | None,
        system_prompt_override: str | None,
        format_prompt_override: str | None,
        source_app: str | None,
        patient_ref: str | None,
        request_id: str | None,
    ) -> _RunContext:
        content = self._serialize_content(payload)
        headers = self._build_headers()
        resolved_input_type = input_type or self._normalizer.infer_input_type(payload)
        resolved_prompt_key = prompt_key or "default"
        resolved_patient_ref = (
            self._normalizer.pseudonymize_patient_ref(patient_ref)
            or self._normalizer.infer_patient_ref(payload)
        )
        resolved_request_id = request_id or str(uuid.uuid4())
        headers["x-request-id"] = resolved_request_id
        return _RunContext(
            content=content,
            headers=headers,
            input_type=resolved_input_type,
            prompt_key=resolved_prompt_key,
            persona_skill_key=persona_skill_key,
            output_profile=output_profile,
            source_app=source_app,
            patient_ref=resolved_patient_ref,
            request_id=resolved_request_id,
            timestamp=datetime.now(timezone.utc),
            start_time=time.monotonic(),
            request_body=self._build_request_body(
                content=content,
                input_type=resolved_input_type,
                prompt_key=resolved_prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
                ai_config=ai_config,
                system_prompt_override=system_prompt_override,
                format_prompt_override=format_prompt_override,
                source_app=source_app,
                request_id=resolved_request_id,
                patient_ref=resolved_patient_ref,
            ),
        )

    @staticmethod
    def _serialize_content(payload: Any) -> str:
        if isinstance(payload, str):
            return payload.strip()
        try:
            return json.dumps(payload, default=str)
        except (TypeError, ValueError) as exc:
            logger.warning("Failed to serialize payload for LangGraph agent: %s", exc)
            return str(payload)

    @staticmethod
    def _build_request_body(
        *,
        content: str,
        input_type: str,
        prompt_key: str,
        persona_skill_key: str | None,
        output_profile: str | None,
        ai_config: dict[str, Any] | None,
        system_prompt_override: str | None,
        format_prompt_override: str | None,
        source_app: str | None,
        request_id: str,
        patient_ref: str | None,
    ) -> dict[str, Any]:
        resolved_ai_provider = None
        resolved_glm_model = None
        resolved_gemini_model = None
        temperature = None
        do_sample = None
        thinking_mode = None
        enable_caching = None

        if ai_config:
            resolved_ai_provider = ai_config.get("primaryProvider")
            if resolved_ai_provider == "glm":
                resolved_glm_model = ai_config.get("primaryModel")
            elif resolved_ai_provider == "gemini":
                resolved_gemini_model = ai_config.get("primaryModel")
            temperature = ai_config.get("temperature")
            do_sample = ai_config.get("doSample")
            thinking_mode = ai_config.get("reasoningEffort")
            enable_caching = ai_config.get("enableCaching")

        return {
            "input_type": input_type,
            "content": content,
            "locale": "pt-BR",
            "prompt_key": prompt_key,
            "persona_skill_key": persona_skill_key,
            "output_profile": output_profile,
            "aiConfig": ai_config,
            "ai_provider": resolved_ai_provider,
            "glm_model": resolved_glm_model,
            "gemini_model": resolved_gemini_model,
            "system_prompt_override": system_prompt_override,
            "format_prompt_override": format_prompt_override,
            "temperature": temperature,
            "do_sample": do_sample,
            "thinking_mode": thinking_mode,
            "enable_caching": enable_caching,
            "output_format": "report_json",
            "metadata": {
                "source_app": source_app,
                "request_id": request_id,
                "patient_ref": patient_ref,
            },
        }

    def _request_client(self, *, timeout: httpx.Timeout | int) -> "_AsyncClientContext":
        if self._http_client is not None:
            return _AsyncClientContext(self._http_client, close_on_exit=False)
        return _AsyncClientContext(
            self._async_client_factory(timeout=timeout),
            close_on_exit=True,
        )

    async def _send_with_fallback(
        self,
        context: _RunContext,
        read_timeout_seconds: float | None,
    ) -> AgentResponse:
        last_request_error: httpx.RequestError | None = None
        last_probe_result: dict[str, Any] | None = None
        failed_endpoint: str | None = None
        request_timeout = self._request_timeout(read_timeout_seconds)

        async with self._request_client(timeout=request_timeout) as client:
            for endpoint in self._resolver.process_endpoints():
                try:
                    return await self._send_once(client, endpoint, context)
                except httpx.RequestError as exc:
                    last_request_error = exc
                    failed_endpoint = endpoint
                    last_probe_result = await self._probe_and_log_failure(context, endpoint, exc)

        if last_request_error is not None:
            return self._handle_request_error(
                context,
                last_request_error,
                failed_endpoint,
                last_probe_result,
            )
        raise ValueError("Clinical writer request attempted no endpoints")

    async def _send_once(
        self,
        client: Any,
        endpoint: str,
        context: _RunContext,
    ) -> AgentResponse:
        validated_endpoint = self._resolver.validate_url(endpoint)
        logger.info(
            "Sending to clinical writer request_id=%s input_type=%s prompt_key=%s endpoint=%s",
            context.request_id,
            context.input_type,
            context.prompt_key,
            validated_endpoint,
        )
        response = await client.post(
            validated_endpoint,
            json=context.request_body,
            headers=context.headers,
        )
        response.raise_for_status()
        raw_result = response.json()
        if not isinstance(raw_result, dict):
            raise ValueError("Clinical writer returned non-object JSON")
        agent_result = self._normalizer.normalize_agent_response(raw_result)
        self._log_success(context, validated_endpoint, response.status_code, raw_result)
        return agent_result

    async def _probe_and_log_failure(
        self,
        context: _RunContext,
        endpoint: str,
        exc: httpx.RequestError,
    ) -> dict[str, Any]:
        probe_result = await self._health_client.probe_health(
            process_endpoint=endpoint,
            headers=context.headers,
        )
        logger.warning(
            (
                "Clinical writer request failed request_id=%s endpoint=%s failure_kind=%s "
                "error_type=%s error=%s probe_reachable=%s probe_status=%s "
                "probe_latency_ms=%s probe_endpoint=%s"
            ),
            context.request_id,
            endpoint,
            self._failure_kind(exc, probe_result),
            type(exc).__name__,
            exc,
            probe_result.get("reachable"),
            probe_result.get("status_code"),
            probe_result.get("latency_ms"),
            probe_result.get("endpoint"),
        )
        return probe_result

    @staticmethod
    def _request_timeout(read_timeout_seconds: float | None) -> httpx.Timeout:
        resolved_read_timeout = (
            float(read_timeout_seconds)
            if read_timeout_seconds is not None
            else float(settings.clinical_writer_http_timeout_seconds)
        )
        return httpx.Timeout(
            connect=30.0,
            read=resolved_read_timeout,
            write=30.0,
            pool=30.0,
        )

    def _log_success(
        self,
        context: _RunContext,
        endpoint: str,
        status_code: int,
        raw_result: dict[str, Any],
    ) -> None:
        duration = time.monotonic() - context.start_time
        logger.info(
            "Clinical writer responded request_id=%s status=%s duration=%.3fs endpoint=%s",
            context.request_id,
            status_code,
            duration,
            endpoint,
        )
        self._persist_run_log(
            request_id=context.request_id,
            timestamp=context.timestamp,
            input_type=context.input_type,
            prompt_key=context.prompt_key,
            prompt_version=raw_result.get("prompt_version"),
            questionnaire_prompt_version=raw_result.get("questionnaire_prompt_version"),
            persona_skill_version=raw_result.get("persona_skill_version"),
            persona_skill_key=context.persona_skill_key,
            output_profile=context.output_profile,
            model_version=raw_result.get("model_version"),
            source_app=context.source_app,
            patient_ref=context.patient_ref,
            status="ok" if raw_result.get("ok") else "error",
        )

    def _handle_http_status_error(
        self,
        context: _RunContext,
        exc: httpx.HTTPStatusError,
    ) -> AgentResponse:
        duration = time.monotonic() - context.start_time
        detail = self._normalizer.extract_upstream_error_detail(exc)
        quota_exhausted = self._normalizer.is_resource_exhausted_error(detail)
        retry_after_seconds = self._normalizer.extract_retry_after_seconds(detail)
        logger.error(
            "Clinical writer returned error request_id=%s status=%s duration=%.3fs quota_exhausted=%s retry_after_seconds=%s",
            context.request_id,
            exc.response.status_code if exc.response is not None else "unknown",
            duration,
            quota_exhausted,
            retry_after_seconds,
        )
        self._persist_error_log(
            request_id=context.request_id,
            timestamp=context.timestamp,
            input_type=context.input_type,
            prompt_key=context.prompt_key,
            persona_skill_key=context.persona_skill_key,
            output_profile=context.output_profile,
            source_app=context.source_app,
            patient_ref=context.patient_ref,
        )
        return self._normalizer.status_error_response(exc)

    def _handle_request_error(
        self,
        context: _RunContext,
        exc: httpx.RequestError,
        endpoint: str | None,
        probe_result: dict[str, Any] | None,
    ) -> AgentResponse:
        duration = time.monotonic() - context.start_time
        logger.error(
            (
                "Failed to reach clinical writer request_id=%s duration=%.3fs endpoint=%s "
                "failure_kind=%s error_type=%s error=%s probe_reachable=%s probe_status=%s "
                "probe_latency_ms=%s probe_endpoint=%s"
            ),
            context.request_id,
            duration,
            endpoint,
            self._failure_kind(exc, probe_result),
            type(exc).__name__,
            exc,
            (probe_result or {}).get("reachable"),
            (probe_result or {}).get("status_code"),
            (probe_result or {}).get("latency_ms"),
            (probe_result or {}).get("endpoint"),
        )
        self._persist_error_log(
            request_id=context.request_id,
            timestamp=context.timestamp,
            input_type=context.input_type,
            prompt_key=context.prompt_key,
            persona_skill_key=context.persona_skill_key,
            output_profile=context.output_profile,
            source_app=context.source_app,
            patient_ref=context.patient_ref,
        )
        return self._normalizer.request_error_response(exc=exc, probe_result=probe_result)

    def _handle_invalid_response(
        self,
        context: _RunContext,
        exc: ValueError,
    ) -> AgentResponse:
        duration = time.monotonic() - context.start_time
        logger.error(
            "Invalid clinical writer response request_id=%s duration=%.3fs error=%s",
            context.request_id,
            duration,
            exc,
        )
        self._persist_error_log(
            request_id=context.request_id,
            timestamp=context.timestamp,
            input_type=context.input_type,
            prompt_key=context.prompt_key,
            persona_skill_key=context.persona_skill_key,
            output_profile=context.output_profile,
            source_app=context.source_app,
            patient_ref=context.patient_ref,
        )
        return AgentResponse(errorMessage="Invalid agent response format")

    def _handle_unexpected_error(
        self,
        context: _RunContext,
        exc: Exception,
    ) -> AgentResponse:
        duration = time.monotonic() - context.start_time
        logger.error(
            "Unexpected error calling clinical writer request_id=%s duration=%.3fs error=%s",
            context.request_id,
            duration,
            exc,
        )
        self._persist_error_log(
            request_id=context.request_id,
            timestamp=context.timestamp,
            input_type=context.input_type,
            prompt_key=context.prompt_key,
            persona_skill_key=context.persona_skill_key,
            output_profile=context.output_profile,
            source_app=context.source_app,
            patient_ref=context.patient_ref,
        )
        return AgentResponse(errorMessage="Unexpected error contacting AI agent")

    @staticmethod
    def _failure_kind(
        exc: httpx.RequestError,
        probe_result: dict[str, Any] | None,
    ) -> str:
        if isinstance(exc, httpx.ReadTimeout) and bool((probe_result or {}).get("reachable")):
            return "reachable_slow"
        if bool((probe_result or {}).get("reachable")):
            return "reachable_error"
        return "unreachable"

    def _persist_error_log(
        self,
        *,
        request_id: str,
        timestamp: datetime,
        input_type: str,
        prompt_key: str,
        persona_skill_key: str | None,
        output_profile: str | None,
        source_app: str | None,
        patient_ref: str | None,
    ) -> None:
        self._persist_run_log(
            request_id=request_id,
            timestamp=timestamp,
            input_type=input_type,
            prompt_key=prompt_key,
            prompt_version=None,
            questionnaire_prompt_version=None,
            persona_skill_version=None,
            persona_skill_key=persona_skill_key,
            output_profile=output_profile,
            model_version=None,
            source_app=source_app,
            patient_ref=patient_ref,
            status="error",
        )

    def _persist_run_log(
        self,
        *,
        request_id: str,
        timestamp: datetime,
        input_type: str,
        prompt_key: str,
        prompt_version: str | None,
        questionnaire_prompt_version: str | None,
        persona_skill_version: str | None,
        persona_skill_key: str | None,
        output_profile: str | None,
        model_version: str | None,
        source_app: str | None,
        patient_ref: str | None,
        status: str,
    ) -> None:
        try:
            repo = self._run_log_repository or ClinicalWriterRunLogRepository(get_db())
            repo.create(
                {
                    "request_id": request_id,
                    "timestamp": timestamp,
                    "input_type": input_type,
                    "prompt_key": prompt_key,
                    "prompt_version": prompt_version,
                    "questionnaire_prompt_version": questionnaire_prompt_version,
                    "persona_skill_version": persona_skill_version,
                    "persona_skill_key": persona_skill_key,
                    "output_profile": output_profile,
                    "model_version": model_version,
                    "source_app": source_app,
                    "patient_ref": patient_ref,
                    "clinical_writer_status": status,
                }
            )
        except Exception as exc:  # pragma: no cover
            logger.error("Failed to persist clinical writer run log: %s", exc)


class _AsyncClientContext:
    def __init__(self, client: Any, *, close_on_exit: bool) -> None:
        self._client = client
        self._close_on_exit = close_on_exit

    async def __aenter__(self) -> Any:
        return self._client

    async def __aexit__(self, exc_type, exc, tb) -> bool:
        del exc_type, exc, tb
        if self._close_on_exit and hasattr(self._client, "aclose"):
            await self._client.aclose()
        return False


def _default_run_client() -> ClinicalWriterRunClient:
    return ClinicalWriterRunClient()


async def send_to_langgraph_agent(
    payload: Any,
    *,
    input_type: str | None = None,
    prompt_key: str | None = None,
    persona_skill_key: str | None = None,
    output_profile: str | None = None,
    ai_config: dict[str, Any] | None = None,
    system_prompt_override: str | None = None,
    format_prompt_override: str | None = None,
    source_app: str | None = None,
    patient_ref: str | None = None,
    request_id: str | None = None,
    read_timeout_seconds: float | None = None,
) -> AgentResponse:
    return await _default_run_client().send_to_langgraph_agent(
        payload,
        input_type=input_type,
        prompt_key=prompt_key,
        persona_skill_key=persona_skill_key,
        output_profile=output_profile,
        ai_config=ai_config,
        system_prompt_override=system_prompt_override,
        format_prompt_override=format_prompt_override,
        source_app=source_app,
        patient_ref=patient_ref,
        request_id=request_id,
        read_timeout_seconds=read_timeout_seconds,
    )


async def send_to_langgraph_analysis(payload: dict[str, Any]) -> dict[str, Any]:
    return await _default_run_client().send_analysis(payload)


async def fetch_langgraph_status(request_id: str) -> dict[str, Any]:
    return await _default_run_client().fetch_status(request_id)


async def send_to_langgraph_transcription(payload: dict[str, Any]) -> dict[str, Any]:
    return await _default_run_client().send_transcription(payload)
