from datetime import datetime
from typing import Optional, Dict, Any

from pydantic import BaseModel, Field, ConfigDict


class ChatMessage(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    session_id: str = Field(..., alias="sessionId")
    role: str
    message_type: str = Field(..., alias="messageType")
    content: str
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")
    updated_at: datetime = Field(default_factory=datetime.utcnow, alias="updatedAt")
    deleted_at: Optional[datetime] = Field(default=None, alias="deletedAt")
    metadata: Optional[Dict[str, Any]] = None
    edit_history: Optional[list[Dict[str, Any]]] = Field(default=None, alias="editHistory")

    model_config = ConfigDict(extra="forbid", populate_by_name=True)
