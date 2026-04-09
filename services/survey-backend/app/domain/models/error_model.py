from typing import Any, Literal
from pydantic import BaseModel, Field

class ApiError(BaseModel):
    """Standardized error object for frontend-safe responses."""
    code: str = Field(..., description="Stable string identifier for the error category")
    user_message: str = Field(..., alias="userMessage", description="Localized, human-readable message in pt-BR")
    severity: Literal["info", "warning", "error", "critical"] = Field(default="error")
    retryable: bool = Field(default=False, description="Indicates if the operation should be retried")
    request_id: str | None = Field(default=None, alias="requestId", description="Unique ID for correlation/support")
    operation: str | None = Field(default=None, description="The name of the attempted action")
    stage: str | None = Field(default=None, description="Current processing stage if applicable")
    details: list[dict[str, Any]] | None = Field(default=None, description="Optional list of field-specific validation errors")

    model_config = {"populate_by_name": True}
