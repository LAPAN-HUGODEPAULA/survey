from datetime import datetime
from typing import Optional, List, Dict, Any

from pydantic import BaseModel, Field, ConfigDict


class TemplateRecord(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    template_group_id: Optional[str] = Field(default=None, alias="templateGroupId")
    name: str
    document_type: str = Field(..., alias="documentType")
    version: str = Field(default="1.0.0")
    status: str = Field(default="draft")
    body: str
    placeholders: List[str] = Field(default_factory=list)
    conditions: Optional[List[Dict[str, Any]]] = None
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    approved_at: Optional[datetime] = Field(default=None, alias="approvedAt")
    created_by: Optional[str] = Field(default=None, alias="createdBy")
    updated_by: Optional[str] = Field(default=None, alias="updatedBy")
    approved_by: Optional[str] = Field(default=None, alias="approvedBy")

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class TemplateCreateRequest(BaseModel):
    name: str
    document_type: str = Field(..., alias="documentType")
    body: str
    placeholders: List[str] = Field(default_factory=list)
    conditions: Optional[List[Dict[str, Any]]] = None

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class TemplateUpdateRequest(BaseModel):
    name: Optional[str] = None
    document_type: Optional[str] = Field(default=None, alias="documentType")
    body: str
    placeholders: List[str] = Field(default_factory=list)
    conditions: Optional[List[Dict[str, Any]]] = None

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class TemplatePreviewRequest(BaseModel):
    sample_data: Dict[str, Any] = Field(default_factory=dict, alias="sampleData")

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class TemplatePreviewResponse(BaseModel):
    html: str
    title: str
    body: str
    missing_fields: List[str] = Field(default_factory=list, alias="missingFields")
    metadata: Dict[str, Any] = Field(default_factory=dict)

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class TemplateAuditRecord(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    template_id: Optional[str] = Field(default=None, alias="templateId")
    template_group_id: Optional[str] = Field(default=None, alias="templateGroupId")
    version: Optional[str] = None
    action: str
    status: Optional[str] = None
    actor: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    metadata: Dict[str, Any] = Field(default_factory=dict)

    model_config = ConfigDict(extra="forbid", populate_by_name=True)
