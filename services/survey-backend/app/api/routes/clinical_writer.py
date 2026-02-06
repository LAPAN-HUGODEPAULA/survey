from fastapi import APIRouter
from pydantic import BaseModel, Field

from app.config.logging_config import logger
from app.domain.models.agent_response_model import AgentResponse
from app.integrations.clinical_writer.client import send_to_langgraph_agent, send_to_langgraph_analysis


router = APIRouter()


class ClinicalWriterRequest(BaseModel):
    input_type: str = Field(default="consult", description="consult|survey7|full_intake")
    content: str = Field(..., min_length=1, description="Conversation text or JSON string")
    locale: str = Field(default="pt-BR")
    prompt_key: str = Field(default="default")
    output_format: str = Field(default="report_json")
    metadata: dict = Field(default_factory=dict)


class AnalysisMessage(BaseModel):
    role: str
    content: str
    message_type: str = Field(..., alias="messageType")

    model_config = {"populate_by_name": True, "extra": "forbid"}


class ClinicalWriterAnalysisRequest(BaseModel):
    session_id: str | None = Field(default=None, alias="sessionId")
    phase: str | None = None
    messages: list[AnalysisMessage]

    model_config = {"populate_by_name": True, "extra": "forbid"}


class ClinicalWriterAnalysisResponse(BaseModel):
    suggestions: list[dict] = Field(default_factory=list)
    entities: list[dict] = Field(default_factory=list)
    alerts: list[dict] = Field(default_factory=list)
    hypotheses: list[dict] = Field(default_factory=list)
    knowledge: list[dict] = Field(default_factory=list)
    phase: str | None = None


@router.post("/clinical_writer/process", response_model=AgentResponse)
async def process_clinical_writer(request: ClinicalWriterRequest) -> AgentResponse:
    """Forward a request to the Clinical Writer agent and return its response."""
    logger.info("Forwarding clinical writer request.")
    agent_result = await send_to_langgraph_agent(
        request.content,
        input_type=request.input_type,
        prompt_key=request.prompt_key,
        source_app=request.metadata.get("source_app") or "clinical-writer",
        patient_ref=request.metadata.get("patient_ref"),
        request_id=request.metadata.get("request_id"),
    )
    try:
        return AgentResponse(**agent_result)
    except Exception as exc:  # pragma: no cover - guard for unexpected response shapes
        logger.error("Invalid data returned by agent: %s", exc)
        return AgentResponse(error_message="Invalid agent response format")


@router.post("/clinical_writer/analysis", response_model=ClinicalWriterAnalysisResponse)
async def analyze_clinical_writer(request: ClinicalWriterAnalysisRequest) -> ClinicalWriterAnalysisResponse:
    """Forward conversation analysis request to the Clinical Writer analysis engine."""
    logger.info("Forwarding clinical writer analysis request.")
    payload = request.model_dump(by_alias=True)
    result = await send_to_langgraph_analysis(payload)
    return ClinicalWriterAnalysisResponse(**result)
