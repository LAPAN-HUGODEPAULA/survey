"""Agent access-point catalog models."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from app.domain.models._key_validation import normalize_key


class AIAgentRouteRef(BaseModel):
    """Ordered reference to a configured AI agent for an access point."""

    agent_key: str = Field(..., alias="agentKey")
    model: str | None = None
    temperature: float | None = Field(default=None, ge=0.0, le=1.0)
    max_tokens: int | None = Field(default=None, alias="maxTokens", gt=0)
    enabled: bool = True

    model_config = ConfigDict(populate_by_name=True)

    @field_validator("agent_key")
    @classmethod
    def validate_agent_key(cls, value: str) -> str:
        return normalize_key(value, field_name="agent_key", allowed_extra_chars=".")

    @field_validator("model")
    @classmethod
    def trim_optional_model(cls, value: str | None) -> str | None:
        if value is None:
            return None
        normalized = value.strip()
        return normalized or None


class AIConfig(BaseModel):
    """Configuration for the AI model used by the access point."""

    agent_refs: list[AIAgentRouteRef] | None = Field(default=None, alias="agentRefs")
    primary_provider: str | None = Field(default=None, alias="primaryProvider")
    primary_model: str | None = Field(default=None, alias="primaryModel")
    fallback_provider: str | None = Field(default=None, alias="fallbackProvider")
    fallback_model: str | None = Field(default=None, alias="fallbackModel")
    temperature: float = Field(default=0.0, ge=0.0, le=1.0)
    reasoning_effort: str | None = Field(default="low", alias="reasoningEffort")
    enable_caching: bool = Field(default=True, alias="enableCaching")

    model_config = ConfigDict(populate_by_name=True)

    @model_validator(mode="after")
    def validate_route_or_legacy_model(self) -> "AIConfig":
        has_enabled_agent_ref = any(ref.enabled for ref in self.agent_refs or [])
        has_legacy_primary = bool(self.primary_provider and self.primary_model)
        if not has_enabled_agent_ref and not has_legacy_primary:
            raise ValueError("aiConfig must define agentRefs or primaryProvider/primaryModel")
        return self

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
