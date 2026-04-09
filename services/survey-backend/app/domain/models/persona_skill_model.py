"""Persona skill catalog models for output-profile prompt composition."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator


class PersonaSkillUpsert(BaseModel):
    """Request shape for creating or updating a persona skill."""

    persona_skill_key: str = Field(..., alias="personaSkillKey", min_length=1)
    name: str = Field(..., min_length=1)
    output_profile: str = Field(..., alias="outputProfile", min_length=1)
    instructions: str = Field(..., min_length=1)

    model_config = ConfigDict(extra="forbid", populate_by_name=True)

    @field_validator("persona_skill_key", "output_profile")
    @classmethod
    def validate_key_fields(cls, value: str) -> str:
        """Require code-safe keys used in runtime requests and storage."""
        normalized = value.strip()
        if not normalized:
            raise ValueError("value must not be blank")
        allowed = set("abcdefghijklmnopqrstuvwxyz0123456789:_-")
        lowered = normalized.lower()
        if any(char not in allowed for char in lowered):
            raise ValueError(
                "value must contain only lowercase letters, digits, colon, underscore, or hyphen"
            )
        return lowered

    @field_validator("name", "instructions")
    @classmethod
    def trim_non_empty(cls, value: str) -> str:
        """Reject blank strings after trimming whitespace."""
        normalized = value.strip()
        if not normalized:
            raise ValueError("value must not be blank")
        return normalized


class PersonaSkill(PersonaSkillUpsert):
    """Stored persona skill returned through the API."""

    created_at: datetime = Field(..., alias="createdAt")
    modified_at: datetime = Field(..., alias="modifiedAt")
