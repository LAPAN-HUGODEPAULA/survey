"""Response normalization and retry classification for Clinical Writer payloads."""

from __future__ import annotations

import hashlib
import re
from typing import Any

import httpx

from app.domain.models.agent_response_model import AgentResponse
from lapan_core import ReportTextFormatter


class AgentResponseNormalizer:
    """Normalize upstream payloads into the backend AgentResponse shape."""

    def normalize_agent_response(self, payload: dict[str, Any]) -> AgentResponse:
        normalized = dict(payload)
        if "report" in normalized and "medicalRecord" not in normalized:
            report_text = ReportTextFormatter.to_text(normalized.get("report"))
            normalized["medicalRecord"] = report_text or None
        if "medical_record" in normalized and "medicalRecord" not in normalized:
            normalized["medicalRecord"] = normalized["medical_record"]
        if "error_message" in normalized and "errorMessage" not in normalized:
            normalized["errorMessage"] = normalized["error_message"]
        progress = normalized.get("ai_progress")
        if isinstance(progress, dict):
            normalized["aiProgress"] = self.normalize_progress(progress)
            normalized.pop("ai_progress", None)
        if not isinstance(normalized.get("warnings"), list):
            normalized["warnings"] = []
        return AgentResponse.model_validate(normalized)

    def normalize_progress(self, progress: dict[str, Any]) -> dict[str, Any]:
        normalized = dict(progress)
        if "user_message" in normalized and "userMessage" not in normalized:
            normalized["userMessage"] = normalized["user_message"]
        if "updated_at" in normalized and "updatedAt" not in normalized:
            normalized["updatedAt"] = normalized["updated_at"]
        if "stage_label" in normalized and "stageLabel" not in normalized:
            normalized["stageLabel"] = normalized["stage_label"]
        return normalized

    @staticmethod
    def extract_upstream_error_detail(exc: httpx.HTTPStatusError) -> str:
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

    @staticmethod
    def is_resource_exhausted_error(detail: str) -> bool:
        normalized = detail.upper()
        return "RESOURCE_EXHAUSTED" in normalized or "QUOTA EXCEEDED" in normalized

    @staticmethod
    def extract_retry_after_seconds(detail: str) -> int | None:
        if not detail:
            return None
        retry_delay_match = re.search(r"retryDelay['\"]?\s*[:=]\s*['\"]?(\d+)\s*s", detail)
        if retry_delay_match:
            return int(retry_delay_match.group(1))
        human_match = re.search(
            r"Please retry in\s+(\d+(?:\.\d+)?)s",
            detail,
            flags=re.IGNORECASE,
        )
        if human_match:
            return int(float(human_match.group(1)))
        return None

    def request_error_response(
        self,
        *,
        exc: httpx.RequestError,
        probe_result: dict[str, Any] | None,
    ) -> AgentResponse:
        failure_kind = (
            "reachable_slow"
            if isinstance(exc, httpx.ReadTimeout) and bool((probe_result or {}).get("reachable"))
            else (
                "reachable_error"
                if bool((probe_result or {}).get("reachable"))
                else "unreachable"
            )
        )
        return AgentResponse(
            errorMessage=(
                "AI analysis timed out before completion"
                if failure_kind == "reachable_slow"
                else "Unable to reach AI agent"
            ),
            aiProgress={
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
        )

    def status_error_response(self, exc: httpx.HTTPStatusError) -> AgentResponse:
        status_code = exc.response.status_code if exc.response is not None else None
        upstream_detail = self.extract_upstream_error_detail(exc)
        quota_exhausted = self.is_resource_exhausted_error(upstream_detail)
        retryable = quota_exhausted or status_code in {408, 429, 500, 502, 503, 504}
        retry_after_seconds = self.extract_retry_after_seconds(upstream_detail)
        return AgentResponse(
            errorMessage=(
                "AI quota exceeded for clinical analysis"
                if quota_exhausted
                else "Agent error: upstream clinical writer rejected the request"
            ),
            aiProgress={
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
        )

    @staticmethod
    def infer_input_type(payload: Any) -> str:
        if isinstance(payload, str):
            return "consult"
        if isinstance(payload, dict):
            survey_id = payload.get("surveyId") or payload.get("survey_id")
            if survey_id == "lapan_q7":
                return "survey7"
        return "full_intake"

    def infer_patient_ref(self, payload: Any) -> str | None:
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
        return self.pseudonymize_patient_ref(candidate)

    @staticmethod
    def pseudonymize_patient_ref(patient_ref: str | None) -> str | None:
        if not patient_ref:
            return None
        normalized = patient_ref.strip().lower()
        if not normalized:
            return None
        digest = hashlib.sha256(normalized.encode("utf-8")).hexdigest()
        return f"pt-{digest[:16]}"
