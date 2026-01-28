from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import bcrypt
import secrets
import string
from contextlib import asynccontextmanager

from app.config.logging_config import logger
from app.api.routes.survey import router as surveys_router
from app.api.routes.survey_responses import router as survey_results_router
from app.api.routes.patient_responses import router as patient_results_router
from app.api.routes.clinical_writer import router as clinical_writer_router
from app.api.routes.screener_routes import router as screeners_router

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
            logger.warning("System Screener temporary password: %s", system_screener_password)
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
