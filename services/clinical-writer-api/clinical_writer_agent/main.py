# Package imports
from contextlib import asynccontextmanager
import logging
import uuid
from datetime import datetime, timezone
from typing import Literal, Optional

from fastapi import FastAPI, Depends, HTTPException, Security, status, Request
from fastapi.responses import JSONResponse
from fastapi.security import APIKeyHeader
from pydantic import BaseModel, Field, field_validator
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
try:
    from starlette_context import context, plugins
    from starlette_context.errors import ContextDoesNotExistError
    from starlette_context.middleware import RawContextMiddleware
except ModuleNotFoundError:  # pragma: no cover - fallback for test environments
    context = {}
    plugins = None
    ContextDoesNotExistError = LookupError
    RawContextMiddleware = None

# Project imports
from .agent_graph import (
    clinical_writer_graph,
    get_metrics_monitor,
    get_progress_tracker,
    get_shared_observer,
)
from .prompt_registry import create_prompt_registry
from .report_models import ReportDocument
from .analysis_models import AnalysisRequest, AnalysisResponse
from .analysis_engine import (
    extract_entities,
    detect_phase,
    generate_suggestions,
    generate_hypotheses,
    detect_alerts,
    knowledge_lookup,
)
from .transcription_models import TranscriptionRequest, TranscriptionResponse
from .transcription_retention import cleanup_startup_audio_residue
from .transcription_service import transcribe
from .settings import Settings, settings

# ======================================================================================
# FastAPI App Initialization
# ======================================================================================

logging.basicConfig(level=logging.DEBUG)
logging.getLogger("pymongo").setLevel(logging.WARNING)
logger = logging.getLogger("clinical_writer")
logger.setLevel(logging.DEBUG)


@asynccontextmanager
async def lifespan(_app: FastAPI):
    """Validate runtime configuration before serving requests."""
    settings.validate_runtime_security()
    deleted_audio_files = cleanup_startup_audio_residue()
    if deleted_audio_files:
        logger.info(
            "Startup audio cleanup removed %d stranded files",
            len(deleted_audio_files),
        )
    logger.info("Clinical Writer API started successfully")
    yield
    logger.info("Clinical Writer API stopped")


app = FastAPI(
    title="Clinical Writer AI Agent",
    description="An AI agent that processes clinical conversations and survey data to generate structured reports.",
    version="0.2.0",
    lifespan=lifespan,
)

# ======================================================================================
# Constants and Configuration
# ======================================================================================

DEFAULT_LOCALE = "pt-BR"
MODEL_VERSION = settings.model_version

# ======================================================================================
# Middleware
# ======================================================================================

@app.middleware("http")
async def diagnostic_logging_middleware(request: Request, call_next):
    """Log raw request details to debug low-level 400 errors."""
    if request.url.path == "/process":
        body = await request.body()
        logger.debug("DIAGNOSTIC: Method=%s Path=%s Headers=%s Body=%s",
                     request.method, request.url.path, dict(request.headers), body.decode(errors='replace'))
        
        # Reposicionar o corpo para que o FastAPI possa lê-lo novamente
        async def receive():
            return {"type": "http.request", "body": body}
        request._receive = receive
        
    return await call_next(request)


# The order of middleware is important. RawContextMiddleware should be first.
# Temporarily disabled to debug 400 Bad Request
"""
if RawContextMiddleware is not None and plugins is not None:
    app.add_middleware(
        RawContextMiddleware,
        plugins=(plugins.RequestIdPlugin(),)
    )
"""


from fastapi.exceptions import RequestValidationError
from pydantic import BaseModel, Field, field_validator, ConfigDict

# ======================================================================================
# API Models
# ======================================================================================

class RequestMetadata(BaseModel):
    model_config = ConfigDict(extra="ignore")
    source_app: Optional[str] = None
    request_id: Optional[str] = None
    patient_ref: Optional[str] = None


