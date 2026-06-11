"""Helpers for resolving runtime selection through access points."""

import os
from collections.abc import Callable
from dataclasses import dataclass

from app.services.survey_prompt_selection import (
    DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE,
    DEFAULT_PERSONA_BY_OUTPUT_PROFILE,
    resolve_prompt_key,
)


@dataclass(frozen=True)
class AccessPointSelection:
    """Resolved prompt and persona configuration for one runtime artifact."""

    access_point_key: str | None
    prompt_key: str
    persona_skill_key: str | None
    output_profile: str | None
    ai_config: dict | None = None
    system_prompt_override: str | None = None
    format_prompt_override: str | None = None


def _parse_bool(value: str | None, *, default: bool) -> bool:
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def _default_ai_config_from_env() -> dict | None:
    glm_model = _coerce_optional_string(os.getenv("GLM_MODEL"))
    gemini_model = _coerce_optional_string(os.getenv("GEMINI_MODEL"))
    primary_provider = _coerce_optional_string(os.getenv("AI_DEFAULT_PRIMARY_PROVIDER"))
    if primary_provider not in {"glm", "gemini"}:
        primary_provider = "glm" if glm_model else "gemini"
    if primary_provider not in {"glm", "gemini"}:
        return None

    primary_model = glm_model if primary_provider == "glm" else gemini_model
    fallback_provider = "gemini" if primary_provider == "glm" else "glm"
    fallback_model = gemini_model if fallback_provider == "gemini" else glm_model
    if not primary_model:
        return None

    return {
        "primaryProvider": primary_provider,
        "primaryModel": primary_model,
        "fallbackProvider": fallback_provider if fallback_model else None,
        "fallbackModel": fallback_model,
        "temperature": float(os.getenv("AI_DEFAULT_TEMPERATURE", "0")),
        "reasoningEffort": _coerce_optional_string(os.getenv("AI_DEFAULT_REASONING_EFFORT")) or "low",
        "enableCaching": _parse_bool(os.getenv("AI_DEFAULT_ENABLE_CACHING"), default=True),
    }


def _normalize_ai_config(value: dict | None) -> dict | None:
    if not isinstance(value, dict):
        return None
    agent_refs = value.get("agentRefs")
    if isinstance(agent_refs, list) and any(
        isinstance(item, dict) and item.get("enabled", True) for item in agent_refs
    ):
        normalized = dict(value)
        normalized["agentRefs"] = [dict(item) for item in agent_refs if isinstance(item, dict)]
        normalized.setdefault("temperature", value.get("temperature", 0.0))
        normalized.setdefault(
            "reasoningEffort",
            _coerce_optional_string(value.get("reasoningEffort")) or "low",
        )
        normalized.setdefault("enableCaching", bool(value.get("enableCaching", True)))
        return normalized
    primary_provider = _coerce_optional_string(value.get("primaryProvider"))
    primary_model = _coerce_optional_string(value.get("primaryModel"))
    if not primary_provider or not primary_model:
        return None
    fallback_provider = _coerce_optional_string(value.get("fallbackProvider"))
    fallback_model = _coerce_optional_string(value.get("fallbackModel"))
    return {
        "primaryProvider": primary_provider,
        "primaryModel": primary_model,
        "fallbackProvider": fallback_provider,
        "fallbackModel": fallback_model,
        "temperature": value.get("temperature", 0.0),
        "reasoningEffort": _coerce_optional_string(value.get("reasoningEffort")) or "low",
        "enableCaching": bool(value.get("enableCaching", True)),
    }


def _resolve_effective_ai_config(
    *,
    request_ai_config: dict | None,
    access_point_ai_config: dict | None,
    global_ai_config: dict | None,
) -> dict | None:
    env_ai_config = _default_ai_config_from_env()
    return (
        _normalize_ai_config(request_ai_config)
        or _normalize_ai_config(access_point_ai_config)
        or _normalize_ai_config(global_ai_config)
        or env_ai_config
    )


def _coerce_optional_string(value: object | None) -> str | None:
    if value is None:
        return None
    normalized = str(value).strip()
    if not normalized:
        return None
    return normalized


def resolve_access_point_selection(
    *,
    survey: dict | None,
    requested_access_point_key: str | None,
    requested_prompt_key: str | None,
    requested_persona_skill_key: str | None,
    requested_output_profile: str | None,
    requested_ai_config: dict | None,
    global_ai_config: dict | None,
    input_type: str,
    get_access_point_by_key: Callable[[str], dict | None] | None = None,
) -> AccessPointSelection:
    """Resolve runtime configuration using request overrides, access points, and survey defaults."""
    access_point: dict | None = None
    if requested_access_point_key:
        if get_access_point_by_key is None:
            raise ValueError("Access-point resolution is unavailable for this request")
        access_point = get_access_point_by_key(requested_access_point_key)
        if access_point is None:
            raise ValueError(f"Unknown accessPointKey: {requested_access_point_key}")

    prompt_key = requested_prompt_key or _coerce_optional_string(
        access_point.get("promptKey") if access_point else None
    )
    if not prompt_key:
        prompt_key = resolve_prompt_key(survey, None)

    survey_output_profile = _coerce_optional_string(survey.get("outputProfile") if survey else None)
    survey_persona_skill_key = _coerce_optional_string(
        survey.get("personaSkillKey") if survey else None
    )
    access_point_output_profile = _coerce_optional_string(
        access_point.get("outputProfile") if access_point else None
    )
    access_point_persona_skill_key = _coerce_optional_string(
        access_point.get("personaSkillKey") if access_point else None
    )

    output_profile = (
        requested_output_profile
        or access_point_output_profile
        or survey_output_profile
        or DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE.get(input_type)
    )
    persona_skill_key = (
        requested_persona_skill_key
        or access_point_persona_skill_key
        or survey_persona_skill_key
    )
    if not persona_skill_key and output_profile:
        persona_skill_key = DEFAULT_PERSONA_BY_OUTPUT_PROFILE.get(output_profile, output_profile)

    effective_ai_config = _resolve_effective_ai_config(
        request_ai_config=requested_ai_config,
        access_point_ai_config=access_point.get("aiConfig") if access_point else None,
        global_ai_config=global_ai_config,
    )

    return AccessPointSelection(
        access_point_key=_coerce_optional_string(
            access_point.get("accessPointKey") if access_point else requested_access_point_key
        ),
        prompt_key=prompt_key,
        persona_skill_key=persona_skill_key,
        output_profile=output_profile,
        ai_config=effective_ai_config,
        system_prompt_override=_coerce_optional_string(
            access_point.get("systemPromptOverride") if access_point else None
        ),
        format_prompt_override=_coerce_optional_string(
            access_point.get("formatPromptOverride") if access_point else None
        ),
    )
