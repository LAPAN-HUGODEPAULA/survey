from datetime import datetime, timezone

from pydantic import BaseModel, ConfigDict, Field


class ScreenerAccessLinkModel(BaseModel):
    """Vincula um screener autenticado a um questionario compartilhavel."""

    id: str = Field(..., alias="_id")
    screener_id: str = Field(..., alias="screenerId")
    screener_name: str = Field(..., alias="screenerName")
    survey_id: str = Field(..., alias="surveyId")
    survey_display_name: str = Field(..., alias="surveyDisplayName")
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="createdAt",
    )

    model_config = ConfigDict(populate_by_name=True, extra="forbid")