class ProcessRequest(BaseModel):
    model_config = ConfigDict(extra="ignore")
    input_type: Literal["consult", "survey7", "full_intake"]
    content: str = Field(..., description="Conversation text or JSON string")
    locale: str = Field(default=DEFAULT_LOCALE)
    prompt_key: str = Field(default="default")
    persona_skill_key: Optional[str] = Field(default=None)
    output_profile: Optional[str] = Field(default=None)
    ai_config: Optional[dict] = Field(default=None, alias="aiConfig")
    system_prompt_override: Optional[str] = Field(default=None)
    format_prompt_override: Optional[str] = Field(default=None)
    temperature: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    do_sample: Optional[bool] = Field(default=None)
    thinking_mode: Optional[str] = Field(default=None)
    enable_caching: Optional[bool] = Field(default=None)
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
    questionnaire_prompt_version: Optional[str] = None
    persona_skill_version: Optional[str] = None
    model_version: str
    report: ReportDocument
    warnings: list[str] = Field(default_factory=list)
    ai_progress: dict = Field(default_factory=dict)


class ProcessStatusResponse(BaseModel):
    request_id: str
    ai_progress: dict


# ======================================================================================
# Security and Dependencies
# ======================================================================================

api_key_header = APIKeyHeader(name="Authorization", auto_error=False)


def verify_token(api_key: Optional[str] = Security(api_key_header)) -> bool:
    """
    Bearer token guard. Production must either configure API_TOKEN or explicitly
    opt into unauthenticated access for controlled environments.
    """
    runtime_settings = Settings()
    configured_token = runtime_settings.api_token_value
    
    # Debug log to help identify 401 issues (redacted for safety but showing presence)
    if configured_token:
        logger.debug("Auth: API_TOKEN is configured (length=%d)", len(configured_token))
    else:
        logger.debug("Auth: API_TOKEN is NOT configured")

    if not configured_token:
        if runtime_settings.is_production and not runtime_settings.allow_unauthenticated_access:
            logger.error("Auth failure: API_TOKEN missing in production")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="API token is not configured",
            )
        return True

    if runtime_settings.allow_unauthenticated_access:
        logger.debug("Auth: Unauthenticated access allowed by configuration")
        return True

    expected = f"Bearer {configured_token}"
    if not api_key or api_key != expected:
        logger.warning("Auth failure: Received %s, expected Bearer length=%d", 
                       "missing" if not api_key else "invalid token", 
                       len(expected))
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

def get_tracker():
    """Dependency to get the shared progress tracker."""
    return get_progress_tracker()

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


def _store_request_id(request_id: str) -> None:
    """Best-effort propagation of request ids to request-scoped context."""
    try:
        context["request_id"] = request_id
    except (ContextDoesNotExistError, LookupError, TypeError):
        # Direct function calls in tests and scripts may execute without
        # Starlette request-context middleware. The graph still carries the id
        # through explicit state, so request-scoped storage is optional here.
        return


def _resolve_process_request_id(body: ProcessRequest, request: Request) -> str:
    """Use caller-provided request ids so status polling targets the active run."""
    header_request_id = request.headers.get("x-request-id")
    if header_request_id:
        return header_request_id
    if body.metadata.request_id:
        return body.metadata.request_id
    return str(uuid.uuid4())

