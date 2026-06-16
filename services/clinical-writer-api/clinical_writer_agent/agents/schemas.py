"""Typed Pydantic boundaries for layered clinical-writer graph stages."""

from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field


class _StageModel(BaseModel):
    """Base schema that ignores unrelated graph-state keys."""

    model_config = ConfigDict(extra="ignore")


class ContextLoaderInput(_StageModel):
    input_type: str = ""
    prompt_key: str = "default"
    persona_skill_key: str | None = None
    output_profile: str | None = None
    system_prompt_override: str | None = None
    format_prompt_override: str | None = None


class ContextLoaderOutput(_StageModel):
    prompt_version: str
    questionnaire_prompt_version: str = ""
    persona_skill_version: str = ""
    persona_skill_key: str = ""
    output_profile: str = ""
    prompt_text: str
    interpretation_prompt: str
    persona_prompt: str
    validation_status: str
    error_kind: str | None = None
    error_message: str | None = None


class ClinicalAnalyzerInput(_StageModel):
    input_type: str = ""
    interpretation_prompt: str = ""
    input_content: str = ""
    format_prompt_override: str | None = None
    ai_config: dict[str, Any] | None = None
    temperature: float | None = None
    do_sample: bool | None = None
    thinking_mode: str | None = None
    enable_caching: bool | None = None
    request_id: str | None = None


class ClinicalAnalyzerOutput(_StageModel):
    clinical_facts: dict[str, Any]
    model_version: str
    validation_status: str
    error_kind: str | None = None
    error_message: str | None = None


class PersonaWriterInput(_StageModel):
    input_type: str = ""
    persona_prompt: str = ""
    clinical_facts: dict[str, Any] = Field(default_factory=dict)
    format_prompt_override: str | None = None
    ai_config: dict[str, Any] | None = None
    temperature: float | None = None
    do_sample: bool | None = None
    thinking_mode: str | None = None
    enable_caching: bool | None = None
    request_id: str | None = None
    reflection_feedback: str | None = None
    reflection_retries_used: int = 0


class PersonaWriterOutput(_StageModel):
    report: dict[str, Any]
    draft_narrative: str
    medical_record: str
    model_version: str
    validation_status: str
    error_kind: str | None = None
    error_message: str | None = None


class ReflectorInput(_StageModel):
    input_type: str = ""
    persona_prompt: str = ""
    clinical_facts: dict[str, Any] = Field(default_factory=dict)
    report: dict[str, Any]
    ai_config: dict[str, Any] | None = None
    temperature: float | None = None
    do_sample: bool | None = None
    thinking_mode: str | None = None
    enable_caching: bool | None = None
    request_id: str | None = None
    reflection_feedback: str | None = None
    reflection_retries_used: int = 0
    warnings: list[str] = Field(default_factory=list)


class ReflectionAssessment(_StageModel):
    grounded: bool
    tone_ok: bool
    safety_ok: bool
    issues: list[str] = Field(default_factory=list)
    revision_instructions: str = ""


class ReflectorOutput(_StageModel):
    reflection_outcome: Literal["retry", "accepted", "accepted_with_warning", "error"]
    reflection_feedback: str | None = None
    reflection_retries_used: int = 0
    warnings: list[str] = Field(default_factory=list)
    validation_status: str = "written"
    error_kind: str | None = None
    error_message: str | None = None
