# Package imports
import os
from datetime import datetime, timezone
from typing import Literal, Optional

from fastapi import FastAPI, Depends, HTTPException, Security, status
from fastapi.security import APIKeyHeader
from pydantic import BaseModel, Field, field_validator

# Project imports
from .agent_graph import (
    clinical_writer_graph,
    get_metrics_monitor,
    get_shared_observer,
)
from .prompt_registry import PromptNotFoundError, create_prompt_registry
from .report_models import ReportDocument

app = FastAPI()

DEFAULT_LOCALE = "pt-BR"
MODEL_VERSION = os.getenv("MODEL_VERSION", "unknown")


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
    input_type: str
    prompt_version: str
    model_version: str
    report: ReportDocument
    warnings: list[str] = Field(default_factory=list)


api_key_header = APIKeyHeader(name="Authorization", auto_error=False)

def verify_token(api_key: Optional[str] = Security(api_key_header)) -> bool:
    """
    Basic bearer token guard. If API_TOKEN is set, enforce Authorization: Bearer <token>.
    If no token is configured, allow all requests (development-friendly).
    """
    expected_token = os.getenv("API_TOKEN")
    if not expected_token:
        return True

    if not api_key or api_key != f"Bearer {expected_token}":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API token",
        )
    return True

def get_graph():
    return clinical_writer_graph


def get_observer(graph = Depends(get_graph)):
    # Prefer the observer attached to the graph; fall back to the shared default.
    observer = getattr(graph, "observer", None)
    return observer or get_shared_observer()

_prompt_registry = None


def get_prompt_registry():
    global _prompt_registry
    if _prompt_registry is None:
        _prompt_registry = create_prompt_registry()
    return _prompt_registry


def _validate_report(report_payload: object) -> ReportDocument:
    try:
        return ReportDocument.model_validate(report_payload)
    except Exception as exc:  # pragma: no cover - explicit error message for clients
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Invalid report JSON: {exc}",
        ) from exc


@app.get("/")
async def root():
    return {"message": "Clinical Writer AI Multiagent System is running! Use the /process endpoint to process clinical data."}

@app.post("/process", response_model=ProcessResponse, dependencies=[Depends(verify_token)])
async def process_content(
    input: ProcessRequest,
    graph = Depends(get_graph),
    observer = Depends(get_observer),
    prompt_registry = Depends(get_prompt_registry),
):
    try:
        prompt_text, prompt_version = prompt_registry.get_prompt(input.prompt_key)
    except PromptNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc

    state = {
        "input_content": input.content,
        "observer": observer,
        "input_type": input.input_type,
        "request_id": input.metadata.request_id,
        "prompt_key": input.prompt_key,
        "prompt_version": prompt_version,
        "prompt_text": prompt_text,
        "model_version": MODEL_VERSION,
    }
    final_state = graph.invoke(state) # type: ignore

    # The observer field cannot be serialized, so we remove it.
    if 'observer' in final_state:
        del final_state['observer']

    if final_state.get("error_message"):
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(final_state["error_message"]),
        )

    report_payload = final_state.get("report")
    if report_payload is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Missing report payload from writer node.",
        )

    report = _validate_report(report_payload)

    return ProcessResponse(
        ok=True,
        input_type=input.input_type,
        prompt_version=final_state.get("prompt_version", prompt_version),
        model_version=final_state.get("model_version", MODEL_VERSION),
        report=report,
        warnings=[],
    )

@app.get("/metrics")
async def get_metrics(observer = Depends(get_observer)):
    """Get collected metrics from the live metrics observer."""
    metrics_monitor = get_metrics_monitor(observer)
    return metrics_monitor.get_metrics_summary()
