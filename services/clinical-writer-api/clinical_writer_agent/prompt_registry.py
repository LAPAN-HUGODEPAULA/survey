"""Prompt registry composition for the clinical writer orchestration graph."""

from __future__ import annotations

import logging
import os
from dataclasses import dataclass
from typing import Tuple

from .repository.prompt_repository import (
    LocalPromptRepository,
    MongoPersonaRepository,
    MongoPromptRepository,
    MongoQuestionnairePromptRepository,
    PersonaRepository,
    PromptNotFoundError,
    PromptRepository,
)

logger = logging.getLogger("clinical_writer.prompt_registry")

SURVEY_INPUT_TYPES = {"survey7", "full_intake"}
DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE = {
    "survey7": "patient_condition_overview",
    "full_intake": "clinical_diagnostic_report",
}
DEFAULT_PERSONA_KEY_BY_OUTPUT_PROFILE = {
    "patient_condition_overview": "patient_condition_overview",
    "clinical_diagnostic_report": "clinical_diagnostic_report",
    "clinical_referral_letter": "clinical_referral_letter",
    "parental_guidance": "parental_guidance",
    "educational_support_summary": "school_report",
    "school_report": "school_report",
}


@dataclass(frozen=True)
class ResolvedPrompt:
    """Resolved prompt bundle consumed by the graph's context loader."""

    prompt_text: str
    prompt_version: str
    interpretation_prompt: str | None = None
    persona_prompt: str | None = None
    questionnaire_prompt_version: str | None = None
    persona_skill_version: str | None = None
    persona_skill_key: str | None = None
    output_profile: str | None = None


class PromptRegistry:
    """Abstract prompt registry interface."""

    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        """Return prompt text and prompt version for a key."""
        raise NotImplementedError

    def resolve_process_prompt(
        self,
        *,
        input_type: str,
        prompt_key: str,
        persona_skill_key: str | None = None,
        output_profile: str | None = None,
        system_prompt_override: str | None = None,
        format_prompt_override: str | None = None,
    ) -> ResolvedPrompt:
        del persona_skill_key, output_profile, format_prompt_override, input_type
        prompt_text, prompt_version = self.get_prompt(prompt_key)
        return ResolvedPrompt(
            prompt_text=system_prompt_override or prompt_text,
            prompt_version=(
                f"override:{hash(system_prompt_override)}"
                if system_prompt_override
                else prompt_version
            ),
            interpretation_prompt=system_prompt_override or prompt_text,
            persona_prompt=system_prompt_override or prompt_text,
        )


class CompositePromptProvider(PromptRegistry):
    """Try multiple prompt sources until one resolves successfully."""

    def __init__(self, providers: list[PromptRegistry]):
        self._providers = providers

    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        last_error: PromptNotFoundError | None = None
        for provider in self._providers:
            try:
                return provider.get_prompt(prompt_key)
            except PromptNotFoundError as exc:
                last_error = exc
            except RuntimeError as exc:
                logger.warning(
                    "Prompt provider unavailable for key=%s: %s",
                    prompt_key,
                    exc,
                )
        if last_error is not None:
            raise last_error
        raise PromptNotFoundError(f"Prompt '{prompt_key}' could not be resolved.")


