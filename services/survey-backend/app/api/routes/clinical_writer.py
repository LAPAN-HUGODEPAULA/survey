import asyncio
import contextlib
import uuid
from typing import Any, Literal

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from app.config.logging_config import logger
from app.domain.models.agent_response_model import AgentResponse
from app.domain.models.ai_stages import AIProcessingStage, STAGE_MESSAGES_PTBR
from app.api.task_manager import task_manager
from app.integrations.clinical_writer.client import (
    fetch_langgraph_status,
    send_to_langgraph_agent,
    send_to_langgraph_analysis,
)


router = APIRouter()


class AIProgressPayload(BaseModel):
    stage: str = AIProcessingStage.QUEUED.value
    stage_label: str | None = Field(default=None, alias="stageLabel")
    percent: int = 0
    status: str = "processing"
    severity: Literal["info", "success", "warning", "critical"] = "info"
    retryable: bool = False
    user_message: str | None = Field(default=None, alias="userMessage")
    updated_at: str | None = Field(default=None, alias="updatedAt")

    model_config = {"populate_by_name": True}


class ClinicalWriterTaskError(BaseModel):
    retryable: bool
    user_message: str = Field(alias="userMessage")
    detail: str | None = None

    model_config = {"populate_by_name": True}


class ClinicalWriterRequest(BaseModel):
    input_type: str = Field(default="consult", description="consult|survey7|full_intake")
    content: str = Field(..., min_length=1, description="Conversation text or JSON string")
    locale: str = Field(default="pt-BR")
    prompt_key: str = Field(default="default")
    persona_skill_key: str | None = Field(default=None)
    output_profile: str | None = Field(default=None)
    output_format: str = Field(default="report_json")
    metadata: dict = Field(default_factory=dict)
    async_mode: bool = Field(default=True, alias="asyncMode")

    model_config = {"populate_by_name": True}


class ClinicalWriterTaskResponse(BaseModel):
    task_id: str = Field(alias="taskId")
    status: str
    ai_progress: AIProgressPayload = Field(alias="aiProgress")
    result: AgentResponse | None = None
    error: ClinicalWriterTaskError | None = None

    model_config = {"populate_by_name": True}


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


def _initial_progress() -> AIProgressPayload:
    return AIProgressPayload(
        stage=AIProcessingStage.QUEUED.value,
        stageLabel="Na fila",
        percent=2,
        status="processing",
        severity="info",
        retryable=False,
        userMessage=STAGE_MESSAGES_PTBR[AIProcessingStage.QUEUED],
    )


async def _poll_upstream_progress(task_id: str, request_id: str, stop_event: asyncio.Event) -> None:
    while not stop_event.is_set():
        try:
            progress = await fetch_langgraph_status(request_id)
            if progress:
                await task_manager.set_task(task_id, {"ai_progress": progress})
        except Exception as exc:  # pragma: no cover - polling failures should not fail tasks
            logger.debug("Unable to poll clinical writer status for task %s: %s", task_id, exc)
        await asyncio.sleep(1.0)


def _error_payload(agent_result: dict[str, Any]) -> ClinicalWriterTaskError:
    progress = agent_result.get("ai_progress") or {}
    retryable = bool(progress.get("retryable", False))
    detail = (
        agent_result.get("errorMessage")
        or agent_result.get("error_message")
        or "Falha ao processar a solicitação de IA."
    )
    user_message = progress.get("userMessage") or progress.get("user_message")
    if not user_message:
        user_message = (
            "Não foi possível concluir agora. Tente novamente em alguns instantes."
            if retryable
            else "Não conseguimos gerar a análise automática para este caso."
        )
    return ClinicalWriterTaskError(retryable=retryable, userMessage=user_message, detail=detail)


