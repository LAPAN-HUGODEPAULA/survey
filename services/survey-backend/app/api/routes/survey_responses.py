"""FastAPI router for survey responses."""

from typing import List

from bson.objectid import InvalidId, ObjectId
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import ValidationError

from app.api.dependencies.response_services import (
    get_clinical_text_resolver,
    get_report_delivery_service,
    get_survey_submission_orchestrator,
)
from app.api.dependencies.screener_auth import require_screener
from app.api.models.report_delivery_models import (
    SendReportEmailRequest,
    SendReportEmailResponse,
)
from app.config.logging_config import logger
from app.domain.models.screener_model import ScreenerModel
from app.domain.models.survey_response_model import SurveyResponse
from app.domain.models.survey_response_with_agent import SurveyResponseWithAgent
from app.integrations.email.service import send_survey_response_email
from app.persistence.deps import (
    get_survey_response_repo,
)
from app.persistence.repositories.survey_response_repo import SurveyResponseRepository
from app.services.clinical_text_resolver import ClinicalTextResolver
from app.services.report_command_builder import send_survey_report_email_response
from app.services.report_delivery import ReportDeliveryService
from app.services.response_submission import SurveySubmissionOrchestrator

router = APIRouter()
UNEXPECTED_ERROR_DETAIL = "An unexpected error occurred"


@router.post(
    "/survey_responses/",
    response_model=SurveyResponseWithAgent,
    status_code=status.HTTP_201_CREATED,
)
async def create_survey_response(
    survey_response: SurveyResponse,
    submission_orchestrator: SurveySubmissionOrchestrator = Depends(
        get_survey_submission_orchestrator
    ),
) -> SurveyResponseWithAgent:
    """
    Create a survey response, persist it, trigger an email, and enrich with AI agent output.
    """
    logger.info("--- Received request to create survey response ---")
    patient_name = survey_response.patient.name if survey_response.patient else "Anonymous"
    logger.info("Survey ID: %s, Patient: %s", survey_response.survey_id, patient_name)
    try:
        return await submission_orchestrator.submit(survey_response)
    except ValueError as exc:
        logger.warning(
            "Invalid survey configuration for survey %s: %s",
            survey_response.survey_id,
            exc,
        )
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error creating survey response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail=UNEXPECTED_ERROR_DETAIL) from e


@router.post(
    "/survey_responses/{response_id}/send_report_email",
    response_model=SendReportEmailResponse,
    status_code=status.HTTP_200_OK,
)
async def send_report_email(
    response_id: str,
    payload: SendReportEmailRequest | None = None,
    repo: SurveyResponseRepository = Depends(get_survey_response_repo),
    clinical_text_resolver: ClinicalTextResolver = Depends(get_clinical_text_resolver),
    report_delivery_service: ReportDeliveryService = Depends(get_report_delivery_service),
) -> SendReportEmailResponse:
    """Generate a report PDF and send it to the patient email."""
    return await send_survey_report_email_response(
        response_id=response_id,
        response=repo.get_raw_by_id(response_id),
        override_text=payload.report_text if payload else None,
        clinical_text_resolver=clinical_text_resolver,
        report_delivery_service=report_delivery_service,
        logger=logger,
    )


@router.post(
    "/survey_responses/{response_id}/send_email",
    status_code=status.HTTP_202_ACCEPTED,
)
async def resend_survey_email(
    response_id: str,
    background_tasks: BackgroundTasks,
    repo: SurveyResponseRepository = Depends(get_survey_response_repo),
) -> JSONResponse:
    """
    Triggers a background task to send the survey response email for a given response ID.
    """
    logger.info("--- Received request to resend email for survey response ID: %s ---", response_id)

    # Optional: Check if the response_id is valid and exists before dispatching the task
    try:
        ObjectId(response_id)
        existing = next((item for item in repo.list_all() if str(item.get("_id")) == response_id), None)
        if not existing:
            logger.warning("Attempted to resend email for a non-existent survey response: %s", response_id)
            raise HTTPException(status_code=404, detail=f"Survey response with id {response_id} not found")
    except InvalidId:
        logger.warning("Invalid ObjectId format for email resending: %s", response_id)
        raise HTTPException(status_code=400, detail="Invalid response ID format")

    background_tasks.add_task(send_survey_response_email, response_id)
    logger.info("Email resend task added to background for response ID: %s", response_id)

    return JSONResponse(
        content={"message": "Email sending process initiated."},
        status_code=status.HTTP_202_ACCEPTED
    )

@router.get("/survey_responses/", response_model=List[SurveyResponse])
async def get_survey_responses(
    screener: ScreenerModel = Depends(require_screener),
    repo: SurveyResponseRepository = Depends(get_survey_response_repo),
) -> list[SurveyResponse]:
    """Return a list of all survey responses from the database."""
    logger.info("--- Received request to get all survey responses ---")
    try:
        all_responses = repo.list_all()
    except Exception as exc:
        logger.error("Unexpected error fetching survey response: %s", exc)
        raise HTTPException(status_code=500, detail=UNEXPECTED_ERROR_DETAIL) from exc

    survey_responses = _parse_survey_responses(all_responses)
    logger.info("Successfully parsed %d survey responses.", len(survey_responses))
    logger.info("--- Returning survey responses ---")
    return survey_responses

@router.get("/survey_responses/{response_id}", response_model=SurveyResponse)
async def get_survey_response(
    response_id: str,
    screener: ScreenerModel = Depends(require_screener),
    repo: SurveyResponseRepository = Depends(get_survey_response_repo),
) -> SurveyResponse:
    """Return a single survey response by its ID."""
    logger.info(f"--- Received request to get survey response with id: {response_id} ---")
    logger.info("Validating response_id format and fetching from database...")
    try:
        ObjectId(response_id)
    except InvalidId:
        logger.warning("Invalid ObjectId format: %s", response_id)
        raise HTTPException(status_code=400, detail="Invalid response ID format")

    try:
        survey_response = next(
            (item for item in repo.list_all() if str(item.get("_id")) == response_id),
            None,
        )
    except Exception as exc:
        logger.error("Unexpected error fetching survey response %s: %s", response_id, exc)
        raise HTTPException(status_code=500, detail=UNEXPECTED_ERROR_DETAIL) from exc

    if survey_response:
        logger.info("Successfully found survey response: %s", response_id)
        logger.info(f"--- Returning survey response with id: {response_id} ---")
        return SurveyResponse(**survey_response)

    logger.warning("Survey response not found: %s", response_id)
    raise HTTPException(status_code=404, detail="Survey response not found")


def _parse_survey_responses(all_responses: list[dict]) -> list[SurveyResponse]:
    survey_responses: list[SurveyResponse] = []
    for survey_response in all_responses:
        try:
            logger.debug(
                "Parsing survey response with ID %s",
                survey_response.get("_id", "unknown"),
            )
            survey_responses.append(SurveyResponse(**survey_response))
        except (ValidationError, ValueError, TypeError, KeyError) as exc:
            logger.warning(
                "Failed to parse survey response with ID %s: %s",
                survey_response.get("_id", "unknown"),
                exc,
            )
    return survey_responses
