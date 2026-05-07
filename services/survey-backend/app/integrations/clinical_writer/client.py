"""Service helpers for interacting with the local LangGraph agent."""

import json
import hashlib
from datetime import datetime, timezone
from typing import Any, Dict
import uuid
import time
import re

import httpx

from app.config.logging_config import logger
import os

from app.config.settings import settings
from app.persistence.mongo.client import get_db
from app.persistence.repositories.clinical_writer_run_log_repo import (
    ClinicalWriterRunLogRepository,
)

LANGGRAPH_URL = os.getenv("LANGGRAPH_URL")
DEFAULT_LANGGRAPH_URL = "http://clinical_writer_agent:8000/process"
DEFAULT_LOCAL_LANGGRAPH_URL = "http://localhost:9566/process"
DEFAULT_LOOPBACK_LANGGRAPH_URL = "http://127.0.0.1:9566/process"
DEFAULT_LANGGRAPH_ANALYSIS_URL = "http://localhost:9566/analysis"
DEFAULT_LANGGRAPH_TRANSCRIPTION_URL = "http://localhost:9566/transcriptions"
LANGGRAPH_TOKEN = os.getenv("LANGGRAPH_API_TOKEN")
HEALTH_PROBE_PATHS = ("/healthz", "/")


def _candidate_process_endpoints() -> list[str]:
    """Return process endpoints compatible with container and local development."""
    configured_env_url = os.getenv("CLINICAL_WRITER_URL")
    configured_endpoint = configured_env_url or LANGGRAPH_URL or settings.clinical_writer_url or DEFAULT_LANGGRAPH_URL
    endpoints = [configured_endpoint]

    # When the backend runs locally, the Docker service hostname is not resolvable.
    if not configured_env_url and not LANGGRAPH_URL and configured_endpoint == DEFAULT_LANGGRAPH_URL:
        endpoints.extend([DEFAULT_LOCAL_LANGGRAPH_URL, DEFAULT_LOOPBACK_LANGGRAPH_URL])
    elif configured_endpoint == DEFAULT_LOCAL_LANGGRAPH_URL:
        endpoints.append(DEFAULT_LOOPBACK_LANGGRAPH_URL)

    deduplicated: list[str] = []
    for endpoint in endpoints:
        if endpoint and endpoint not in deduplicated:
            deduplicated.append(endpoint)
    return deduplicated


def _report_to_text(report: Dict[str, Any]) -> str:
    sections = report.get("sections") or []
    lines: list[str] = []
    for section in sections:
        title = section.get("title")
        if title:
            lines.append(str(title))
        for block in section.get("blocks") or []:
            block_type = block.get("type")
            if block_type == "paragraph":
                spans = block.get("spans") or []
                lines.append("".join(span.get("text", "") for span in spans))
            elif block_type == "bullet_list":
                for item in block.get("items") or []:
                    spans = item.get("spans") or []
                    lines.append("- " + "".join(span.get("text", "") for span in spans))
            elif block_type == "key_value":
                for item in block.get("items") or []:
                    key = item.get("key", "")
                    spans = item.get("value") or []
                    value = "".join(span.get("text", "") for span in spans)
                    lines.append(f"{key}: {value}")
    return "\n".join(line for line in lines if line)


def _to_status_endpoint(process_endpoint: str, request_id: str) -> str:
    normalized = process_endpoint.rstrip("/")
    if normalized.endswith("/process"):
        base = normalized[: -len("/process")]
    else:
        base = normalized
    return f"{base}/status/{request_id}"


def _to_base_endpoint(process_endpoint: str) -> str:
    normalized = process_endpoint.rstrip("/")
    if normalized.endswith("/process"):
        base = normalized[: -len("/process")]
    else:
        base = normalized
    return base


def _candidate_status_endpoints(request_id: str) -> list[str]:
    return [_to_status_endpoint(endpoint, request_id) for endpoint in _candidate_process_endpoints()]


