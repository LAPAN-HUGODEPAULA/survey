# Package imports
import os
from datetime import datetime, timezone
from typing import Annotated, Literal, Optional, Union

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

app = FastAPI()

DEFAULT_LOCALE = "pt-BR"
PROMPT_VERSION = os.getenv("PROMPT_VERSION", "v1")
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


class Span(BaseModel):
    text: str
    bold: bool = False
    italic: bool = False


class ParagraphBlock(BaseModel):
    type: Literal["paragraph"] = "paragraph"
    spans: list[Span]


class BulletItem(BaseModel):
    spans: list[Span]


class BulletListBlock(BaseModel):
    type: Literal["bullet_list"] = "bullet_list"
    items: list[BulletItem]


class KeyValueItem(BaseModel):
    key: str
    value: list[Span]


class KeyValueBlock(BaseModel):
    type: Literal["key_value"] = "key_value"
    items: list[KeyValueItem]


Block = Annotated[
    Union[ParagraphBlock, BulletListBlock, KeyValueBlock],
    Field(discriminator="type"),
]


class Section(BaseModel):
    title: str
    blocks: list[Block]


class PatientInfo(BaseModel):
    name: Optional[str] = None
    reference: Optional[str] = None
    birth_date: Optional[str] = None
    sex: Optional[str] = None


class ReportDocument(BaseModel):
    title: str
    subtitle: Optional[str] = None
    created_at: datetime
    patient: PatientInfo
    sections: list[Section]


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


def _span(text: str) -> Span:
    return Span(text=text)


def _paragraph_block(text: str) -> ParagraphBlock:
    return ParagraphBlock(spans=[_span(text)])


def _bullet_block(items: list[str]) -> BulletListBlock:
    return BulletListBlock(items=[BulletItem(spans=[_span(item)]) for item in items])


def _parse_blocks(text: str) -> list[Block]:
    blocks: list[Block] = []
    for chunk in text.split("\n\n"):
        chunk = chunk.strip()
        if not chunk:
            continue
        lines = [line.strip() for line in chunk.splitlines() if line.strip()]
        if not lines:
            continue
        if all(line.startswith(("-", "•")) for line in lines):
            cleaned = [line.lstrip("-•").strip() for line in lines]
            blocks.append(_bullet_block(cleaned))
        else:
            blocks.append(_paragraph_block(" ".join(lines)))
    return blocks


def _build_report(
    request: ProcessRequest,
    final_state: dict,
    prompt_version: str,
) -> ProcessResponse:
    warnings: list[str] = []
    error_message = final_state.get("error_message")
    if error_message:
        warnings.append(str(error_message))

    sections: list[Section] = []
    classification = final_state.get("classification")
    if classification:
        sections.append(
            Section(
                title="Classificacao",
                blocks=[_paragraph_block(str(classification))],
            )
        )

    medical_record = final_state.get("medical_record")
    if medical_record:
        blocks = _parse_blocks(str(medical_record))
        if not blocks:
            blocks = [_paragraph_block(str(medical_record))]
        sections.append(Section(title="Registro Clinico", blocks=blocks))

    if not sections and warnings:
        sections.append(Section(title="Avisos", blocks=[_paragraph_block(warnings[0])]))

    report = ReportDocument(
        title="Relatorio Clinico",
        subtitle=f"Entrada: {request.input_type}",
        created_at=datetime.now(timezone.utc),
        patient=PatientInfo(reference=request.metadata.patient_ref),
        sections=sections,
    )

    return ProcessResponse(
        ok=not warnings,
        input_type=request.input_type,
        prompt_version=prompt_version,
        model_version=MODEL_VERSION,
        report=report,
        warnings=warnings,
    )


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
        _, prompt_version = prompt_registry.get_prompt(input.prompt_key)
    except PromptNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc

    state = {
        "input_content": input.content,
        "observer": observer
    }
    final_state = graph.invoke(state) # type: ignore

    # The observer field cannot be serialized, so we remove it.
    if 'observer' in final_state:
        del final_state['observer']

    return _build_report(input, final_state, prompt_version)

@app.get("/metrics")
async def get_metrics(observer = Depends(get_observer)):
    """Get collected metrics from the live metrics observer."""
    metrics_monitor = get_metrics_monitor(observer)
    return metrics_monitor.get_metrics_summary()