class ClinicalPromptRegistry(PromptRegistry):
    """Resolve questionnaire prompts and persona instructions for survey inputs."""

    def __init__(
        self,
        *,
        fallback_provider: PromptRegistry,
        questionnaire_provider: PromptRepository | None = None,
        persona_provider: PersonaRepository | None = None,
    ):
        self._fallback_provider = fallback_provider
        self._questionnaire_provider = questionnaire_provider
        self._persona_provider = persona_provider

    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        return self._fallback_provider.get_prompt(prompt_key)

    def resolve_process_prompt(
        self,
        *,
        input_type: str,
        prompt_key: str,
        persona_skill_key: str | None = None,
        output_profile: str | None = None,
        system_prompt_override: str | None = None,
        format_prompt_override: str | None = None,
    ) -> ResolvedPrompt:
        del format_prompt_override
        if input_type not in SURVEY_INPUT_TYPES:
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
                system_prompt_override=system_prompt_override,
            )

        if self._questionnaire_provider is None or self._persona_provider is None:
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
                system_prompt_override=system_prompt_override,
            )

        try:
            questionnaire_text, questionnaire_version = (
                self._questionnaire_provider.get_prompt(prompt_key)
            )
        except (PromptNotFoundError, RuntimeError):
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
                system_prompt_override=system_prompt_override,
            )

        resolved_output_profile = (
            output_profile or DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE.get(input_type)
        )
        resolved_persona_skill_key = persona_skill_key
        if not resolved_persona_skill_key and resolved_output_profile:
            resolved_persona_skill_key = DEFAULT_PERSONA_KEY_BY_OUTPUT_PROFILE.get(
                resolved_output_profile,
                resolved_output_profile,
            )

        if not resolved_persona_skill_key and not resolved_output_profile:
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
                system_prompt_override=system_prompt_override,
            )

        try:
            persona_text, persona_version, resolved_persona_skill_key, resolved_output_profile = (
                self._persona_provider.get_persona(
                    persona_skill_key=resolved_persona_skill_key,
                    output_profile=resolved_output_profile,
                )
            )
        except PromptNotFoundError:
            if persona_skill_key or output_profile:
                raise
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
                system_prompt_override=system_prompt_override,
            )

        prompt_text = _compose_prompt(questionnaire_text, persona_text)
        prompt_version = f"{questionnaire_version};{persona_version}"
        interpretation_prompt = questionnaire_text
        persona_prompt = persona_text

        if system_prompt_override:
            prompt_text = system_prompt_override
            interpretation_prompt = system_prompt_override
            persona_prompt = system_prompt_override
            prompt_version = f"override:{hash(system_prompt_override)};{prompt_version}"

        return ResolvedPrompt(
            prompt_text=prompt_text,
            prompt_version=prompt_version,
            interpretation_prompt=interpretation_prompt,
            persona_prompt=persona_prompt,
            questionnaire_prompt_version=questionnaire_version,
            persona_skill_version=persona_version,
            persona_skill_key=resolved_persona_skill_key,
            output_profile=resolved_output_profile,
        )


def _compose_prompt(questionnaire_prompt_text: str, persona_skill_text: str) -> str:
    return (
        "QUESTIONNAIRE CLINICAL LOGIC:\n"
        f"{questionnaire_prompt_text.strip()}\n\n"
        "PERSONA STYLE AND RESTRICTIONS:\n"
        f"{persona_skill_text.strip()}"
    )


def create_prompt_registry() -> PromptRegistry:
    """Create the runtime prompt registry using Mongo-first resolution."""
    provider = os.getenv("PROMPT_PROVIDER", "mongo_first")
    cache_ttl = int(os.getenv("PROMPT_CACHE_TTL_SECONDS", "60"))

    if provider == "google_drive":
        logger.warning(
            "PROMPT_PROVIDER=google_drive is deprecated and ignored; using Mongo/local providers instead."
        )

    configured_providers: list[PromptRegistry] = []
    questionnaire_provider: PromptRepository | None = None
    persona_provider: PersonaRepository | None = None

    mongo_uri = os.getenv("PROMPT_MONGO_URI") or os.getenv("MONGO_URI")
    mongo_db_name = os.getenv("PROMPT_MONGO_DB_NAME") or os.getenv("MONGO_DB_NAME")
    if mongo_uri and mongo_db_name:
        questionnaire_provider = MongoQuestionnairePromptRepository(
            mongo_uri=mongo_uri,
            db_name=mongo_db_name,
            cache_ttl_seconds=cache_ttl,
        )
        persona_provider = MongoPersonaRepository(
            mongo_uri=mongo_uri,
            db_name=mongo_db_name,
            cache_ttl_seconds=cache_ttl,
        )
        configured_providers.append(
            MongoPromptRepository(
                mongo_uri=mongo_uri,
                db_name=mongo_db_name,
                cache_ttl_seconds=cache_ttl,
            )
        )

    configured_providers.append(LocalPromptRepository())
    fallback_provider = (
        configured_providers[0]
        if len(configured_providers) == 1
        else CompositePromptProvider(configured_providers)
    )
    return ClinicalPromptRegistry(
        fallback_provider=fallback_provider,
        questionnaire_provider=questionnaire_provider,
        persona_provider=persona_provider,
    )


__all__ = [
    "ClinicalPromptRegistry",
    "CompositePromptProvider",
    "PromptNotFoundError",
    "PromptRegistry",
    "ResolvedPrompt",
    "create_prompt_registry",
]
