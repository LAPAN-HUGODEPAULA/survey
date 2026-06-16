"""API models for report delivery endpoints."""

from pydantic import BaseModel, ConfigDict, Field


class SendReportEmailRequest(BaseModel):
    """Payload for report email delivery."""

    report_text: str | None = Field(default=None, alias="reportText")

    model_config = ConfigDict(populate_by_name=True)


class SendReportEmailResponse(BaseModel):
    """Response payload for report email delivery."""

    status: str
    response_id: str = Field(alias="responseId")
    recipients: list[str]

    model_config = ConfigDict(populate_by_name=True)
