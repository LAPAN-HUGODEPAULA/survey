from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import bcrypt
import secrets
import string
from contextlib import asynccontextmanager

from app.config.logging_config import logger
from app.config.settings import settings
from app.api.routes.survey import router as surveys_router
from app.api.routes.survey_responses import router as survey_results_router
from app.api.routes.patient_responses import router as patient_results_router
from app.api.routes.clinical_writer import router as clinical_writer_router
from app.api.routes.screener_routes import router as screeners_router
from app.api.routes.chat_sessions import router as chat_sessions_router
from app.api.routes.chat_messages import router as chat_messages_router
from app.api.routes.documents import router as documents_router
from app.api.routes.templates import router as templates_router
from app.api.routes.voice_transcriptions import router as voice_transcriptions_router
from app.api.routes.privacy import router as privacy_router

from app.persistence.mongo.client import get_db
from app.persistence.repositories.screener_repo import (
    SYSTEM_SCREENER_EMAIL,
    SYSTEM_SCREENER_ID,
    ScreenerRepository,
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Survey Application API started successfully")

    # Initialize System Screener
    db = get_db()
    screener_repo = ScreenerRepository(db)

    system_screener = screener_repo.find_by_id(SYSTEM_SCREENER_ID) or screener_repo.find_by_email(
        SYSTEM_SCREENER_EMAIL
    )
    if system_screener:
        logger.info("System Screener already exists with id=%s", SYSTEM_SCREENER_ID)
    else:
        logger.info("System Screener not found. Creating a new one with id=%s.", SYSTEM_SCREENER_ID)
        system_screener_password = "".join(
            secrets.choice(string.ascii_letters + string.digits) for _ in range(16)
        )
        hashed_password = bcrypt.hashpw(system_screener_password.encode("utf-8"), bcrypt.gensalt())
        try:
            screener_repo.ensure_system_screener(hashed_password.decode("utf-8"))
            if settings.is_production:
                logger.info("System Screener created.")
            else:
                logger.warning(
                    "System Screener temporary password: %s",
                    system_screener_password,
                )
        except Exception as e:
            logger.error("Failed to create System Screener: %s", e)

    yield
    logger.info("Survey Application API stopped")

app = FastAPI(
    title="Survey Application API",
    description="API for managing surveys and processing survey/patient results",
    version="1.0.0",
    lifespan=lifespan,
)

@app.middleware("http")
async def enforce_https_in_production(request: Request, call_next):
    if settings.is_production:
        forwarded = request.headers.get("forwarded", "")
        forwarded_proto = None
        if "proto=" in forwarded:
            forwarded_proto = forwarded.split("proto=", 1)[1].split(";", 1)[0].strip()
        proto = (
            forwarded_proto
            or request.headers.get("x-forwarded-proto")
            or request.url.scheme
        )
        if proto != "https":
            return JSONResponse(
                status_code=403,
                content={"detail": "HTTPS required."},
            )
    return await call_next(request)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(surveys_router, prefix="/api/v1", tags=["surveys"])
app.include_router(survey_results_router, prefix="/api/v1", tags=["survey_results"])
app.include_router(patient_results_router, prefix="/api/v1", tags=["patient_results"])
app.include_router(clinical_writer_router, prefix="/api/v1", tags=["clinical_writer"])
app.include_router(screeners_router, prefix="/api/v1", tags=["screeners"])
app.include_router(chat_sessions_router, prefix="/api/v1", tags=["chat_sessions"])
app.include_router(chat_messages_router, prefix="/api/v1", tags=["chat_messages"])
app.include_router(documents_router, prefix="/api/v1", tags=["documents"])
app.include_router(templates_router, prefix="/api/v1", tags=["templates"])
app.include_router(voice_transcriptions_router, prefix="/api/v1", tags=["voice_transcriptions"])
app.include_router(privacy_router, prefix="/api/v1", tags=["privacy"])
