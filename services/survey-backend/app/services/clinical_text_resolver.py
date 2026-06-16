"""Resolve report text from clinical response payloads."""

from __future__ import annotations

from typing import Any

from lapan_core import ReportTextFormatter


class ClinicalTextResolver:
    """Extract the most relevant clinical text from stored agent payloads."""

    def resolve(self, response: dict[str, Any], override_text: str | None = None) -> str:
        """Prefer explicit overrides and fall back to stored agent artifacts."""
        if override_text and override_text.strip():
            return override_text.strip()

        for payload in self._iter_candidate_payloads(response):
            medical_record = payload.get("medicalRecord") or payload.get("medical_record")
            if isinstance(medical_record, str) and medical_record.strip():
                return medical_record.strip()

            report = payload.get("report")
            if isinstance(report, dict):
                rendered = ReportTextFormatter.to_text(report)
                if rendered and rendered.strip():
                    return rendered.strip()

            error_message = payload.get("errorMessage") or payload.get("error_message")
            if isinstance(error_message, str) and error_message.strip():
                return error_message.strip()

        return ""

    @staticmethod
    def _iter_candidate_payloads(response: dict[str, Any]) -> list[dict[str, Any]]:
        candidate_payloads: list[dict[str, Any]] = []
        primary = response.get("agentResponse")
        if isinstance(primary, dict):
            candidate_payloads.append(primary)

        artifacts = response.get("agentResponses")
        if isinstance(artifacts, list):
            candidate_payloads.extend(
                item for item in artifacts if isinstance(item, dict)
            )
        return candidate_payloads
