"""FastAPI router for patient survey responses."""

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.dependencies.response_services import (
    get_clinical_text_resolver,
    get_patient_submission_orchestrator,
    get_report_delivery_service,
)
from app.api.models.report_delivery_models import (
    SendReportEmailRequest,
    SendReportEmailResponse,
)
from app.config.logging_config import logger
from app.domain.models.survey_response_model import SurveyResponse
from app.domain.models.survey_response_with_agent import SurveyResponseWithAgent
from app.persistence.deps import get_patient_response_repo
from app.persistence.repositories.patient_response_repo import PatientResponseRepository
from app.services.clinical_text_resolver import ClinicalTextResolver
from app.services.report_command_builder import send_patient_report_email_response
from app.services.report_delivery import ReportDeliveryService
from app.services.response_submission import PatientSubmissionOrchestrator

router = APIRouter()


@router.post(
    "/patient_responses/",
    response_model=SurveyResponseWithAgent,
    status_code=status.HTTP_201_CREATED,
)
async def create_patient_response(
    survey_response: SurveyResponse,
    submission_orchestrator: PatientSubmissionOrchestrator = Depends(
        get_patient_submission_orchestrator
    ),
) -> SurveyResponseWithAgent:
    """Create a patient survey response and enrich it through the orchestrator."""
    logger.info("--- Received request to create patient response ---")
    patient_name = survey_response.patient.name if survey_response.patient else "Anonymous"
    logger.info("Survey ID: %s, Patient: %s", survey_response.survey_id, patient_name)
    try:
        return await submission_orchestrator.submit(survey_response)
    except ValueError as exc:
        logger.warning(
            "Invalid survey configuration for patient response %s: %s",
            survey_response.survey_id,
            exc,
        )
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except HTTPException:
        raise
    except Exception as exc:
        logger.error(
            "Unexpected error creating patient response for survey %s: %s",
            survey_response.survey_id,
            exc,
        )
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from exc


@router.post(
    "/patient_responses/{response_id}/send_report_email",
    response_model=SendReportEmailResponse,
    status_code=status.HTTP_200_OK,
)
async def send_report_email(
    response_id: str,
    payload: SendReportEmailRequest | None = None,
    repo: PatientResponseRepository = Depends(get_patient_response_repo),
    clinical_text_resolver: ClinicalTextResolver = Depends(get_clinical_text_resolver),
    report_delivery_service: ReportDeliveryService = Depends(get_report_delivery_service),
) -> SendReportEmailResponse:
    """Generate a report PDF and send it to the patient email."""
    logger.info("Preparing report email delivery for patient response %s", response_id)
    return await send_patient_report_email_response(
        response_id=response_id,
        response=repo.get_by_id(response_id),
        override_text=payload.report_text if payload else None,
        clinical_text_resolver=clinical_text_resolver,
        report_delivery_service=report_delivery_service,
        logger=logger,
    )
