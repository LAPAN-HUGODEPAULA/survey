"""FastAPI router for patient survey responses."""

from typing import Optional

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, status
from pydantic import ValidationError

from app.config.logging_config import logger
from app.domain.models.agent_response_model import AgentResponse
from app.domain.models.survey_response_model import SurveyResponse
from app.domain.models.survey_response_with_agent import SurveyResponseWithAgent
from app.integrations.clinical_writer.client import send_to_langgraph_agent
from app.integrations.email.service import send_patient_response_email
from app.persistence.deps import get_patient_response_repo
from app.persistence.repositories.patient_response_repo import PatientResponseRepository

router = APIRouter()


@router.post("/patient_responses/", response_model=SurveyResponseWithAgent, status_code=status.HTTP_201_CREATED)
async def create_patient_response(
    survey_response: SurveyResponse,
    background_tasks: BackgroundTasks,
    repo: PatientResponseRepository = Depends(get_patient_response_repo),
):
    """
    Create a patient survey response, persist it, trigger an email, and enrich with AI agent output.
    """
    logger.info("--- Received request to create patient response ---")
    logger.info("Survey ID: %s, Patient: %s", survey_response.survey_id, survey_response.patient.name)
    try:
        logger.info("Dumping survey response model to dict...")
        survey_response_dict = survey_response.model_dump(by_alias=True)
        if survey_response_dict.get("_id") is None:
            survey_response_dict.pop("_id", None)
        logger.info("Survey response data prepared for insertion.")

        logger.info("Inserting survey response into patient_responses collection...")
        created = repo.create(survey_response_dict)

        if not created:
            logger.error("Failed to create patient response for survey %s - No insertion ID returned", survey_response.survey_id)
            raise HTTPException(status_code=500, detail="Survey response could not be created")

        inserted_id = str(created.get("_id"))
        logger.info("Successfully created patient response with MongoDB ID: %s", inserted_id)

        background_tasks.add_task(send_patient_response_email, inserted_id)

        survey_response.id = inserted_id
        response_payload = survey_response.model_dump(by_alias=True)
        agent_response: Optional[AgentResponse] = None

        try:
            logger.info("Sending patient response to LangGraph agent for processing...")
            agent_result = await send_to_langgraph_agent(
                response_payload,
                input_type="survey7",
                source_app="survey-patient",
                patient_ref=survey_response.patient.email,
            )
            agent_response = AgentResponse(**agent_result)
            logger.info("Received agent response for patient response %s.", inserted_id)
        except ValidationError as exc:
            logger.error("Invalid data returned by agent for patient response %s: %s", inserted_id, exc)
            agent_response = AgentResponse(error_message="Invalid agent response format")
        except Exception as exc:
            logger.error("Failed to enrich patient response %s with agent output: %s", inserted_id, exc)

        logger.info("--- Returning created patient response with agent output ---")
        return SurveyResponseWithAgent(**response_payload, agent_response=agent_response)

    except Exception as e:
        logger.error("Unexpected error creating patient response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e
