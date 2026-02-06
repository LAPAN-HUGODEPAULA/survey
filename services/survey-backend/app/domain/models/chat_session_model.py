from datetime import datetime
from typing import Optional, Dict, Any

from pydantic import BaseModel, Field, ConfigDict


class ChatSession(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    status: str = Field(default="active")
    phase: str = Field(default="intake")
    patient_id: Optional[str] = Field(default=None, alias="patientId")
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    completed_at: Optional[datetime] = Field(default=None, alias="completedAt")
    metadata: Optional[Dict[str, Any]] = None

    model_config = ConfigDict(extra="forbid", populate_by_name=True)
