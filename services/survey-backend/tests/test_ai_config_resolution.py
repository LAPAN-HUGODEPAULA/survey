from app.services.access_point_selection import resolve_access_point_selection


def test_resolve_access_point_selection_includes_ai_config():
    survey = {
        "prompt": {"promptKey": "survey-default", "name": "Default"},
    }
    access_point = {
        "accessPointKey": "test.access_point",
        "promptKey": "ap_prompt",
        "personaSkillKey": "ap_persona",
        "outputProfile": "ap_profile",
        "aiProvider": "glm",
        "glmModel": "glm-special",
        "geminiModel": "gemini-special",
    }

    selection = resolve_access_point_selection(
        survey=survey,
        requested_access_point_key="test.access_point",
        requested_prompt_key=None,
        requested_persona_skill_key=None,
        requested_output_profile=None,
        input_type="survey7",
        get_access_point_by_key=lambda _key: access_point,
    )

    assert selection.ai_provider == "glm"
    assert selection.glm_model == "glm-special"
    assert selection.gemini_model == "gemini-special"


def test_resolve_access_point_selection_ai_config_none_when_missing():
    survey = {"prompt": {"promptKey": "survey-default"}}
    access_point = {
        "accessPointKey": "test.access_point",
        "promptKey": "ap_prompt",
    }

    selection = resolve_access_point_selection(
        survey=survey,
        requested_access_point_key="test.access_point",
        requested_prompt_key=None,
        requested_persona_skill_key=None,
        requested_output_profile=None,
        input_type="survey7",
        get_access_point_by_key=lambda _key: access_point,
    )

    assert selection.ai_provider is None
    assert selection.glm_model is None
    assert selection.gemini_model is None
