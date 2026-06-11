"""AI agent catalog models."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.domain.models._key_validation import normalize_key


ProviderType = Literal["openai_compatible", "glm", "gemini"]


class AIAgentUpsert(BaseModel):
    """Request shape for creating or updating an AI agent catalog record."""

    agent_key: str = Field(..., alias="agentKey", min_length=1)
    name: str = Field(..., min_length=1)
    provider_type: ProviderType = Field(..., alias="providerType")
    base_url: str | None = Field(default=None, alias="baseUrl")
    api_key_env_var: str | None = Field(default=None, alias="apiKeyEnvVar")
    default_model: str = Field(..., alias="defaultModel", min_length=1)
    enabled: bool = True
    supports_openai_chat_completions: bool = Field(
        default=False,
        alias="supportsOpenAIChatCompletions",
    )
    supports_response_format: bool = Field(
        default=False,
        alias="supportsResponseFormat",
    )
    supports_rag: bool = Field(default=False, alias="supportsRag")
    notes: str | None = None

    model_config = ConfigDict(populate_by_name=True)

    @field_validator("agent_key")
    @classmethod
    def validate_agent_key(cls, value: str) -> str:
        return normalize_key(value, field_name="agent_key", allowed_extra_chars=".")

    @field_validator("name", "default_model")
    @classmethod
    def trim_required_text(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("value must not be blank")
        return normalized

    @field_validator("base_url", "api_key_env_var", "notes")
    @classmethod
    def trim_optional_text(cls, value: str | None) -> str | None:
        if value is None:
            return None
        normalized = value.strip()
        return normalized or None

    @field_validator("api_key_env_var")
    @classmethod
    def validate_api_key_env_var(cls, value: str | None) -> str | None:
        if value is None:
            return None
        if not value.replace("_", "").isalnum() or value[0].isdigit():
            raise ValueError("apiKeyEnvVar must be a valid environment variable name")
        return value


class AIAgent(AIAgentUpsert):
    """Stored AI agent catalog record returned through the API."""

    created_at: datetime = Field(..., alias="createdAt")
    modified_at: datetime = Field(..., alias="modifiedAt")
