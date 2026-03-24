from clinical_writer_agent.prompt_registry import (
    CompositePromptProvider,
    PromptNotFoundError,
)


class _MissingProvider:
    def get_prompt(self, prompt_key: str):
        raise PromptNotFoundError(f"missing {prompt_key}")


class _WorkingProvider:
    def get_prompt(self, prompt_key: str):
        return (f"prompt for {prompt_key}", "version-1")


def test_composite_prompt_provider_falls_through_missing_provider():
    registry = CompositePromptProvider([_MissingProvider(), _WorkingProvider()])

    prompt_text, version = registry.get_prompt("clinical_referral_letter:lapan7")

    assert prompt_text == "prompt for clinical_referral_letter:lapan7"
    assert version == "version-1"
