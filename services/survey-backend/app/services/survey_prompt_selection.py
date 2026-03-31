"""Helpers for resolving survey-associated prompt and persona selections."""

from collections.abc import Callable
from dataclasses import dataclass

from app.domain.models.survey_prompt_model import SurveyPromptReference


LEGACY_SURVEY_PROMPT_KEY = "survey7"
DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE = {
    "survey7": "patient_condition_overview",
    "full_intake": "clinical_diagnostic_report",
}
DEFAULT_PERSONA_BY_OUTPUT_PROFILE = {
    "patient_condition_overview": "patient_condition_overview",
    "clinical_diagnostic_report": "clinical_diagnostic_report",
    "clinical_referral_letter": "clinical_referral_letter",
    "parental_guidance": "parental_guidance",
    "educational_support_summary": "school_report",
    "school_report": "school_report",
}


@dataclass(frozen=True)
class SurveyPromptSelection:
    """Resolved prompt and persona configuration for a survey-derived request."""

    prompt_key: str
    persona_skill_key: str | None
    output_profile: str | None


def _coerce_optional_string(value: object | None) -> str | None:
    """Normalize an optional string-like value."""
    if value is None:
        return None
    normalized = str(value).strip()
    if not normalized:
        return None
    return normalized


def list_prompt_references(survey: dict | None) -> list[SurveyPromptReference]:
    """Parse prompt metadata from current and legacy survey documents."""
    if not survey:
        return []
    raw_prompt = survey.get("prompt")
    if isinstance(raw_prompt, dict):
        return [SurveyPromptReference(**raw_prompt)]
    raw_associations = survey.get("promptAssociations") or []
    associations: list[SurveyPromptReference] = []
    for raw in raw_associations:
        if not isinstance(raw, dict):
            continue
        associations.append(
            SurveyPromptReference(
                promptKey=raw.get("promptKey", ""),
                name=raw.get("name", ""),
            )
        )
    return associations


def resolve_prompt_key(survey: dict | None, requested_prompt_key: str | None) -> str:
    """Resolve the prompt key used for survey-generated AI reports."""
    associations = list_prompt_references(survey)
    if requested_prompt_key:
        if associations and requested_prompt_key not in {item.prompt_key for item in associations}:
            raise ValueError("Selected prompt is not associated with the requested survey")
        return requested_prompt_key
    if associations:
        return associations[0].prompt_key
    return LEGACY_SURVEY_PROMPT_KEY


def hydrate_survey_persona_defaults(
    survey: dict | None,
    *,
    requested_persona_skill_key: str | None = None,
    requested_output_profile: str | None = None,
    get_persona_by_key: Callable[[str], dict | None] | None = None,
    get_persona_by_output_profile: Callable[[str], dict | None] | None = None,
) -> dict | None:
    """Hydrate survey-level persona defaults before precedence resolution."""
    if not survey:
        return survey
    if requested_persona_skill_key or requested_output_profile:
        return survey

    hydrated = dict(survey)
    survey_persona_skill_key = _coerce_optional_string(hydrated.get("personaSkillKey"))
    survey_output_profile = _coerce_optional_string(hydrated.get("outputProfile"))

    if survey_persona_skill_key:
        persona = get_persona_by_key(survey_persona_skill_key) if get_persona_by_key else None
        if persona is None:
            raise ValueError(
                "Survey default personaSkillKey references an unknown persona skill: "
                f"{survey_persona_skill_key}"
            )
        hydrated["personaSkillKey"] = survey_persona_skill_key
        hydrated["outputProfile"] = survey_output_profile or _coerce_optional_string(
            persona.get("outputProfile")
        )
        return hydrated

    if survey_output_profile and get_persona_by_output_profile:
        persona = get_persona_by_output_profile(survey_output_profile)
        if persona:
            hydrated["personaSkillKey"] = _coerce_optional_string(persona.get("personaSkillKey"))
            hydrated["outputProfile"] = survey_output_profile

    return hydrated


def resolve_prompt_selection(
    survey: dict | None,
    requested_prompt_key: str | None,
    *,
    requested_persona_skill_key: str | None = None,
    requested_output_profile: str | None = None,
    input_type: str = "survey7",
) -> SurveyPromptSelection:
    """Resolve questionnaire prompt and persona skill independently."""
    prompt_key = resolve_prompt_key(survey, requested_prompt_key)
    survey_output_profile = _coerce_optional_string(
        survey.get("outputProfile") if survey else None
    )
    survey_persona_skill_key = _coerce_optional_string(
        survey.get("personaSkillKey") if survey else None
    )
    output_profile = (
        requested_output_profile
        or survey_output_profile
        or DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE.get(input_type)
    )
    persona_skill_key = requested_persona_skill_key or survey_persona_skill_key
    if not persona_skill_key and output_profile:
        persona_skill_key = DEFAULT_PERSONA_BY_OUTPUT_PROFILE.get(output_profile, output_profile)
    return SurveyPromptSelection(
        prompt_key=prompt_key,
        persona_skill_key=persona_skill_key,
        output_profile=output_profile,
    )
