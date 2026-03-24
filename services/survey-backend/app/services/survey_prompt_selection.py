"""Helpers for resolving survey-associated AI prompt keys."""

from app.domain.models.survey_prompt_model import SurveyPromptAssociation


LEGACY_SURVEY_PROMPT_KEY = "survey7"


def list_prompt_associations(survey: dict | None) -> list[SurveyPromptAssociation]:
    """Parse prompt association metadata from a survey document."""
    if not survey:
        return []
    raw_associations = survey.get("promptAssociations") or []
    associations: list[SurveyPromptAssociation] = []
    for raw in raw_associations:
        if not isinstance(raw, dict):
            continue
        associations.append(SurveyPromptAssociation(**raw))
    return associations


def resolve_prompt_key(survey: dict | None, requested_prompt_key: str | None) -> str:
    """Resolve the prompt key used for survey-generated AI reports."""
    associations = list_prompt_associations(survey)
    if requested_prompt_key:
        if associations and requested_prompt_key not in {item.prompt_key for item in associations}:
            raise ValueError("Selected prompt is not associated with the requested survey")
        return requested_prompt_key
    if associations:
        return associations[0].prompt_key
    return LEGACY_SURVEY_PROMPT_KEY