# ======================================================================================
# API Endpoints
# ======================================================================================

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Log validation errors to help debug 400 Bad Request responses."""
    logger.error("Validation error for %s: %s", request.url, exc.errors())
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": exc.errors(), "body": exc.body},
    )


@app.get("/", summary="Root", tags=["Status"])
async def root():
    """Health check endpoint."""
    return {"message": "Clinical Writer AI Multiagent System is running."}


@app.get("/healthz", summary="Health", tags=["Status"])
async def healthz():
    """Lightweight liveness probe for upstream callers."""
    return {
        "ok": True,
        "service": "clinical_writer_agent",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }

@app.post("/process", response_model=ProcessResponse, dependencies=[Depends(verify_token)], tags=["Processing"])
async def process_content(
    body: ProcessRequest,
    request: Request,
    graph=Depends(get_graph),
    observer=Depends(get_observer),
    prompt_registry=Depends(get_prompt_registry),
    tracker=Depends(get_tracker),
):
    """
    Process clinical content (conversation or JSON) to generate a structured report.
    """
    request_id = _resolve_process_request_id(body, request)
    _store_request_id(request_id)
    logger.info(
        "Process request received: input_type=%s, prompt_key=%s, persona_skill_key=%s, output_profile=%s, request_id=%s, content_length=%s",
        body.input_type,
        body.prompt_key,
        body.persona_skill_key,
        body.output_profile,
        request_id,
        len(body.content),
    )
    tracker.start(request_id)
    initial_state = {
        "input_content": body.content,
        "observer": observer,
        "input_type": body.input_type,
        "request_id": request_id,
        "prompt_key": body.prompt_key,
        "persona_skill_key": body.persona_skill_key,
        "output_profile": body.output_profile,
        "ai_config": body.ai_config,
        "system_prompt_override": body.system_prompt_override,
        "format_prompt_override": body.format_prompt_override,
        "temperature": body.temperature,
        "do_sample": body.do_sample,
        "thinking_mode": body.thinking_mode,
        "enable_caching": body.enable_caching,
        "prompt_registry": prompt_registry,
    }
    final_state = graph.invoke(initial_state)

    for internal_key in ("observer", "prompt_registry"):
        if internal_key in final_state:
            del final_state[internal_key]

    if error_message := final_state.get("error_message"):
        logger.error(
            "Writer error: request_id=%s, input_type=%s, error=%s",
            request_id,
            body.input_type,
            error_message,
        )
        status_code = (
            status.HTTP_400_BAD_REQUEST
            if final_state.get("error_kind") == "prompt_not_found"
            else status.HTTP_500_INTERNAL_SERVER_ERROR
        )
        raise HTTPException(
            status_code=status_code,
            detail=str(error_message),
        )

    if not (report_payload := final_state.get("report")):
        logger.error(
            "Missing report payload: request_id=%s, input_type=%s",
            request_id,
            body.input_type,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Missing report payload from writer node.",
        )

    report = _validate_report(report_payload)

    response = ProcessResponse(
        ok=True,
        request_id=request_id,
        input_type=body.input_type,
        prompt_version=final_state.get("prompt_version", "unknown"),
        questionnaire_prompt_version=final_state.get(
            "questionnaire_prompt_version"
        ),
        persona_skill_version=final_state.get(
            "persona_skill_version"
        ),
        model_version=final_state.get("model_version", MODEL_VERSION),
        report=report,
        warnings=final_state.get("warnings", []),
        ai_progress=tracker.get(request_id) or {},
    )
    tracker.complete(request_id)
    response.ai_progress = tracker.get(request_id) or response.ai_progress
    logger.info(
        "Process request completed: request_id=%s, prompt_version=%s",
        request_id,
        response.prompt_version,
    )
    return response


@app.get(
    "/status/{request_id}",
    response_model=ProcessStatusResponse,
    dependencies=[Depends(verify_token)],
    tags=["Processing"],
)
async def process_status(request_id: str, tracker=Depends(get_tracker)) -> ProcessStatusResponse:
    """Return LangGraph stage progress for a given request id."""
    progress = tracker.get(request_id)
    if progress is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Request progress not found",
        )
    return ProcessStatusResponse(request_id=request_id, ai_progress=progress)


@app.post("/analysis", response_model=AnalysisResponse, dependencies=[Depends(verify_token)], tags=["Analysis"])
async def analyze_conversation(body: AnalysisRequest):
    entities = extract_entities(body.messages)
    phase = body.phase or detect_phase(body.messages)
    suggestions = generate_suggestions(body.messages)
    hypotheses = generate_hypotheses(body.messages)
    alerts = detect_alerts(body.messages)
    knowledge = knowledge_lookup(body.messages)
    return AnalysisResponse(
        suggestions=suggestions,
        entities=entities,
        alerts=alerts,
        hypotheses=hypotheses,
        knowledge=knowledge,
        phase=phase,
    )


@app.post(
    "/transcriptions",
    response_model=TranscriptionResponse,
    dependencies=[Depends(verify_token)],
    tags=["Transcription"],
)
async def transcribe_audio(payload: TranscriptionRequest) -> TranscriptionResponse:
    """
    Transcribe audio via configured provider and return metadata.
    """
    try:
        return transcribe(payload)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc

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
