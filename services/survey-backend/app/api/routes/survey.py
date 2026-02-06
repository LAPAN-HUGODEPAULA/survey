"""FastAPI router for managing surveys (create, list, retrieve, update, delete)."""

from typing import List
from bson.objectid import ObjectId

from fastapi import APIRouter, HTTPException, Depends
from pydantic import ValidationError

from app.config.logging_config import logger
from app.domain.models.survey_model import Survey
from app.persistence.deps import get_survey_repo
from app.persistence.repositories.survey_repo import SurveyRepository

router = APIRouter()

@router.post("/surveys/", response_model=Survey)
async def create_survey(survey: Survey, repo: SurveyRepository = Depends(get_survey_repo)):
    """Create a new survey and store it in the database."""
    logger.info("Creating new survey: %s (ID: %s)", survey.survey_displayname, survey.id)
    try:
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

@router.put("/surveys/{survey_id}", response_model=Survey)
async def update_survey(
    survey_id: str, survey: Survey, repo: SurveyRepository = Depends(get_survey_repo)
):
    """Update an existing survey."""
    logger.info("Updating survey with ID: %s", survey_id)
    try:
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

@router.delete("/surveys/{survey_id}", status_code=204)
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
