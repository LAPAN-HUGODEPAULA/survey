from app.services.survey_prompt_selection import (
    LEGACY_SURVEY_PROMPT_KEY,
    resolve_prompt_key,
)


def test_resolve_prompt_key_uses_configured_prompt():
    survey = {
        "prompt": {
            "promptKey": "autism-intake-summary",
            "name": "Autism Intake Summary",
        }
    }

    assert resolve_prompt_key(survey, None) == "autism-intake-summary"


def test_resolve_prompt_key_falls_back_when_prompt_is_null():
    survey = {"prompt": None}

    assert resolve_prompt_key(survey, None) == LEGACY_SURVEY_PROMPT_KEY


def test_resolve_prompt_key_rejects_unknown_requested_prompt():
    survey = {
        "prompt": {
            "promptKey": "autism-intake-summary",
            "name": "Autism Intake Summary",
        }
    }

    try:
        resolve_prompt_key(survey, "other-prompt")
    except ValueError as exc:
        assert str(exc) == "Selected prompt is not associated with the requested survey"
    else:
        raise AssertionError("Expected invalid prompt selection to raise ValueError")
