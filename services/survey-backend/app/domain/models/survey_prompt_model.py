"""Questionnaire prompt catalog and survey reference models."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator


class SurveyPromptReference(BaseModel):
    """Compact questionnaire prompt reference embedded inside a survey definition."""

    prompt_key: str = Field(..., alias="promptKey")
    name: str

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class SurveyPromptUpsert(BaseModel):
    """Request shape for creating or updating questionnaire clinical logic."""

    prompt_key: str = Field(..., alias="promptKey", min_length=1)
    name: str = Field(..., min_length=1)
    prompt_text: str = Field(..., alias="promptText", min_length=1)

    model_config = ConfigDict(extra="forbid", populate_by_name=True)

    @field_validator("prompt_key")
    @classmethod
    def validate_prompt_key(cls, value: str) -> str:
        """Require a code-safe key that works in runtime calls."""
        normalized = value.strip()
        if not normalized:
            raise ValueError("promptKey must not be blank")
        allowed = set("abcdefghijklmnopqrstuvwxyz0123456789:_-")
        lowered = normalized.lower()
        if any(char not in allowed for char in lowered):
            raise ValueError(
                "promptKey must contain only lowercase letters, digits, colon, underscore, or hyphen"
            )
        return lowered

    @field_validator("name", "prompt_text")
    @classmethod
    def trim_non_empty(cls, value: str) -> str:
        """Reject blank strings after trimming whitespace."""
        normalized = value.strip()
        if not normalized:
            raise ValueError("value must not be blank")
        return normalized


class SurveyPrompt(SurveyPromptUpsert):
    """Stored questionnaire prompt definition returned through the API."""

    created_at: datetime = Field(..., alias="createdAt")
    modified_at: datetime = Field(..., alias="modifiedAt")
