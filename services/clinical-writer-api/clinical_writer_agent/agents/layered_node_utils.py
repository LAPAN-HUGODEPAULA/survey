"""Shared helpers for layered orchestration nodes."""

from __future__ import annotations

import json
import re
from typing import Any, Protocol

from ..agent_config import AgentConfig
from ..model_router import ModelRouter
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


def resolve_model_routing_metadata(llm_model: Any, state: Any) -> dict[str, Any]:
    """Expose routing metadata for telemetry dashboards."""
    model_version = resolve_model_version(llm_model)
    provider, _, model = model_version.partition(":")
    primary_provider = state.get("ai_provider") or "glm"
    return {
        "model_version": model_version,
        "provider": provider if provider else "unknown",
        "model": model if model else model_version,
        "primary_provider": primary_provider,
        "fallback_used": bool(provider) and provider != primary_provider,
    }


def resolve_model_router(state: Any) -> ModelRouter:
    """Build a ModelRouter using configuration from state or environment defaults."""
    primary_provider = state.get("ai_provider") or "glm"
    primary_model = state.get("glm_model") if primary_provider == "glm" else state.get("gemini_model")
    if not primary_model:
        primary_model = AgentConfig.PRIMARY_MODEL if primary_provider == "glm" else AgentConfig.LLM_MODEL_NAME

    fallback_provider = "gemini" if primary_provider == "glm" else "glm"
    fallback_model = state.get("gemini_model") if fallback_provider == "gemini" else state.get("glm_model")
    if not fallback_model:
        fallback_model = AgentConfig.LLM_MODEL_NAME if fallback_provider == "gemini" else AgentConfig.GLM_MODEL_NAME

    temperature = state.get("temperature")
    if temperature is None:
        temperature = AgentConfig.LLM_TEMPERATURE

    return ModelRouter(
        primary_model=primary_model,
        fallback_model=fallback_model,
        primary_provider=primary_provider,
        fallback_provider=fallback_provider,
        temperature=temperature,
        do_sample=state.get("do_sample"),
        thinking_mode=state.get("thinking_mode"),
        enable_caching=state.get("enable_caching"),
    )


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
