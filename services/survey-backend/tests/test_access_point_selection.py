from app.services.access_point_selection import resolve_access_point_selection


def test_resolve_access_point_selection_prefers_request_overrides():
    survey = {
        "prompt": {"promptKey": "survey-default", "name": "Default"},
        "personaSkillKey": "survey_persona",
        "outputProfile": "survey_profile",
    }
    access_point = {
        "accessPointKey": "survey_patient.thank_you.auto_analysis",
        "promptKey": "access_point_prompt",
        "personaSkillKey": "access_point_persona",
        "outputProfile": "access_point_profile",
    }

    selection = resolve_access_point_selection(
        survey=survey,
        requested_access_point_key="survey_patient.thank_you.auto_analysis",
        requested_prompt_key="request_prompt",
        requested_persona_skill_key="request_persona",
        requested_output_profile="request_profile",
        input_type="survey7",
        get_access_point_by_key=lambda _key: access_point,
    )

    assert selection.prompt_key == "request_prompt"
    assert selection.persona_skill_key == "request_persona"
    assert selection.output_profile == "request_profile"


def test_resolve_access_point_selection_uses_access_point_before_survey_defaults():
    survey = {
        "prompt": {"promptKey": "survey-default", "name": "Default"},
        "personaSkillKey": "survey_persona",
        "outputProfile": "survey_profile",
    }
    access_point = {
        "accessPointKey": "survey_patient.thank_you.auto_analysis",
        "promptKey": "access_point_prompt",
        "personaSkillKey": "access_point_persona",
        "outputProfile": "access_point_profile",
    }

    selection = resolve_access_point_selection(
        survey=survey,
        requested_access_point_key="survey_patient.thank_you.auto_analysis",
        requested_prompt_key=None,
        requested_persona_skill_key=None,
        requested_output_profile=None,
        input_type="survey7",
        get_access_point_by_key=lambda _key: access_point,
    )

    assert selection.access_point_key == "survey_patient.thank_you.auto_analysis"
    assert selection.prompt_key == "access_point_prompt"
    assert selection.persona_skill_key == "access_point_persona"
    assert selection.output_profile == "access_point_profile"


def test_resolve_access_point_selection_falls_back_to_survey_defaults_when_binding_absent():
    survey = {
        "prompt": {"promptKey": "survey-default", "name": "Default"},
        "personaSkillKey": "survey_persona",
        "outputProfile": "survey_profile",
    }
    access_point = {
        "accessPointKey": "survey_patient.thank_you.auto_analysis",
        "promptKey": "access_point_prompt",
    }

    selection = resolve_access_point_selection(
        survey=survey,
        requested_access_point_key="survey_patient.thank_you.auto_analysis",
        requested_prompt_key=None,
        requested_persona_skill_key=None,
        requested_output_profile=None,
        input_type="survey7",
        get_access_point_by_key=lambda _key: access_point,
    )

    assert selection.prompt_key == "access_point_prompt"
    assert selection.persona_skill_key == "survey_persona"
    assert selection.output_profile == "survey_profile"