async def _probe_clinical_writer_health(
    *,
    process_endpoint: str,
    headers: Dict[str, str],
) -> dict[str, Any]:
    """Check whether the clinical writer service is reachable right now."""
    base_endpoint = _to_base_endpoint(process_endpoint)
    probe_timeout = httpx.Timeout(connect=2.0, read=2.0, write=2.0, pool=2.0)
    last_request_error: httpx.RequestError | None = None

    async with httpx.AsyncClient(timeout=probe_timeout) as probe_client:
        for path in HEALTH_PROBE_PATHS:
            probe_endpoint = f"{base_endpoint}{path}"
            started_at = time.monotonic()
            try:
                response = await probe_client.get(probe_endpoint, headers=headers)
                elapsed_ms = int((time.monotonic() - started_at) * 1000)
                return {
                    "reachable": True,
                    "status_code": response.status_code,
                    "latency_ms": elapsed_ms,
                    "endpoint": probe_endpoint,
                }
            except httpx.RequestError as exc:
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


def _normalize_agent_response(payload: Dict[str, Any]) -> Dict[str, Any]:
    if "report" in payload and "medicalRecord" not in payload:
        report_text = _report_to_text(payload.get("report") or {})
        payload["medicalRecord"] = report_text or None
    if "medical_record" in payload and "medicalRecord" not in payload:
        payload["medicalRecord"] = payload["medical_record"]
    if "error_message" in payload and "errorMessage" not in payload:
        payload["errorMessage"] = payload["error_message"]
    progress = payload.get("ai_progress")
    if isinstance(progress, dict):
        if "user_message" in progress and "userMessage" not in progress:
            progress["userMessage"] = progress["user_message"]
        if "updated_at" in progress and "updatedAt" not in progress:
            progress["updatedAt"] = progress["updated_at"]
        if "stage_label" in progress and "stageLabel" not in progress:
            progress["stageLabel"] = progress["stage_label"]
    return payload


def _extract_upstream_error_detail(exc: httpx.HTTPStatusError) -> str:
    if exc.response is None:
        return ""
    try:
        payload = exc.response.json()
    except Exception:
        payload = None
    if isinstance(payload, dict):
        detail = payload.get("detail")
        if isinstance(detail, str):
            return detail
        error = payload.get("error")
        if isinstance(error, dict):
            message = error.get("message")
            if isinstance(message, str):
                return message
    return exc.response.text if exc.response is not None else ""


def _is_resource_exhausted_error(detail: str) -> bool:
    normalized = detail.upper()
    return "RESOURCE_EXHAUSTED" in normalized or "QUOTA EXCEEDED" in normalized


def _extract_retry_after_seconds(detail: str) -> int | None:
    if not detail:
        return None
    retry_delay_match = re.search(r"retryDelay['\"]?\s*[:=]\s*['\"]?(\d+)\s*s", detail)
    if retry_delay_match:
        return int(retry_delay_match.group(1))
    human_match = re.search(r"Please retry in\s+(\d+(?:\.\d+)?)s", detail, flags=re.IGNORECASE)
    if human_match:
        return int(float(human_match.group(1)))
    return None


def _infer_input_type(payload: Any) -> str:
    if isinstance(payload, str):
        return "consult"
    if isinstance(payload, dict):
        survey_id = payload.get("surveyId") or payload.get("survey_id")
        if survey_id == "lapan_q7":
            return "survey7"
    return "full_intake"


def _infer_patient_ref(payload: Any) -> str | None:
    if not isinstance(payload, dict):
        return None
    patient = payload.get("patient") or {}
    candidate = (
        patient.get("medicalRecordId")
        or patient.get("medical_record_id")
        or patient.get("id")
        or patient.get("_id")
        or patient.get("email")
        or patient.get("name")
    )
    return _pseudonymize_patient_ref(candidate)


def _pseudonymize_patient_ref(patient_ref: str | None) -> str | None:
    """Convert patient identifiers into stable non-reversible trace ids."""
    if not patient_ref:
        return None
    normalized = patient_ref.strip().lower()
    if not normalized:
        return None
    digest = hashlib.sha256(normalized.encode("utf-8")).hexdigest()
    return f"pt-{digest[:16]}"


