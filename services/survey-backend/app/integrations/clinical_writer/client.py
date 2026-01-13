"""Service helpers for interacting with the local LangGraph agent."""

import json
from datetime import datetime, timezone
from typing import Any, Dict
import uuid

import httpx

from app.config.logging_config import logger
import os

from app.config.settings import settings
from app.persistence.mongo.client import get_db
from app.persistence.repositories.clinical_writer_run_log_repo import (
    ClinicalWriterRunLogRepository,
)

LANGGRAPH_URL = os.getenv("LANGGRAPH_URL")
DEFAULT_LANGGRAPH_URL = "http://localhost:9566/process"
LANGGRAPH_TOKEN = os.getenv("LANGGRAPH_API_TOKEN")


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


def _normalize_agent_response(payload: Dict[str, Any]) -> Dict[str, Any]:
    if "report" in payload and "medicalRecord" not in payload:
        report_text = _report_to_text(payload.get("report") or {})
        payload["medicalRecord"] = report_text or None
    if "medical_record" in payload and "medicalRecord" not in payload:
        payload["medicalRecord"] = payload["medical_record"]
    if "error_message" in payload and "errorMessage" not in payload:
        payload["errorMessage"] = payload["error_message"]
    return payload


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
    return patient.get("email") or patient.get("name")


async def send_to_langgraph_agent(
    payload: Any,
    *,
    input_type: str | None = None,
    prompt_key: str | None = None,
    source_app: str | None = None,
    patient_ref: str | None = None,
) -> Dict[str, Any]:
    """
    Send a survey response payload to the LangGraph agent and return its result.

    The agent expects a JSON body with a single "content" field containing the
    conversation text or JSON string to process.
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
    resolved_prompt_key = prompt_key or resolved_input_type
    resolved_patient_ref = patient_ref or _infer_patient_ref(payload)
    request_id = str(uuid.uuid4())
    timestamp = datetime.now(timezone.utc)

    request_body = {
        "input_type": resolved_input_type,
        "content": content,
        "locale": "pt-BR",
        "prompt_key": resolved_prompt_key,
        "output_format": "report_json",
        "metadata": {
            "source_app": source_app,
            "request_id": request_id,
            "patient_ref": resolved_patient_ref,
        },
    }

    try:
        endpoint = settings.clinical_writer_url or LANGGRAPH_URL or DEFAULT_LANGGRAPH_URL
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(
                endpoint,
                json=request_body,
                headers=headers,
            )
            response.raise_for_status()
            raw_result: Dict[str, Any] = response.json()
            agent_result: Dict[str, Any] = _normalize_agent_response(raw_result)
            logger.info("LangGraph agent responded successfully.")
            _persist_run_log(
                request_id=request_id,
                timestamp=timestamp,
                input_type=resolved_input_type,
                prompt_key=resolved_prompt_key,
                prompt_version=raw_result.get("prompt_version"),
                model_version=raw_result.get("model_version"),
                source_app=source_app,
                patient_ref=resolved_patient_ref,
                status="ok" if raw_result.get("ok") else "error",
            )
            return agent_result
    except httpx.HTTPStatusError as exc:
        text = exc.response.text if exc.response is not None else str(exc)
        logger.error("LangGraph agent returned an error: %s", text)
        _persist_run_log(
            request_id=request_id,
            timestamp=timestamp,
            input_type=resolved_input_type,
            prompt_key=resolved_prompt_key,
            prompt_version=None,
            model_version=None,
            source_app=source_app,
            patient_ref=resolved_patient_ref,
            status="error",
        )
        return {"error_message": f"Agent error: {text}"}
    except httpx.RequestError as exc:
        logger.error("Failed to reach LangGraph agent: %s", exc)
        _persist_run_log(
            request_id=request_id,
            timestamp=timestamp,
            input_type=resolved_input_type,
            prompt_key=resolved_prompt_key,
            prompt_version=None,
            model_version=None,
            source_app=source_app,
            patient_ref=resolved_patient_ref,
            status="error",
        )
        return {"error_message": "Unable to reach AI agent"}
    except Exception as exc:  # pragma: no cover - guard for unexpected failures
        logger.error("Unexpected error when calling LangGraph agent: %s", exc)
        _persist_run_log(
            request_id=request_id,
            timestamp=timestamp,
            input_type=resolved_input_type,
            prompt_key=resolved_prompt_key,
            prompt_version=None,
            model_version=None,
            source_app=source_app,
            patient_ref=resolved_patient_ref,
            status="error",
        )
        return {"error_message": "Unexpected error contacting AI agent"}


def _persist_run_log(
    *,
    request_id: str,
    timestamp: datetime,
    input_type: str,
    prompt_key: str,
    prompt_version: str | None,
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
                "model_version": model_version,
                "source_app": source_app,
                "patient_ref": patient_ref,
                "clinical_writer_status": status,
            }
        )
    except Exception as exc:  # pragma: no cover - logging should not fail requests
        logger.error("Failed to persist clinical writer run log: %s", exc)
