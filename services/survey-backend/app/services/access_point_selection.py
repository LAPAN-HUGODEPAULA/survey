"""Helpers for resolving runtime selection through access points."""

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

    return AccessPointSelection(
        access_point_key=_coerce_optional_string(
            access_point.get("accessPointKey") if access_point else requested_access_point_key
        ),
        prompt_key=prompt_key,
        persona_skill_key=persona_skill_key,
        output_profile=output_profile,
    )
