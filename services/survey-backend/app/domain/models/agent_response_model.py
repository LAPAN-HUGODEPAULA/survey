from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AgentResponse(BaseModel):
    classification: Optional[str] = None
    medical_record: Optional[str] = Field(default=None, alias="medicalRecord")
    error_message: Optional[str] = Field(default=None, alias="errorMessage")

    model_config = ConfigDict(populate_by_name=True)
