"""Agent access-point catalog models."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.domain.models._key_validation import normalize_key


class AIConfig(BaseModel):
    """Configuration for the AI model used by the access point."""

    primary_provider: str = Field(..., alias="primaryProvider")
    primary_model: str = Field(..., alias="primaryModel")
    fallback_provider: str | None = Field(default=None, alias="fallbackProvider")
    fallback_model: str | None = Field(default=None, alias="fallbackModel")
    temperature: float = Field(default=0.0, ge=0.0, le=1.0)
    reasoning_effort: str | None = Field(default="low", alias="reasoningEffort")
    enable_caching: bool = Field(default=True, alias="enableCaching")

    model_config = ConfigDict(populate_by_name=True)

    @field_validator("reasoning_effort")
    @classmethod
    def validate_reasoning_effort(cls, value: str | None) -> str | None:
        if value is None:
            return None
        allowed = {"low", "medium", "high"}
        if value.lower() not in allowed:
            raise ValueError(f"reasoningEffort must be one of {allowed}")
        return value.lower()


class AgentAccessPointUpsert(BaseModel):
    """Request shape for creating or updating an access point."""

    access_point_key: str = Field(..., alias="accessPointKey", min_length=1)
    name: str = Field(..., min_length=1)
    source_app: str = Field(..., alias="sourceApp", min_length=1)
    flow_key: str = Field(..., alias="flowKey", min_length=1)
    prompt_key: str | None = Field(default=None, alias="promptKey")
    persona_skill_key: str | None = Field(default=None, alias="personaSkillKey")
    output_profile: str | None = Field(default=None, alias="outputProfile")
    ai_config: AIConfig | None = Field(default=None, alias="aiConfig")
    ai_provider: str | None = Field(default=None, alias="aiProvider")
    glm_model: str | None = Field(default=None, alias="glmModel")
    gemini_model: str | None = Field(default=None, alias="geminiModel")
    system_prompt_override: str | None = Field(default=None, alias="systemPromptOverride")
    format_prompt_override: str | None = Field(default=None, alias="formatPromptOverride")
    survey_id: str | None = Field(default=None, alias="surveyId")
    description: str | None = None

    model_config = ConfigDict(extra="forbid", populate_by_name=True)

    @field_validator(
        "access_point_key",
        "source_app",
        "flow_key",
        "prompt_key",
        "persona_skill_key",
        "output_profile",
        "ai_provider",
        "glm_model",
        "gemini_model",
    )
    @classmethod
    def validate_key_fields(cls, value: str | None, info) -> str | None:
        if value is None:
            return None
        return normalize_key(
            value,
            field_name=info.field_name,
            allowed_extra_chars=".",
            optional=True,
        )

    @field_validator("name")
    @classmethod
    def trim_name(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("name must not be blank")
        return normalized

    @field_validator("description")
    @classmethod
    def trim_optional_description(cls, value: str | None) -> str | None:
        if value is None:
            return None
        normalized = value.strip()
        return normalized or None

    @field_validator("survey_id")
    @classmethod
    def trim_optional_survey_id(cls, value: str | None) -> str | None:
        if value is None:
            return None
        normalized = value.strip()
        return normalized or None


class AgentAccessPoint(AgentAccessPointUpsert):
    """Stored agent access point returned through the API."""

    created_at: datetime = Field(..., alias="createdAt")
    modified_at: datetime = Field(..., alias="modifiedAt")

