from clinical_writer_agent.prompt_registry import (
    ClinicalPromptRegistry,
    CompositePromptProvider,
    PromptNotFoundError,
    create_prompt_registry,
)


class _MissingProvider:
    def get_prompt(self, prompt_key: str):
        raise PromptNotFoundError(f"missing {prompt_key}")


class _WorkingProvider:
    def get_prompt(self, prompt_key: str):
        return (f"prompt for {prompt_key}", "version-1")


class _UnavailableProvider:
    def get_prompt(self, prompt_key: str):
        raise RuntimeError("upstream unavailable")


class _QuestionnaireProvider:
    def __init__(self, prompt_text: str, version: str):
        self.prompt_text = prompt_text
        self.version = version

    def get_prompt(self, prompt_key: str):
        return self.prompt_text, self.version


class _PersonaProvider:
    def __init__(self, instructions: str, version: str):
        self.instructions = instructions
        self.version = version

    def get_persona(self, *, persona_skill_key: str | None = None, output_profile: str | None = None):
        return self.instructions, self.version, persona_skill_key or "patient_condition_overview", output_profile or "patient_condition_overview"


def test_composite_prompt_provider_falls_through_missing_provider():
    registry = CompositePromptProvider([_MissingProvider(), _WorkingProvider()])

    prompt_text, version = registry.get_prompt("clinical_referral_letter:lapan7")

    assert prompt_text == "prompt for clinical_referral_letter:lapan7"
    assert version == "version-1"


def test_composite_prompt_provider_falls_through_unavailable_provider():
    registry = CompositePromptProvider([_UnavailableProvider(), _WorkingProvider()])

    prompt_text, version = registry.get_prompt("survey7")

    assert prompt_text == "prompt for survey7"
    assert version == "version-1"


def test_clinical_prompt_registry_composes_questionnaire_and_persona():
    registry = ClinicalPromptRegistry(
        fallback_provider=_WorkingProvider(),
        questionnaire_provider=_QuestionnaireProvider(
            "Interpret the questionnaire conservatively.",
            "questionnaire_modifiedAt:2026-03-26T10:00:00+00:00",
        ),
        persona_provider=_PersonaProvider(
            "Write for a school team with formal tone.",
            "persona_modifiedAt:2026-03-26T10:05:00+00:00",
        ),
    )

    resolved = registry.resolve_process_prompt(
        input_type="survey7",
        prompt_key="survey7",
        persona_skill_key="school_report",
        output_profile="school_report",
    )

    assert "QUESTIONNAIRE CLINICAL LOGIC" in resolved.prompt_text
    assert "PERSONA STYLE AND RESTRICTIONS" in resolved.prompt_text
    assert resolved.interpretation_prompt == "Interpret the questionnaire conservatively."
    assert resolved.persona_prompt == "Write for a school team with formal tone."
    assert resolved.questionnaire_prompt_version == "questionnaire_modifiedAt:2026-03-26T10:00:00+00:00"
    assert resolved.persona_skill_version == "persona_modifiedAt:2026-03-26T10:05:00+00:00"


def test_clinical_prompt_registry_uses_updated_persona_on_next_request():
    persona_provider = _PersonaProvider(
        "Write for a school team with formal tone.",
        "persona_modifiedAt:2026-03-26T10:05:00+00:00",
    )
    registry = ClinicalPromptRegistry(
        fallback_provider=_WorkingProvider(),
        questionnaire_provider=_QuestionnaireProvider(
            "Interpret the questionnaire conservatively.",
            "questionnaire_modifiedAt:2026-03-26T10:00:00+00:00",
        ),
        persona_provider=persona_provider,
    )

    first = registry.resolve_process_prompt(
        input_type="survey7",
        prompt_key="survey7",
        persona_skill_key="school_report",
        output_profile="school_report",
    )
    persona_provider.instructions = "Write for a school team with collaborative tone."
    persona_provider.version = "persona_modifiedAt:2026-03-26T10:06:00+00:00"
    second = registry.resolve_process_prompt(
        input_type="survey7",
        prompt_key="survey7",
        persona_skill_key="school_report",
        output_profile="school_report",
    )

    assert "formal tone" in first.prompt_text
    assert "collaborative tone" in second.prompt_text
    assert second.interpretation_prompt == "Interpret the questionnaire conservatively."
    assert second.persona_prompt == "Write for a school team with collaborative tone."
    assert second.persona_skill_version == "persona_modifiedAt:2026-03-26T10:06:00+00:00"


def test_create_prompt_registry_falls_back_when_google_drive_is_misconfigured(
    monkeypatch,
):
    monkeypatch.setenv("PROMPT_PROVIDER", "google_drive")
    monkeypatch.setenv(
        "GOOGLE_APPLICATION_CREDENTIALS",
        "/tmp/does-not-exist-service-account.json",
    )
    monkeypatch.delenv("PROMPT_MONGO_URI", raising=False)
    monkeypatch.delenv("MONGO_URI", raising=False)
    monkeypatch.delenv("PROMPT_MONGO_DB_NAME", raising=False)
    monkeypatch.delenv("MONGO_DB_NAME", raising=False)
    monkeypatch.delenv("PROMPT_DOC_MAP_JSON", raising=False)
    monkeypatch.delenv("GOOGLE_DRIVE_FOLDER_ID", raising=False)

    registry = create_prompt_registry()

    prompt_text, version = registry.get_prompt("default")

    assert prompt_text
    assert version == "local:default"
