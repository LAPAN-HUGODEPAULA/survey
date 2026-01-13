from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AgentResponse(BaseModel):
    ok: Optional[bool] = None
    input_type: Optional[str] = None
    prompt_version: Optional[str] = None
    model_version: Optional[str] = None
    report: Optional[dict] = None
    warnings: list[str] = Field(default_factory=list)
    classification: Optional[str] = None
    medical_record: Optional[str] = Field(default=None, alias="medicalRecord")
    error_message: Optional[str] = Field(default=None, alias="errorMessage")

    model_config = ConfigDict(populate_by_name=True)
