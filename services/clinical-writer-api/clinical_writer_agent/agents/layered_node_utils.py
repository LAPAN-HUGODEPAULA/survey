"""Shared helpers for layered orchestration nodes."""

from __future__ import annotations

import json
import logging
import re
from typing import Any, Protocol

from ..agent_config import AgentConfig
from ..model_router import ModelRouter
from ..repository.agent_route_repository import (
    AgentRouteRepository,
    create_agent_route_repository_from_env,
)
from ..report_models import ReportDocument


logger = logging.getLogger("clinical_writer.routing")


def _resolve_agent_routes(
    ai_config: dict[str, Any],
    route_repository: AgentRouteRepository | None,
) -> list[dict[str, Any]]:
    agent_refs = ai_config.get("agentRefs")
    if not isinstance(agent_refs, list):
        return []

    routes: list[dict[str, Any]] = []
    for item in agent_refs:
        if not isinstance(item, dict) or item.get("enabled", True) is False:
            continue
        agent_key = item.get("agentKey")
        if not agent_key:
            continue
        agent = route_repository.get_agent(agent_key) if route_repository else None
        if not agent:
            raise ValueError(f"Unknown AI agent: {agent_key}")
        if not agent.get("enabled", True):
            raise ValueError(f"Disabled AI agent cannot be used: {agent_key}")
        routes.append(
            {
                **agent,
                "agentKey": agent_key,
                "model": item.get("model") or agent.get("defaultModel"),
                "temperature": (
                    item.get("temperature")
                    if item.get("temperature") is not None
                    else ai_config.get("temperature")
                ),
                "maxTokens": item.get("maxTokens"),
                "enabled": item.get("enabled", True),
            }
        )
    return routes


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
    ai_config = state.get("ai_config") or {}
    primary_provider = ai_config.get("primaryProvider") or "glm"
    return {
        "model_version": model_version,
        "provider": provider if provider else "unknown",
        "model": model if model else model_version,
        "primary_provider": primary_provider,
        "fallback_used": bool(provider) and provider != primary_provider,
    }


def resolve_model_router(state: Any) -> ModelRouter:
    """Build a ModelRouter using configuration from state or environment defaults."""
    ai_config = state.get("ai_config") or {}
    route_repository = state.get("agent_route_repository") or create_agent_route_repository_from_env()
    agent_routes = _resolve_agent_routes(ai_config, route_repository)
    if agent_routes:
        primary_route = agent_routes[0]
        logger.info(
            "stage=model_router_resolved request_id=%s input_type=%s route_count=%s primary_agent=%s primary_model=%s temperature=%s",
            state.get("request_id"),
            state.get("input_type"),
            len(agent_routes),
            primary_route.get("agentKey"),
            primary_route.get("model"),
            primary_route.get("temperature"),
        )
        return ModelRouter(
            primary_model=primary_route.get("model"),
            fallback_model=None,
            primary_provider=primary_route.get("agentKey") or "agent",
            fallback_provider=None,
            temperature=state.get("temperature") if state.get("temperature") is not None else ai_config.get("temperature"),
            do_sample=state.get("do_sample") if state.get("do_sample") is not None else ai_config.get("doSample"),
            thinking_mode=state.get("thinking_mode") or ai_config.get("reasoningEffort"),
            enable_caching=(
                state.get("enable_caching")
                if state.get("enable_caching") is not None
                else ai_config.get("enableCaching")
            ),
            agent_routes=agent_routes,
        )

    primary_provider = ai_config.get("primaryProvider") or ("glm" if AgentConfig.GLM_MODEL_NAME else "gemini")
    primary_model = ai_config.get("primaryModel")
    fallback_provider = ai_config.get("fallbackProvider")
    fallback_model = ai_config.get("fallbackModel")

    if not primary_model:
        primary_model = (
            AgentConfig.GLM_MODEL_NAME if primary_provider == "glm" else AgentConfig.LLM_MODEL_NAME
        )
    if not fallback_provider:
        fallback_provider = "gemini" if primary_provider == "glm" else "glm"
    if not fallback_model:
        fallback_model = (
            AgentConfig.LLM_MODEL_NAME if fallback_provider == "gemini" else AgentConfig.GLM_MODEL_NAME
        )

    if not primary_model:
        raise ValueError("Missing primary model in aiConfig and environment fallback")

    temperature = state.get("temperature")
    if temperature is None:
        temperature = ai_config.get("temperature")
    if temperature is None:
        temperature = AgentConfig.LLM_TEMPERATURE

    logger.info(
        "stage=model_router_resolved request_id=%s input_type=%s primary_provider=%s primary_model=%s fallback_provider=%s fallback_model=%s temperature=%s thinking_mode=%s enable_caching=%s",
        state.get("request_id"),
        state.get("input_type"),
        primary_provider,
        primary_model,
        fallback_provider,
        fallback_model,
        temperature,
        state.get("thinking_mode") or ai_config.get("reasoningEffort"),
        state.get("enable_caching") if state.get("enable_caching") is not None else ai_config.get("enableCaching"),
    )

    return ModelRouter(
        primary_model=primary_model,
        fallback_model=fallback_model,
        primary_provider=primary_provider,
        fallback_provider=fallback_provider,
        temperature=temperature,
        do_sample=state.get("do_sample") if state.get("do_sample") is not None else ai_config.get("doSample"),
        thinking_mode=state.get("thinking_mode") or ai_config.get("reasoningEffort"),
        enable_caching=(
            state.get("enable_caching")
            if state.get("enable_caching") is not None
            else ai_config.get("enableCaching")
        ),
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
