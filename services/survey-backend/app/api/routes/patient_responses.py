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
from app.persistence.deps import (
    get_agent_access_point_repo,
    get_patient_response_repo,
    get_persona_skill_repo,
    get_survey_repo,
)
from app.persistence.repositories.agent_access_point_repo import AgentAccessPointRepository
from app.persistence.repositories.patient_response_repo import PatientResponseRepository
from app.persistence.repositories.persona_skill_repo import PersonaSkillRepository
from app.persistence.repositories.survey_repo import SurveyRepository
from app.domain.models.agent_response_model import AgentArtifactResponse
from app.services.access_point_selection import resolve_access_point_selection
from app.services.survey_prompt_selection import (
    hydrate_survey_persona_defaults,
)

router = APIRouter()


@router.post("/patient_responses/", response_model=SurveyResponseWithAgent, status_code=status.HTTP_201_CREATED)
async def create_patient_response(
    survey_response: SurveyResponse,
    background_tasks: BackgroundTasks,
    repo: PatientResponseRepository = Depends(get_patient_response_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
    persona_repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
    access_point_repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
):
    """
    Create a patient survey response, persist it, trigger an email, and enrich with AI agent output.
    """
    logger.info("--- Received request to create patient response ---")
    patient_name = survey_response.patient.name if survey_response.patient else "Anonymous"
    logger.info("Survey ID: %s, Patient: %s", survey_response.survey_id, patient_name)
    try:
        resolved_survey = survey_repo.get_by_id(survey_response.survey_id)
        resolved_survey = hydrate_survey_persona_defaults(
            resolved_survey,
            requested_persona_skill_key=survey_response.persona_skill_key,
            requested_output_profile=survey_response.output_profile,
            get_persona_by_key=persona_repo.get_by_key,
            get_persona_by_output_profile=persona_repo.get_by_output_profile,
        )
        selection = resolve_access_point_selection(
            survey=resolved_survey,
            requested_access_point_key=survey_response.access_point_key,
            requested_prompt_key=survey_response.prompt_key,
            requested_persona_skill_key=survey_response.persona_skill_key,
            requested_output_profile=survey_response.output_profile,
            input_type="survey7",
            get_access_point_by_key=access_point_repo.get_by_key,
        )
        survey_response.access_point_key = selection.access_point_key
        survey_response.prompt_key = selection.prompt_key
        survey_response.persona_skill_key = selection.persona_skill_key
        survey_response.output_profile = selection.output_profile

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
        agent_responses: list[AgentArtifactResponse] = []

        try:
            logger.info("Sending patient response to LangGraph agent for processing...")
            runtime_points = _resolve_runtime_access_points(
                selection,
                access_point_repo=access_point_repo,
                survey_id=survey_response.survey_id,
                source_app="survey-patient",
                flow_key="thank_you.auto_analysis",
            )
            for runtime_point in runtime_points:
                agent_result = await send_to_langgraph_agent(
                    response_payload,
                    input_type="survey7",
                    prompt_key=runtime_point.prompt_key,
                    persona_skill_key=runtime_point.persona_skill_key,
                    output_profile=runtime_point.output_profile,
                    source_app="survey-patient",
                    patient_ref=survey_response.patient.email if survey_response.patient else None,
                )
                artifact = AgentArtifactResponse(
                    accessPointKey=runtime_point.access_point_key,
                    **agent_result,
                )
                agent_responses.append(artifact)
            agent_response = agent_responses[0] if agent_responses else None
            logger.info("Received agent response for patient response %s.", inserted_id)
        except ValueError as exc:
            logger.warning("Invalid prompt selection for patient response %s: %s", inserted_id, exc)
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        except ValidationError as exc:
            logger.error("Invalid data returned by agent for patient response %s: %s", inserted_id, exc)
            agent_response = AgentResponse(error_message="Invalid agent response format")
        except Exception as exc:
            logger.error("Failed to enrich patient response %s with agent output: %s", inserted_id, exc)

        logger.info("--- Returning created patient response with agent output ---")
        return SurveyResponseWithAgent(
            **response_payload,
            agent_response=agent_response,
            agent_responses=agent_responses,
        )

    except ValueError as exc:
        logger.warning(
            "Invalid survey configuration for patient response %s: %s",
            survey_response.survey_id,
            exc,
        )
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error creating patient response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e


def _resolve_runtime_access_points(
    primary_selection,
    *,
    access_point_repo: AgentAccessPointRepository,
    survey_id: str,
    source_app: str,
    flow_key: str,
):
    runtime_points = [primary_selection]
    configured = access_point_repo.list_for_runtime(
        source_app=source_app,
        flow_key=flow_key,
        survey_id=survey_id,
    )
    seen_keys = {primary_selection.access_point_key, None}
    for item in configured:
        access_point_key = item.get("accessPointKey")
        if access_point_key in seen_keys:
            continue
        seen_keys.add(access_point_key)
        runtime_points.append(
            type(primary_selection)(
                access_point_key=access_point_key,
                prompt_key=item["promptKey"],
                persona_skill_key=item.get("personaSkillKey"),
                output_profile=item.get("outputProfile"),
            )
        )
    return runtime_points
