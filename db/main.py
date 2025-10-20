from fastapi import FastAPI
from contextlib import asynccontextmanager

# Use absolute imports because this file is executed as a top-level module ("uvicorn main:app")
# Relative imports like ".routers" fail since there is no parent package directory.
from routers.survey import router as surveys_router
from routers.survey_responses import router as survey_results_router
from config.logging_config import logger


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Survey Application API started successfully")
    yield
    logger.info("Survey Application API shutting down")

app = FastAPI(title="Survey Application API", version="1.0.0", lifespan=lifespan)

logger.info("Starting Survey Application API")

app.include_router(surveys_router, prefix="/api/v1", tags=["surveys"])
app.include_router(survey_results_router, prefix="/api/v1", tags=["survey_results"])

logger.info("API routers registered successfully")