async def _run_background_task(task_id: str, request: ClinicalWriterRequest, request_id: str) -> None:
    await task_manager.set_task(task_id, {"status": "processing"})
    stop_event = asyncio.Event()
    poller = asyncio.create_task(_poll_upstream_progress(task_id, request_id, stop_event))

    try:
        agent_result = await send_to_langgraph_agent(
            request.content,
            input_type=request.input_type,
            prompt_key=request.prompt_key,
            persona_skill_key=request.persona_skill_key,
            output_profile=request.output_profile,
            source_app=request.metadata.get("source_app") or "clinical-writer",
            patient_ref=request.metadata.get("patient_ref"),
            request_id=request_id,
        )
        parsed_result = AgentResponse(**agent_result)
        has_error = bool(parsed_result.error_message)
        if has_error:
            error = _error_payload(agent_result)
            await task_manager.set_task(
                task_id,
                {
                    "status": "failed",
                    "result": None,
                    "error": error.model_dump(by_alias=True),
                    "ai_progress": {
                        "stage": AIProcessingStage.FAILED.value,
                        "stageLabel": "Falha",
                        "percent": 100,
                        "status": "failed",
                        "severity": "warning" if error.retryable else "critical",
                        "retryable": error.retryable,
                        "userMessage": error.user_message,
                    },
                },
            )
            return
        await task_manager.set_task(
            task_id,
            {
                "status": "completed",
                "result": parsed_result.model_dump(by_alias=True),
                "error": None,
                "ai_progress": {
                    "stage": AIProcessingStage.COMPLETED.value,
                    "stageLabel": "Concluído",
                    "percent": 100,
                    "status": "success",
                    "severity": "success",
                    "retryable": False,
                    "userMessage": "Relatório gerado com sucesso.",
                },
            },
        )
    except Exception as exc:  # pragma: no cover - defensive fallback
        await task_manager.set_task(
            task_id,
            {
                "status": "failed",
                "result": None,
                "error": ClinicalWriterTaskError(
                    retryable=True,
                    userMessage="Tivemos um atraso na análise, estamos tentando novamente...",
                    detail=str(exc),
                ).model_dump(by_alias=True),
                "ai_progress": {
                    "stage": AIProcessingStage.FAILED.value,
                    "stageLabel": "Falha",
                    "percent": 100,
                    "status": "failed",
                    "severity": "warning",
                    "retryable": True,
                    "userMessage": "Tivemos um atraso na análise, estamos tentando novamente...",
                },
            },
        )
    finally:
        stop_event.set()
        poller.cancel()
        with contextlib.suppress(asyncio.CancelledError):
            await poller


@router.post("/clinical_writer/process", response_model=AgentResponse | ClinicalWriterTaskResponse)
async def process_clinical_writer(request: ClinicalWriterRequest) -> AgentResponse | ClinicalWriterTaskResponse:
    """Forward a request to the Clinical Writer agent and optionally run it asynchronously."""
    logger.info("Forwarding clinical writer request.")

    if request.async_mode:
        request_id = request.metadata.get("request_id") or str(uuid.uuid4())
        task_id = request_id
        await task_manager.set_task(
            task_id,
            {
                "task_id": task_id,
                "status": "submitted",
                "ai_progress": _initial_progress().model_dump(by_alias=True),
                "result": None,
                "error": None,
            },
        )
        asyncio.create_task(_run_background_task(task_id, request, request_id))
        task = await task_manager.get_task(task_id)
        return ClinicalWriterTaskResponse(
            taskId=task_id,
            status=task["status"],
            aiProgress=task["ai_progress"],
            result=None,
            error=None,
        )

    agent_result = await send_to_langgraph_agent(
        request.content,
        input_type=request.input_type,
        prompt_key=request.prompt_key,
        persona_skill_key=request.persona_skill_key,
        output_profile=request.output_profile,
        source_app=request.metadata.get("source_app") or "clinical-writer",
        patient_ref=request.metadata.get("patient_ref"),
        request_id=request.metadata.get("request_id"),
    )
    try:
        return AgentResponse(**agent_result)
    except Exception as exc:  # pragma: no cover - guard for unexpected response shapes
        logger.error("Invalid data returned by agent: %s", exc)
        return AgentResponse(error_message="Invalid agent response format")


@router.get("/clinical_writer/status/{task_id}", response_model=ClinicalWriterTaskResponse)
async def get_clinical_writer_status(task_id: str) -> ClinicalWriterTaskResponse:
    """Get the current asynchronous processing status for a clinical writer task."""
    task = await task_manager.get_task(task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return ClinicalWriterTaskResponse(
        taskId=task_id,
        status=task.get("status", "submitted"),
        aiProgress=task.get("ai_progress") or _initial_progress().model_dump(by_alias=True),
        result=task.get("result"),
        error=task.get("error"),
    )


@router.post("/clinical_writer/analysis", response_model=ClinicalWriterAnalysisResponse)
async def analyze_clinical_writer(request: ClinicalWriterAnalysisRequest) -> ClinicalWriterAnalysisResponse:
    """Forward conversation analysis request to the Clinical Writer analysis engine."""
    logger.info("Forwarding clinical writer analysis request.")
    payload = request.model_dump(by_alias=True)
    result = await send_to_langgraph_analysis(payload)
    return ClinicalWriterAnalysisResponse(**result)
