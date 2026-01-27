from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import bcrypt

from app.config.logging_config import logger
from app.api.routes.survey import router as surveys_router
from app.api.routes.survey_responses import router as survey_results_router
from app.api.routes.patient_responses import router as patient_results_router
from app.api.routes.clinical_writer import router as clinical_writer_router
from app.api.routes.screener_routes import router as screeners_router

from app.persistence.mongo.client import get_db
from app.persistence.repositories.screener_repo import ScreenerRepository
from app.domain.models.screener_model import ScreenerModel, Address, ProfessionalCouncil

SYSTEM_SCREENER_EMAIL = "lapan.hugodepaula@gmail.com"

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Survey Application API started successfully")

    # Initialize System Screener
    db = get_db()
    screener_repo = ScreenerRepository(db)

    system_screener = screener_repo.find_by_email(SYSTEM_SCREENER_EMAIL)
    if not system_screener:
        logger.info("System Screener not found. Creating a new one.")
        # Generate a random password for the system screener
        import secrets
        import string
        system_screener_password = ''.join(secrets.choice(string.ascii_letters + string.digits) for i in range(16))
        hashed_password = bcrypt.hashpw(system_screener_password.encode('utf-8'), bcrypt.gensalt())

        system_screener_data = ScreenerModel(
            cpf="00000000000",
            firstName="LAPAN",
            surname="System Screener",
            email=SYSTEM_SCREENER_EMAIL,
            password=hashed_password.decode('utf-8'),
            phone="31984831284",
            address=Address(
                postalCode="34000000",
                street="Rua da Paisagem",
                number="220",
                complement="",
                neighborhood="Vale do Sereno",
                city="Nova Lima",
                state="MG",
            ),
            professionalCouncil=ProfessionalCouncil(
                type="none",
                registrationNumber="",
            ),
            jobTitle="",
            degree="",
            darvCourseYear=None,
        )
        try:
            screener_repo.create(system_screener_data)
            logger.info("System Screener created successfully.")
            logger.warning(f"System Screener temporary password: {system_screener_password}")
        except Exception as e:
            logger.error("Failed to create System Screener: %s", e)
    else:
        logger.info("System Screener already exists.")

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
app.include_router(screeners_router, prefix="/api/v1", tags=["screeners"]) # Added router
