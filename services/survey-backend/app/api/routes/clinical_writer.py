from fastapi import APIRouter
from pydantic import BaseModel, Field

from app.config.logging_config import logger
from app.domain.models.agent_response_model import AgentResponse
from app.integrations.clinical_writer.client import send_to_langgraph_agent


router = APIRouter()


class ClinicalWriterRequest(BaseModel):
    input_type: str = Field(..., description="consult|survey7|full_intake")
    content: str = Field(..., min_length=1, description="Conversation text or JSON string")
    locale: str = Field(default="pt-BR")
    prompt_key: str = Field(default="default")
    output_format: str = Field(default="report_json")
    metadata: dict = Field(default_factory=dict)


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
