# Package imports
import os
import logging
import uuid
from datetime import datetime, timezone
from typing import Literal, Optional

from fastapi import FastAPI, Depends, HTTPException, Security, status, Request
from fastapi.security import APIKeyHeader
from pydantic import BaseModel, Field, field_validator
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette_context import context, plugins
from starlette_context.middleware import RawContextMiddleware

# Project imports
from .agent_graph import (
    clinical_writer_graph,
    get_metrics_monitor,
    get_shared_observer,
)
from .prompt_registry import PromptNotFoundError, create_prompt_registry
from .report_models import ReportDocument

# ======================================================================================
# FastAPI App Initialization
# ======================================================================================

app = FastAPI(
    title="Clinical Writer AI Agent",
    description="An AI agent that processes clinical conversations and survey data to generate structured reports.",
    version="1.0.0",
)
logger = logging.getLogger("clinical_writer")

# ======================================================================================
# Constants and Configuration
# ======================================================================================

DEFAULT_LOCALE = "pt-BR"
MODEL_VERSION = os.getenv("MODEL_VERSION", "unknown")
API_TOKEN = os.getenv("API_TOKEN")

# ======================================================================================
# Middleware
# ======================================================================================

class RequestIdMiddleware(BaseHTTPMiddleware):
    """Injects a unique request ID into every request context."""

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint):
        request_id = str(uuid.uuid4())
        context["request_id"] = request_id
        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        return response

# The order of middleware is important. RawContextMiddleware should be first.
app.add_middleware(RawContextMiddleware, plugins=(plugins.RequestIdPlugin(),))
app.add_middleware(RequestIdMiddleware)

# ======================================================================================
# API Models
# ======================================================================================

class RequestMetadata(BaseModel):
    source_app: Optional[str] = None
    request_id: Optional[str] = None
    patient_ref: Optional[str] = None


class ProcessRequest(BaseModel):
    input_type: Literal["consult", "survey7", "full_intake"]
    content: str = Field(..., description="Conversation text or JSON string")
    locale: str = Field(default=DEFAULT_LOCALE)
    prompt_key: str = Field(default="default")
    output_format: Literal["report_json"] = Field(default="report_json")
    metadata: RequestMetadata = Field(default_factory=RequestMetadata)

    @field_validator("content")
    @classmethod
    def content_must_not_be_empty(cls, value: str) -> str:
        """Ensure content is not empty or whitespace."""
        if not value or not value.strip():
            raise ValueError("content must not be empty")
        return value.strip()


class ProcessResponse(BaseModel):
    ok: bool
    request_id: str
    input_type: str
    prompt_version: str
    model_version: str
    report: ReportDocument
    warnings: list[str] = Field(default_factory=list)


# ======================================================================================
# Security and Dependencies
# ======================================================================================

api_key_header = APIKeyHeader(name="Authorization", auto_error=False)

def verify_token(api_key: Optional[str] = Security(api_key_header)) -> bool:
    """
    Bearer token guard. If API_TOKEN is not set, allows all requests.
    Otherwise, it enforces `Authorization: Bearer <token>`.
    """
    if not API_TOKEN:
        return True

    if not api_key or api_key != f"Bearer {API_TOKEN}":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API token",
        )
    return True

def get_graph():
    """Dependency to get the compiled LangGraph."""
    return clinical_writer_graph

def get_observer():
    """Dependency to get the shared observer for logging/metrics."""
    return get_shared_observer()

_prompt_registry = create_prompt_registry()

def get_prompt_registry():
    """Dependency to get the prompt registry."""
    return _prompt_registry

# ======================================================================================
# Helper Functions
# ======================================================================================

def _validate_report(report_payload: object) -> ReportDocument:
    """Validate the structure of the generated report."""
    try:
        return ReportDocument.model_validate(report_payload)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Invalid report JSON generated by the model: {exc}",
        ) from exc

# ======================================================================================
# API Endpoints
# ======================================================================================

@app.get("/", summary="Root", tags=["Status"])
async def root():
    """Health check endpoint."""
    return {"message": "Clinical Writer AI Multiagent System is running."}

@app.post("/process", response_model=ProcessResponse, dependencies=[Depends(verify_token)], tags=["Processing"])
async def process_content(
    request: ProcessRequest,
    graph=Depends(get_graph),
    observer=Depends(get_observer),
    prompt_registry=Depends(get_prompt_registry),
):
    """
    Process clinical content (conversation or JSON) to generate a structured report.
    """
    request_id = context.get("request_id")
    logger.info(
        "Process request received: input_type=%s, prompt_key=%s, request_id=%s, content_length=%s",
        request.input_type,
        request.prompt_key,
        request_id,
        len(request.content),
    )
    try:
        prompt_text, prompt_version = prompt_registry.get_prompt(request.prompt_key)
    except PromptNotFoundError as exc:
        logger.warning(
            "Prompt not found: prompt_key=%s, request_id=%s",
            request.prompt_key,
            request_id,
        )
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc

    initial_state = {
        "input_content": request.content,
        "observer": observer,
        "input_type": request.input_type,
        "request_id": request_id,
        "prompt_key": request.prompt_key,
        "prompt_version": prompt_version,
        "prompt_text": prompt_text,
    }
    final_state = graph.invoke(initial_state)

    if 'observer' in final_state:
        del final_state['observer']

    if error_message := final_state.get("error_message"):
        logger.error(
            "Writer error: request_id=%s, input_type=%s, error=%s",
            request_id,
            request.input_type,
            error_message,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(error_message),
        )

    if not (report_payload := final_state.get("report")):
        logger.error(
            "Missing report payload: request_id=%s, input_type=%s",
            request_id,
            request.input_type,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Missing report payload from writer node.",
        )

    report = _validate_report(report_payload)

    response = ProcessResponse(
        ok=True,
        request_id=request_id,
        input_type=request.input_type,
        prompt_version=final_state.get("prompt_version", prompt_version),
        model_version=final_state.get("model_version", MODEL_VERSION),
        report=report,
    )
    logger.info(
        "Process request completed: request_id=%s, prompt_version=%s",
        request_id,
        response.prompt_version,
    )
    return response

@app.get("/metrics", summary="Get Live Metrics", tags=["Monitoring"])
async def get_metrics(observer=Depends(get_observer)):
    """Get collected metrics from the live metrics observer."""
    try:
        metrics_monitor = get_metrics_monitor(observer)
        return metrics_monitor.get_metrics_summary()
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc
