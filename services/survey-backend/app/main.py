from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.config.logging_config import logger
from app.api.routes.survey import router as surveys_router
from app.api.routes.survey_responses import router as survey_results_router
from app.api.routes.patient_responses import router as patient_results_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Survey Application API started successfully")
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
