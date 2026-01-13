from fastapi import APIRouter
from pydantic import BaseModel, Field

from app.config.logging_config import logger
from app.domain.models.agent_response_model import AgentResponse
from app.integrations.clinical_writer.client import send_to_langgraph_agent


router = APIRouter()


class ClinicalWriterRequest(BaseModel):
    content: str = Field(..., min_length=1, description="Conversation text or JSON string")


@router.post("/clinical_writer/process", response_model=AgentResponse)
async def process_clinical_writer(request: ClinicalWriterRequest) -> AgentResponse:
    """Forward a request to the Clinical Writer agent and return its response."""
    logger.info("Forwarding clinical writer request.")
    agent_result = await send_to_langgraph_agent(
        request.content,
        input_type="consult",
        prompt_key="default",
        source_app="clinical-writer",
    )
    try:
        return AgentResponse(**agent_result)
    except Exception as exc:  # pragma: no cover - guard for unexpected response shapes
        logger.error("Invalid data returned by agent: %s", exc)
        return AgentResponse(error_message="Invalid agent response format")
