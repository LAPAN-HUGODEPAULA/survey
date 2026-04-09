"""Shared helpers for layered orchestration nodes."""

from __future__ import annotations

import json
import re
from typing import Any, Protocol

from ..agent_config import AgentConfig
from ..report_models import ReportDocument


class LLMClient(Protocol):
    """Protocol shared by injectable LLM doubles and runtime routers."""

    def invoke(self, prompt: str) -> Any:
        """Execute a single model invocation."""


def parse_json_object(raw: str) -> dict[str, Any]:
    """Extract a JSON object from a raw LLM response."""
    cleaned = raw.strip()
    if not cleaned:
        raise ValueError("Model response is empty.")

    fenced_match = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", cleaned, re.DOTALL)
    if fenced_match:
        cleaned = fenced_match.group(1).strip()
    else:
        first_brace = cleaned.find("{")
        last_brace = cleaned.rfind("}")
        if first_brace != -1 and last_brace != -1 and last_brace > first_brace:
            cleaned = cleaned[first_brace : last_brace + 1].strip()

    try:
        payload = json.loads(cleaned)
    except json.JSONDecodeError as exc:
        preview = cleaned[:200].replace("\n", " ")
        raise ValueError(
            f"Model response is not valid JSON: {exc}. Start: '{preview}'"
        ) from exc

    if not isinstance(payload, dict):
        raise ValueError("Model response must be a JSON object.")

    return payload


def resolve_model_version(llm_model: Any) -> str:
    """Best-effort model version extraction for metrics and API responses."""
    if llm_model is None:
        return AgentConfig.PRIMARY_MODEL
    if hasattr(llm_model, "model_version") and getattr(llm_model, "model_version"):
        return getattr(llm_model, "model_version")
    if hasattr(llm_model, "model"):
        return getattr(llm_model, "model")
    if hasattr(llm_model, "name"):
        return getattr(llm_model, "name")
    return AgentConfig.PRIMARY_MODEL


def report_to_markdown(report_payload: dict[str, Any]) -> str:
    """Render a lightweight markdown representation for audit/debug state."""
    report = ReportDocument.model_validate(report_payload)
    lines: list[str] = [f"# {report.title}"]
    if report.subtitle:
        lines.extend(["", f"_{report.subtitle}_"])

    for section in report.sections:
        lines.extend(["", f"## {section.title}"])
        for block in section.blocks:
            if block.type == "paragraph":
                lines.append("".join(span.text for span in block.spans))
            elif block.type == "bullet_list":
                lines.extend(f"- {''.join(span.text for span in item.spans)}" for item in block.items)
            elif block.type == "key_value":
                lines.extend(
                    f"- **{item.key}:** {''.join(span.text for span in item.value)}"
                    for item in block.items
                )

    return "\n".join(lines).strip()
