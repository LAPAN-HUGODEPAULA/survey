"""Audit domain models for builder administrative actions."""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class ActorInfo(BaseModel):
    """Information about who performed the action."""

    id: str = Field(..., description="Screener ID")
    email: str = Field(..., description="Screener email address")

    model_config = ConfigDict(populate_by_name=True)


class ResourceInfo(BaseModel):
    """Information about the resource being acted upon."""

    type: str = Field(..., description="Resource type: survey, prompt, persona_skill, agent_access_point")
    id: Optional[str] = Field(None, description="Resource ID (MongoDB ID)")
    key: Optional[str] = Field(None, description="Resource key (prompt_key, access_point_key, etc.)")
    name: Optional[str] = Field(None, description="Resource display name")

    model_config = ConfigDict(populate_by_name=True)


class SurveyOutcome(BaseModel):
    """Outcome data for survey operations."""

    survey_id: str = Field(..., alias="surveyId")
    version: datetime = Field(..., alias="version")
    display_name: Optional[str] = Field(None, alias="displayName")

    model_config = ConfigDict(populate_by_name=True)


class PromptOutcome(BaseModel):
    """Outcome data for prompt operations."""

    prompt_key: str = Field(..., alias="promptKey")
    name: str = Field(...)
    content_digest: str = Field(..., alias="contentDigest")
    version: datetime = Field(..., alias="version")
    word_count: int = Field(..., alias="wordCount")

    model_config = ConfigDict(populate_by_name=True)


class PersonaSkillOutcome(BaseModel):
    """Outcome data for persona skill operations."""

    persona_skill_key: str = Field(..., alias="personaSkillKey")
    name: str = Field(...)
    version: datetime = Field(..., alias="version")

    model_config = ConfigDict(populate_by_name=True)


class AgentAccessPointOutcome(BaseModel):
    """Outcome data for agent access point operations."""

    access_point_key: str = Field(..., alias="accessPointKey")
    name: str = Field(...)
    survey_id: Optional[str] = Field(None, alias="surveyId")
    prompt_key: str = Field(..., alias="promptKey")
    version: datetime = Field(..., alias="version")

    model_config = ConfigDict(populate_by_name=True)


class AuthOutcome(BaseModel):
    """Outcome data for authentication operations."""

    email: str = Field(...)
    ip_address: Optional[str] = Field(None, alias="ipAddress")
    user_agent: Optional[str] = Field(None, alias="userAgent")
    success: bool = Field(...)
    failure_reason: Optional[str] = Field(None, alias="failureReason")
    session_duration: Optional[int] = Field(None, alias="sessionDuration")

    model_config = ConfigDict(populate_by_name=True)


class BuilderAuditLog(BaseModel):
    """Audit record for builder administrative actions."""

    id: str = Field(default="", alias="_id")
    correlation_id: str = Field(..., alias="correlationId")
    namespace: str = "builder"

    # Core audit fields
    event_type: str = Field(..., alias="eventType")  # builder_create_survey, etc.
    actor: ActorInfo = Field(...)
    operation: str = Field(...)  # Fine-grained operation name
    status: str = Field(...)  # success|failed

    # Resource context
    resource: ResourceInfo = Field(...)

    # Outcome data
    outcome: dict = Field(...)  # Type-specific outcome data

    # Timing
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")

    # Optional
    payload: Optional[dict] = None  # Original request if needed

    model_config = ConfigDict(populate_by_name=True, populate_by_alias=True)


class BuilderAuditCreate(BaseModel):
    """Input model for creating builder audit records."""

    correlation_id: str = Field(..., alias="correlationId")
    event_type: str = Field(..., alias="eventType")
    actor: ActorInfo = Field(...)
    operation: str = Field(...)
    status: str = Field(...)
    resource: ResourceInfo = Field(...)
    outcome: dict = Field(...)

    model_config = ConfigDict(populate_by_name=True, populate_by_alias=True)