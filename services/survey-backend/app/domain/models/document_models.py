from datetime import datetime
from typing import Optional, Dict, Any, List

from pydantic import BaseModel, Field, ConfigDict


class DocumentPreviewRequest(BaseModel):
    session_id: str = Field(..., alias="sessionId")
    document_type: str = Field(..., alias="documentType")
    title: Optional[str] = None
    body: Optional[str] = None

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class DocumentExportRequest(BaseModel):
    session_id: str = Field(..., alias="sessionId")
    document_type: str = Field(..., alias="documentType")
    title: str
    body: str
    metadata: Optional[Dict[str, Any]] = None

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class DocumentPreview(BaseModel):
    html: str
    title: str
    body: str
    missing_fields: List[str] = Field(default_factory=list, alias="missingFields")
    metadata: Dict[str, Any] = Field(default_factory=dict)

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class DocumentRecord(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    session_id: str = Field(..., alias="sessionId")
    document_type: str = Field(..., alias="documentType")
    title: str
    body: str
    html: str
    status: str = Field(default="final")
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    metadata: Optional[Dict[str, Any]] = None

    model_config = ConfigDict(extra="forbid", populate_by_name=True)
