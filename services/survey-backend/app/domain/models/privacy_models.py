from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class PrivacyRequest(BaseModel):
    id: str = Field(default="", alias="_id")
    request_type: str = Field(..., alias="requestType")
    subject_type: str = Field(..., alias="subjectType")
    subject_id: Optional[str] = Field(default=None, alias="subjectId")
    requester_email: Optional[str] = Field(default=None, alias="requesterEmail")
    requester_name: Optional[str] = Field(default=None, alias="requesterName")
    details: Optional[str] = None
    status: str = "pending"
    created_at: Optional[datetime] = Field(default=None, alias="createdAt")
    updated_at: Optional[datetime] = Field(default=None, alias="updatedAt")
    fulfilled_at: Optional[datetime] = Field(default=None, alias="fulfilledAt")
    resolution_note: Optional[str] = Field(default=None, alias="resolutionNote")
    metadata: Optional[dict] = None

    model_config = ConfigDict(populate_by_name=True, from_attributes=True)


class PrivacyRequestCreate(BaseModel):
    request_type: str = Field(..., alias="requestType")
    subject_type: str = Field(..., alias="subjectType")
    subject_id: Optional[str] = Field(default=None, alias="subjectId")
    requester_email: Optional[str] = Field(default=None, alias="requesterEmail")
    requester_name: Optional[str] = Field(default=None, alias="requesterName")
    details: Optional[str] = None
    metadata: Optional[dict] = None

    model_config = ConfigDict(populate_by_name=True, extra="forbid")


class PrivacyRequestUpdate(BaseModel):
    status: Optional[str] = None
    resolution_note: Optional[str] = Field(default=None, alias="resolutionNote")
    metadata: Optional[dict] = None

    model_config = ConfigDict(populate_by_name=True, extra="forbid")


class DataLifecycleJob(BaseModel):
    id: str = Field(default="", alias="_id")
    request_id: str = Field(..., alias="requestId")
    action: str
    subject_type: str = Field(..., alias="subjectType")
    subject_id: Optional[str] = Field(default=None, alias="subjectId")
    status: str = "queued"
    created_at: Optional[datetime] = Field(default=None, alias="createdAt")
    updated_at: Optional[datetime] = Field(default=None, alias="updatedAt")
    metadata: Optional[dict] = None

    model_config = ConfigDict(populate_by_name=True, from_attributes=True)


class SecurityAuditLog(BaseModel):
    id: str = Field(default="", alias="_id")
    event_type: str = Field(..., alias="eventType")
    actor: Optional[dict] = None
    target: Optional[dict] = None
    payload: Optional[dict] = None
    created_at: Optional[datetime] = Field(default=None, alias="createdAt")
    prev_hash: Optional[str] = Field(default=None, alias="prevHash")
    hash: Optional[str] = None

    model_config = ConfigDict(populate_by_name=True, from_attributes=True)