async def send_to_langgraph_agent(
    payload: Any,
    *,
    input_type: str | None = None,
    prompt_key: str | None = None,
    persona_skill_key: str | None = None,
    output_profile: str | None = None,
    ai_config: Dict[str, Any] | None = None,
    system_prompt_override: str | None = None,
    format_prompt_override: str | None = None,
    source_app: str | None = None,
    patient_ref: str | None = None,
    request_id: str | None = None,
    read_timeout_seconds: float | None = None,
) -> Dict[str, Any]:
    """
    Send a survey response payload to the LangGraph agent and return its result.

    The agent expects a JSON body with the report_json contract, including
    input_type, content, locale, prompt_key, output_format, and metadata.
    """
    if isinstance(payload, str):
        content = payload.strip()
    else:
        try:
            content = json.dumps(payload, default=str)
        except (TypeError, ValueError) as exc:
            logger.warning("Failed to serialize payload for LangGraph agent: %s", exc)
            content = str(payload)

    headers: Dict[str, str] = {}
    token = settings.clinical_writer_token or LANGGRAPH_TOKEN
    if token:
        headers["Authorization"] = f"Bearer {token}"

    resolved_input_type = input_type or _infer_input_type(payload)
    resolved_prompt_key = prompt_key or "default"
    resolved_patient_ref = _pseudonymize_patient_ref(patient_ref) or _infer_patient_ref(payload)
    request_id = request_id or str(uuid.uuid4())
    timestamp = datetime.now(timezone.utc)
    start_time = time.monotonic()
    headers["x-request-id"] = request_id

    # Resolve AI parameters from aiConfig only.
    resolved_ai_provider = None
    resolved_glm_model = None
    resolved_gemini_model = None
    temperature = None
    do_sample = None
    thinking_mode = None
    enable_caching = None

    if ai_config:
        resolved_ai_provider = ai_config.get("primaryProvider") or resolved_ai_provider
        if resolved_ai_provider == "glm":
            resolved_glm_model = ai_config.get("primaryModel") or resolved_glm_model
        elif resolved_ai_provider == "gemini":
            resolved_gemini_model = ai_config.get("primaryModel") or resolved_gemini_model
        
        temperature = ai_config.get("temperature")
        do_sample = ai_config.get("doSample")
        thinking_mode = ai_config.get("reasoningEffort")
        enable_caching = ai_config.get("enableCaching")

    request_body = {
        "input_type": resolved_input_type,
        "content": content,
        "locale": "pt-BR",
        "prompt_key": resolved_prompt_key,
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
            "patient_ref": resolved_patient_ref,
        },
    }

    last_probe_result: dict[str, Any] | None = None
    failed_endpoint: str | None = None
    try:
        endpoints = _candidate_process_endpoints()
        last_request_error: httpx.RequestError | None = None
        resolved_read_timeout = (
            float(read_timeout_seconds)
            if read_timeout_seconds is not None
            else float(settings.clinical_writer_http_timeout_seconds)
        )
        request_timeout = httpx.Timeout(
            connect=30.0,
            read=resolved_read_timeout,
            write=30.0,
            pool=30.0,
        )

        async with httpx.AsyncClient(timeout=request_timeout) as client:
            for endpoint in endpoints:
                try:
                    logger.info(
                        "Sending to clinical writer request_id=%s input_type=%s prompt_key=%s endpoint=%s",
                        request_id,
                        resolved_input_type,
                        resolved_prompt_key,
                        endpoint,
                    )
                    response = await client.post(
                        endpoint,
                        json=request_body,
                        headers=headers,
                    )
                    response.raise_for_status()
                    raw_result: Dict[str, Any] = response.json()
                    agent_result: Dict[str, Any] = _normalize_agent_response(raw_result)
                    duration = time.monotonic() - start_time
                    logger.info(
                        "Clinical writer responded request_id=%s status=%s duration=%.3fs endpoint=%s",
                        request_id,
                        response.status_code,
                        duration,
                        endpoint,
                    )
                    _persist_run_log(
                        request_id=request_id,
                        timestamp=timestamp,
                        input_type=resolved_input_type,
                        prompt_key=resolved_prompt_key,
                        prompt_version=raw_result.get("prompt_version"),
                        questionnaire_prompt_version=raw_result.get("questionnaire_prompt_version"),
                        persona_skill_version=raw_result.get("persona_skill_version"),
                        persona_skill_key=persona_skill_key,
                        output_profile=output_profile,
                        model_version=raw_result.get("model_version"),
                        source_app=source_app,
                        patient_ref=resolved_patient_ref,
                        status="ok" if raw_result.get("ok") else "error",
                    )
                    return agent_result
                except httpx.RequestError as exc:
                    last_request_error = exc
                    failed_endpoint = endpoint
                    last_probe_result = await _probe_clinical_writer_health(
                        process_endpoint=endpoint,
                        headers=headers,
                    )
                    request_error_type = type(exc).__name__
                    failure_kind = (
                        "reachable_slow"
                        if isinstance(exc, httpx.ReadTimeout)
                        and bool(last_probe_result.get("reachable"))
                        else ("reachable_error" if last_probe_result.get("reachable") else "unreachable")
                    )
                    logger.warning(
                        (
                            "Clinical writer request failed request_id=%s endpoint=%s failure_kind=%s "
                            "error_type=%s error=%s probe_reachable=%s probe_status=%s "
                            "probe_latency_ms=%s probe_endpoint=%s"
                        ),
                        request_id,
                        endpoint,
                        failure_kind,
                        request_error_type,
                        exc,
                        last_probe_result.get("reachable"),
                        last_probe_result.get("status_code"),
                        last_probe_result.get("latency_ms"),
                        last_probe_result.get("endpoint"),
                    )

        if last_request_error is not None:
            raise last_request_error
    except httpx.HTTPStatusError as exc:
        duration = time.monotonic() - start_time
        status_code = exc.response.status_code if exc.response is not None else None
        upstream_detail = _extract_upstream_error_detail(exc)
        quota_exhausted = _is_resource_exhausted_error(upstream_detail)
        retryable = quota_exhausted or status_code in {408, 429, 500, 502, 503, 504}
        retry_after_seconds = _extract_retry_after_seconds(upstream_detail)
        logger.error(
            "Clinical writer returned error request_id=%s status=%s duration=%.3fs quota_exhausted=%s retry_after_seconds=%s",
            request_id,
            status_code if status_code is not None else "unknown",
            duration,
            quota_exhausted,
            retry_after_seconds,
        )
        _persist_run_log(
            request_id=request_id,
            timestamp=timestamp,
            input_type=resolved_input_type,
            prompt_key=resolved_prompt_key,
            prompt_version=None,
            questionnaire_prompt_version=None,
            persona_skill_version=None,
            persona_skill_key=persona_skill_key,
            output_profile=output_profile,
            model_version=None,
            source_app=source_app,
            patient_ref=resolved_patient_ref,
            status="error",
        )
        return {
            "error_message": (
                "AI quota exceeded for clinical analysis"
                if quota_exhausted
                else "Agent error: upstream clinical writer rejected the request"
            ),
            "ai_progress": {
                "stage": "reviewing_content",
                "stageLabel": "Revisando conteúdo",
                "percent": 100,
                "status": "failed",
                "severity": "warning" if retryable else "critical",
                "retryable": retryable,
                "userMessage": (
                    (
                        "A cota de IA foi atingida. Tente novamente em alguns minutos."
                        if retry_after_seconds is None
                        else f"A cota de IA foi atingida. Tente novamente em cerca de {retry_after_seconds}s."
                    )
                    if quota_exhausted
                    else (
                        "Não foi possível concluir agora. Tente novamente em alguns instantes."
                        if retryable
                        else "Não conseguimos gerar a análise automática para este caso."
                    )
                ),
            },
        }
    except httpx.RequestError as exc:
        duration = time.monotonic() - start_time
        request_error_type = type(exc).__name__
        failure_kind = (
            "reachable_slow"
            if isinstance(exc, httpx.ReadTimeout)
            and bool((last_probe_result or {}).get("reachable"))
            else (
                "reachable_error"
                if bool((last_probe_result or {}).get("reachable"))
                else "unreachable"
            )
        )
        logger.error(
            (
                "Failed to reach clinical writer request_id=%s duration=%.3fs endpoint=%s "
                "failure_kind=%s error_type=%s error=%s probe_reachable=%s probe_status=%s "
                "probe_latency_ms=%s probe_endpoint=%s"
            ),
            request_id,
            duration,
            failed_endpoint,
            failure_kind,
            request_error_type,
            exc,
            (last_probe_result or {}).get("reachable"),
            (last_probe_result or {}).get("status_code"),
            (last_probe_result or {}).get("latency_ms"),
            (last_probe_result or {}).get("endpoint"),
        )
        _persist_run_log(
            request_id=request_id,
            timestamp=timestamp,
            input_type=resolved_input_type,
            prompt_key=resolved_prompt_key,
            prompt_version=None,
            questionnaire_prompt_version=None,
            persona_skill_version=None,
            persona_skill_key=persona_skill_key,
            output_profile=output_profile,
            model_version=None,
            source_app=source_app,
            patient_ref=resolved_patient_ref,
            status="error",
        )
        return {
            "error_message": (
                "AI analysis timed out before completion"
                if failure_kind == "reachable_slow"
                else "Unable to reach AI agent"
            ),
            "ai_progress": {
                "stage": "reviewing_content",
                "stageLabel": "Revisando conteúdo",
                "percent": 100,
                "status": "failed",
                "severity": "warning",
                "retryable": True,
                "userMessage": (
                    "A análise está demorando mais que o esperado. Tente novamente em instantes."
                    if failure_kind == "reachable_slow"
                    else "Não foi possível concluir agora. Tente novamente em alguns instantes."
                ),
            },
        }
    except Exception as exc:  # pragma: no cover - guard for unexpected failures
        duration = time.monotonic() - start_time
        logger.error(
            "Unexpected error calling clinical writer request_id=%s duration=%.3fs error=%s",
            request_id,
            duration,
            exc,
        )
        _persist_run_log(
            request_id=request_id,
            timestamp=timestamp,
            input_type=resolved_input_type,
            prompt_key=resolved_prompt_key,
            prompt_version=None,
            questionnaire_prompt_version=None,
            persona_skill_version=None,
            persona_skill_key=persona_skill_key,
            output_profile=output_profile,
            model_version=None,
            source_app=source_app,
            patient_ref=resolved_patient_ref,
            status="error",
        )
        return {"error_message": "Unexpected error contacting AI agent"}


