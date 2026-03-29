"""Helpers for resolving survey-associated prompt and persona selections."""

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
    output_profile = requested_output_profile or DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE.get(input_type)
    persona_skill_key = requested_persona_skill_key
    if not persona_skill_key and output_profile:
        persona_skill_key = DEFAULT_PERSONA_BY_OUTPUT_PROFILE.get(output_profile, output_profile)
    return SurveyPromptSelection(
        prompt_key=prompt_key,
        persona_skill_key=persona_skill_key,
        output_profile=output_profile,
    )
