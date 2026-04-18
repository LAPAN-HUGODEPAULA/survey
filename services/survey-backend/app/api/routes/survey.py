"""FastAPI router for managing surveys (create, list, retrieve, update, delete)."""

from datetime import datetime
from typing import List

from bson.objectid import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from pydantic import ValidationError

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.config.logging_config import logger
from app.domain.models.survey_model import Survey
from app.domain.models.survey_prompt_model import SurveyPromptReference
from app.persistence.deps import (
    get_persona_skill_repo,
    get_survey_prompt_repo,
    get_survey_repo,
)
from app.persistence.repositories.persona_skill_repo import PersonaSkillRepository
from app.persistence.repositories.survey_prompt_repo import SurveyPromptRepository
from app.persistence.repositories.survey_repo import SurveyRepository

router = APIRouter(dependencies=[Depends(require_builder_admin)])


def _resolve_prompt_reference(
    survey: Survey,
    prompt_repo: SurveyPromptRepository,
) -> SurveyPromptReference | None:
    """Validate a prompt reference against the prompt catalog."""
    if survey.prompt is None:
        return None

    prompt = prompt_repo.get_by_key(survey.prompt.prompt_key)
    if not prompt:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Unknown promptKey: {survey.prompt.prompt_key}",
        )

    return SurveyPromptReference(
        promptKey=prompt["promptKey"],
        name=prompt["name"],
    )


def _resolve_persona_defaults(
    survey: Survey,
    persona_repo: PersonaSkillRepository,
) -> tuple[str | None, str | None]:
    """Validate and canonicalize survey-level persona defaults."""
    if survey.persona_skill_key is None and survey.output_profile is None:
        return None, None

    if survey.persona_skill_key is not None:
        persona = persona_repo.get_by_key(survey.persona_skill_key)
        if not persona:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
                detail=f"Unknown personaSkillKey: {survey.persona_skill_key}",
            )
        persona_output_profile = persona["outputProfile"]
        if (
            survey.output_profile is not None
            and survey.output_profile != persona_output_profile
        ):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
                detail=(
                    "outputProfile does not match personaSkillKey: "
                    f"{survey.persona_skill_key}"
                ),
            )
        return survey.persona_skill_key, persona_output_profile

    persona = persona_repo.get_by_output_profile(survey.output_profile)
    if not persona:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Unknown outputProfile: {survey.output_profile}",
        )
    return persona["personaSkillKey"], persona["outputProfile"]


@router.post(
    "/surveys/",
    response_model=Survey,
    status_code=201,
    dependencies=[Depends(require_builder_csrf)],
)
async def create_survey(
    survey: Survey,
    repo: SurveyRepository = Depends(get_survey_repo),
    prompt_repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
    persona_repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
):
    """Create a new survey and store it in the database."""
    logger.info("Creating new survey: %s (ID: %s)", survey.survey_displayname, survey.id)
    try:
        survey.prompt = _resolve_prompt_reference(survey, prompt_repo)
        survey.persona_skill_key, survey.output_profile = _resolve_persona_defaults(
            survey,
            persona_repo,
        )
        survey_dict = survey.model_dump(by_alias=True)
        new_id = survey.id or str(ObjectId())
        survey_dict["_id"] = new_id
        survey_dict = {k: v for k, v in survey_dict.items() if v is not None}
        logger.info("Survey data prepared for insertion: %s", survey_dict.get("surveyId"))

        created = repo.create(survey_dict)

        if not created:
            logger.error("Failed to create survey: %s - No insertion returned", survey.id)
            raise HTTPException(status_code=500, detail="Survey could not be created")

        logger.info("Successfully created survey: %s with MongoDB ID: %s", survey.id, created.get("_id"))
        return Survey(**created)

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error creating survey %s: %s", survey.id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e


@router.get("/surveys/", response_model=List[Survey])
async def get_surveys(repo: SurveyRepository = Depends(get_survey_repo)):
    """Return a list of all surveys from the database."""
    logger.info("Fetching all surveys")
    try:
        surveys = []
        all_results = repo.list_all()
        logger.info("Fetched surveys: %d", len(all_results))
        survey_count = 0

        for survey in all_results:
            try:
                logger.info("Parsing survey with ID %s", survey.get("_id", "unknown"))
                surveys.append(Survey(**survey))
                survey_count += 1
            except (ValidationError, ValueError, TypeError, KeyError) as e:
                logger.warning("Failed to parse survey with ID %s: %s", survey.get("_id", "unknown"), e)
                continue

        logger.info("Successfully fetched %d surveys", survey_count)
        return surveys

    except Exception as e:
        logger.error("Unexpected error fetching surveys: %s", e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e


@router.get("/surveys/export")
async def export_surveys(repo: SurveyRepository = Depends(get_survey_repo)):
    """Export all surveys as a JSON file."""
    logger.info("Exporting all surveys")
    try:
        surveys = repo.list_all()
        timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        headers = {
            "Content-Disposition": f'attachment; filename="surveys_export_{timestamp}.json"'
        }
        return JSONResponse(content=jsonable_encoder(surveys), headers=headers)
    except Exception as e:
        logger.error("Unexpected error exporting surveys: %s", e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e


@router.get("/surveys/{survey_id}", response_model=Survey)
async def get_survey(survey_id: str, repo: SurveyRepository = Depends(get_survey_repo)):
    """Return a single survey by its ID."""
    logger.info("Fetching survey with ID: %s", survey_id)
    try:
        survey = repo.get_by_id(survey_id)

        if survey:
            logger.info("Successfully found survey: %s", survey_id)
            return Survey(**survey)

        logger.warning("Survey not found: %s", survey_id)
        raise HTTPException(status_code=404, detail="Survey not found")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error fetching survey %s: %s", survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e


@router.put(
    "/surveys/{survey_id}",
    response_model=Survey,
    dependencies=[Depends(require_builder_csrf)],
)
async def update_survey(
    survey_id: str,
    survey: Survey,
    repo: SurveyRepository = Depends(get_survey_repo),
    prompt_repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
    persona_repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
):
    """Update an existing survey."""
    logger.info("Updating survey with ID: %s", survey_id)
    try:
        survey.prompt = _resolve_prompt_reference(survey, prompt_repo)
        survey.persona_skill_key, survey.output_profile = _resolve_persona_defaults(
            survey,
            persona_repo,
        )
        updated_survey = repo.update(survey_id, survey.model_dump(by_alias=True))

        if updated_survey:
            logger.info("Successfully updated survey: %s", survey_id)
            return Survey(**updated_survey)

        logger.warning("Survey not found for update: %s", survey_id)
        raise HTTPException(status_code=404, detail="Survey not found")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error updating survey %s: %s", survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e


@router.delete(
    "/surveys/{survey_id}",
    status_code=204,
    dependencies=[Depends(require_builder_csrf)],
)
async def delete_survey(survey_id: str, repo: SurveyRepository = Depends(get_survey_repo)):
    """Delete a survey by its ID."""
    logger.info("Deleting survey with ID: %s", survey_id)
    try:
        if not repo.get_by_id(survey_id):
            logger.warning("Survey not found for deletion: %s", survey_id)
            raise HTTPException(status_code=404, detail="Survey not found")

        repo.delete(survey_id)
        logger.info("Successfully deleted survey: %s", survey_id)
        return

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error deleting survey %s: %s", survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e
