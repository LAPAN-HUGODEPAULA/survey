"""FastAPI application entrypoint for the survey backend."""

from contextlib import asynccontextmanager
import secrets
import string

import bcrypt
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.errors import global_http_exception_handler
from app.api.middleware.correlation import CorrelationMiddleware
from app.api.routes.builder_auth import router as builder_auth_router
from app.api.routes.agent_access_points import router as agent_access_points_router
from app.api.routes.chat_messages import router as chat_messages_router
from app.api.routes.chat_sessions import router as chat_sessions_router
from app.api.routes.clinical_writer import router as clinical_writer_router
from app.api.routes.documents import router as documents_router
from app.api.routes.persona_skills import router as persona_skills_router
from app.api.routes.patient_responses import router as patient_responses_router
from app.api.routes.medications import router as medications_router
from app.api.routes.privacy import router as privacy_router
from app.api.routes.screener_access_links import router as screener_access_links_router
from app.api.routes.screener_settings import router as screener_settings_router
from app.api.routes.screener_routes import router as screeners_router
from app.api.routes.survey import router as surveys_router
from app.api.routes.survey_prompts import router as survey_prompts_router
from app.api.routes.survey_responses import router as survey_responses_router
from app.api.routes.templates import router as templates_router
from app.api.routes.voice_transcriptions import router as voice_transcriptions_router
from app.config.logging_config import logger
from app.config.settings import settings
from app.persistence.mongo.client import get_db
from app.persistence.repositories.screener_repo import (
    SYSTEM_SCREENER_EMAIL,
    SYSTEM_SCREENER_ID,
    ScreenerRepository,
)


def _build_security_headers() -> dict[str, str]:
    """Return baseline response headers that reduce common browser attack surface."""
    headers = {
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "X-Content-Type-Options": "nosniff",
        "X-Frame-Options": "DENY",
    }
    if settings.is_production:
        headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    return headers


def _ensure_reserved_system_screener(screener_repo: ScreenerRepository) -> None:
    """Ensure the reserved builder account exists and keeps admin access."""
    system_screener = screener_repo.find_by_id(SYSTEM_SCREENER_ID) or screener_repo.find_by_email(
        SYSTEM_SCREENER_EMAIL
    )
    if system_screener and system_screener.isBuilderAdmin:
        logger.info("System Screener already exists with id=%s", SYSTEM_SCREENER_ID)
        return

    if system_screener:
        logger.info(
            "System Screener exists without builder admin access. Promoting email=%s.",
            SYSTEM_SCREENER_EMAIL,
        )
        screener_repo.ensure_system_screener(system_screener.password)
        return

    logger.info("System Screener not found. Creating a new one with id=%s.", SYSTEM_SCREENER_ID)
    system_screener_password = "".join(
        secrets.choice(string.ascii_letters + string.digits) for _ in range(16)
    )
    hashed_password = bcrypt.hashpw(system_screener_password.encode("utf-8"), bcrypt.gensalt())
    screener_repo.ensure_system_screener(hashed_password.decode("utf-8"))
    logger.info("System Screener created.")
    if not settings.is_production:
        logger.warning(
            "System Screener created with a generated development credential. "
            "Reset it through the database before sharing the environment."
        )


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize service-level dependencies when the API starts."""
    settings.validate_runtime_security()
    logger.info("Survey Application API started successfully")

    # Ensure the reserved system screener exists before handling requests.
    db = get_db()
    screener_repo = ScreenerRepository(db)

    try:
        _ensure_reserved_system_screener(screener_repo)
    except Exception as e:
        logger.error("Failed to create System Screener: %s", e)

    yield
    logger.info("Survey Application API stopped")


app = FastAPI(
    title="Survey Application API",
    description="API for managing surveys and processing survey/patient results",
    version="0.2.0",
    lifespan=lifespan,
)

app.add_exception_handler(HTTPException, global_http_exception_handler)


@app.middleware("http")
async def enforce_https_in_production(request: Request, call_next):
    """Reject non-HTTPS requests when the app runs behind a production proxy."""
    if settings.is_production:
        forwarded = request.headers.get("forwarded", "")
        forwarded_proto = None
        if "proto=" in forwarded:
            forwarded_proto = forwarded.split("proto=", 1)[1].split(";", 1)[0].strip()
        proto = forwarded_proto or request.headers.get("x-forwarded-proto") or request.url.scheme
        if proto != "https":
            return JSONResponse(
                status_code=403,
                content={"detail": "HTTPS required."},
            )
    response = await call_next(request)
    for header_name, header_value in _build_security_headers().items():
        response.headers.setdefault(header_name, header_value)
    return response


app.add_middleware(CorrelationMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=[
        "Authorization",
        "Content-Type",
        settings.builder_csrf_header_name,
        "X-Privacy-Admin-Token",
        "X-Request-ID",
    ],
)

app.include_router(surveys_router, prefix="/api/v1", tags=["surveys"])
app.include_router(survey_prompts_router, prefix="/api/v1", tags=["survey_prompts"])
app.include_router(persona_skills_router, prefix="/api/v1", tags=["persona_skills"])
app.include_router(agent_access_points_router, prefix="/api/v1", tags=["agent_access_points"])
app.include_router(survey_responses_router, prefix="/api/v1", tags=["survey_responses"])
app.include_router(patient_responses_router, prefix="/api/v1", tags=["patient_responses"])
app.include_router(medications_router, prefix="/api/v1", tags=["medications"])
app.include_router(clinical_writer_router, prefix="/api/v1", tags=["clinical_writer"])
app.include_router(screeners_router, prefix="/api/v1", tags=["screeners"])
app.include_router(builder_auth_router, prefix="/api/v1", tags=["builder_auth"])
app.include_router(screener_access_links_router, prefix="/api/v1", tags=["screener_access_links"])
app.include_router(screener_settings_router, prefix="/api/v1", tags=["screener_settings"])
app.include_router(chat_sessions_router, prefix="/api/v1", tags=["chat_sessions"])
app.include_router(chat_messages_router, prefix="/api/v1", tags=["chat_messages"])
app.include_router(documents_router, prefix="/api/v1", tags=["documents"])
app.include_router(templates_router, prefix="/api/v1", tags=["templates"])
app.include_router(voice_transcriptions_router, prefix="/api/v1", tags=["voice_transcriptions"])
app.include_router(privacy_router, prefix="/api/v1", tags=["privacy"])
