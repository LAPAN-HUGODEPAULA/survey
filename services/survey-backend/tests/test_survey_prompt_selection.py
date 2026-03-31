from app.services.survey_prompt_selection import (
    DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE,
    LEGACY_SURVEY_PROMPT_KEY,
    hydrate_survey_persona_defaults,
    resolve_prompt_selection,
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


def test_resolve_prompt_selection_uses_default_persona_for_input_type():
    survey = {
        "prompt": {
            "promptKey": "autism-intake-summary",
            "name": "Autism Intake Summary",
        }
    }

    selection = resolve_prompt_selection(survey, None, input_type="survey7")

    assert selection.prompt_key == "autism-intake-summary"
    assert selection.output_profile == DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE["survey7"]
    assert selection.persona_skill_key == "patient_condition_overview"


def test_resolve_prompt_selection_uses_survey_defaults_before_legacy_fallback():
    survey = {
        "prompt": {
            "promptKey": "autism-intake-summary",
            "name": "Autism Intake Summary",
        },
        "personaSkillKey": "school_report",
        "outputProfile": "school_report",
    }

    selection = resolve_prompt_selection(survey, None, input_type="survey7")

    assert selection.prompt_key == "autism-intake-summary"
    assert selection.output_profile == "school_report"
    assert selection.persona_skill_key == "school_report"


def test_resolve_prompt_selection_keeps_explicit_persona_and_output_profile():
    survey = {
        "prompt": {
            "promptKey": "autism-intake-summary",
            "name": "Autism Intake Summary",
        }
    }

    selection = resolve_prompt_selection(
        survey,
        None,
        requested_persona_skill_key="school_report",
        requested_output_profile="school_report",
        input_type="survey7",
    )

    assert selection.prompt_key == "autism-intake-summary"
    assert selection.output_profile == "school_report"
    assert selection.persona_skill_key == "school_report"


def test_resolve_prompt_selection_uses_request_overrides_instead_of_survey_defaults():
    survey = {
        "prompt": {
            "promptKey": "autism-intake-summary",
            "name": "Autism Intake Summary",
        },
        "personaSkillKey": "school_report",
        "outputProfile": "school_report",
    }

    selection = resolve_prompt_selection(
        survey,
        None,
        requested_persona_skill_key="clinical_diagnostic_report",
        requested_output_profile="clinical_diagnostic_report",
        input_type="survey7",
    )

    assert selection.output_profile == "clinical_diagnostic_report"
    assert selection.persona_skill_key == "clinical_diagnostic_report"


def test_hydrate_survey_persona_defaults_rejects_unknown_survey_persona():
    survey = {
        "prompt": {
            "promptKey": "autism-intake-summary",
            "name": "Autism Intake Summary",
        },
        "personaSkillKey": "deleted_persona",
    }

    try:
        hydrate_survey_persona_defaults(
            survey,
            get_persona_by_key=lambda key: None,
        )
    except ValueError as exc:
        assert (
            str(exc)
            == "Survey default personaSkillKey references an unknown persona skill: deleted_persona"
        )
    else:
        raise AssertionError("Expected stale survey persona to raise ValueError")


def test_hydrate_survey_persona_defaults_derives_persona_from_output_profile():
    survey = {
        "prompt": {
            "promptKey": "autism-intake-summary",
            "name": "Autism Intake Summary",
        },
        "outputProfile": "school_report",
    }

    hydrated = hydrate_survey_persona_defaults(
        survey,
        get_persona_by_output_profile=lambda profile: {
            "personaSkillKey": "school_report",
            "outputProfile": profile,
        },
    )

    assert hydrated is not None
    assert hydrated["personaSkillKey"] == "school_report"
    assert hydrated["outputProfile"] == "school_report"
