"""Agent access-point catalog models."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.domain.models._key_validation import normalize_key


class AgentAccessPointUpsert(BaseModel):
    """Request shape for creating or updating an access point."""

    access_point_key: str = Field(..., alias="accessPointKey", min_length=1)
    name: str = Field(..., min_length=1)
    source_app: str = Field(..., alias="sourceApp", min_length=1)
    flow_key: str = Field(..., alias="flowKey", min_length=1)
    prompt_key: str = Field(..., alias="promptKey", min_length=1)
    persona_skill_key: str = Field(..., alias="personaSkillKey", min_length=1)
    output_profile: str = Field(..., alias="outputProfile", min_length=1)
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
    def validate_key_fields(cls, value: str, info) -> str:
        return normalize_key(value, field_name=info.field_name, allowed_extra_chars=".")

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