async def send_to_langgraph_analysis(payload: Dict[str, Any]) -> Dict[str, Any]:
    """Send analysis request payload to the Clinical Writer analysis endpoint."""
    headers: Dict[str, str] = {}
    token = settings.clinical_writer_token or LANGGRAPH_TOKEN
    if token:
        headers["Authorization"] = f"Bearer {token}"

    configured = os.getenv("LANGGRAPH_ANALYSIS_URL")
    if not configured and settings.clinical_writer_url:
        configured = settings.clinical_writer_url.replace("/process", "/analysis")
    endpoint = configured or DEFAULT_LANGGRAPH_ANALYSIS_URL
    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.post(endpoint, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()


async def fetch_langgraph_status(request_id: str) -> Dict[str, Any]:
    """Fetch stage progress from the clinical writer service."""
    headers: Dict[str, str] = {}
    token = settings.clinical_writer_token or LANGGRAPH_TOKEN
    if token:
        headers["Authorization"] = f"Bearer {token}"

    endpoints = _candidate_status_endpoints(request_id)
    last_request_error: httpx.RequestError | None = None

    async with httpx.AsyncClient(timeout=5) as client:
        for endpoint in endpoints:
            try:
                response = await client.get(endpoint, headers=headers)
                response.raise_for_status()
                payload = response.json()
                if isinstance(payload, dict):
                    progress = payload.get("ai_progress")
                    if isinstance(progress, dict):
                        normalized = _normalize_agent_response({"ai_progress": progress})
                        return normalized.get("ai_progress", {})
                    if "stage" in payload:
                        normalized = _normalize_agent_response({"ai_progress": payload})
                        return normalized.get("ai_progress", {})
            except httpx.RequestError as exc:
                last_request_error = exc
            except httpx.HTTPStatusError:
                continue

    if last_request_error is not None:
        raise last_request_error
    return {}


async def send_to_langgraph_transcription(payload: Dict[str, Any]) -> Dict[str, Any]:
    """Send transcription request payload to the Clinical Writer transcription endpoint."""
    headers: Dict[str, str] = {}
    token = settings.clinical_writer_token or LANGGRAPH_TOKEN
    if token:
        headers["Authorization"] = f"Bearer {token}"

    configured = os.getenv("LANGGRAPH_TRANSCRIPTION_URL") or settings.clinical_writer_transcription_url
    if not configured and settings.clinical_writer_url:
        configured = settings.clinical_writer_url.replace("/process", "/transcriptions")
    endpoint = configured or DEFAULT_LANGGRAPH_TRANSCRIPTION_URL
    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(endpoint, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()


def _persist_run_log(
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
        repo = ClinicalWriterRunLogRepository(get_db())
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
    except Exception as exc:  # pragma: no cover - logging should not fail requests
        logger.error("Failed to persist clinical writer run log: %s", exc)
