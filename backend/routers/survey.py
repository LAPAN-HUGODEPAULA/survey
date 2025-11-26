"""FastAPI router for managing surveys (create, list, retrieve)."""

from typing import List

from fastapi import APIRouter, HTTPException
from pydantic import ValidationError
from pymongo.errors import PyMongoError

from config.database_config import db
from config.logging_config import logger
from models.survey_model import Survey

router = APIRouter()

@router.post("/surveys/", response_model=Survey)
async def create_survey(survey: Survey):
    """Create a new survey and store it in the database."""
    logger.info("Creating new survey: %s (ID: %s)", survey.survey_displayname, survey.id)
    try:
        survey_dict = survey.model_dump(by_alias=True)
        logger.info("Survey data prepared for insertion: %s", survey_dict.get('surveyId'))
        
        result = db.surveys.insert_one(survey_dict)
        
        if not result.inserted_id:
            logger.error("Failed to create survey: %s - No insertion ID returned", survey.id)
            raise HTTPException(status_code=500, detail="Survey could not be created")

        logger.info("Successfully created survey: %s with MongoDB ID: %s", survey.id, result.inserted_id)
        return survey
        
    except PyMongoError as e:
        logger.error("Database error creating survey %s: %s", survey.id, e)
        raise HTTPException(status_code=500, detail="Database error occurred while creating survey") from e
    except Exception as e:
        logger.error("Unexpected error creating survey %s: %s", survey.id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e

@router.get("/surveys/", response_model=List[Survey])
async def get_surveys():
    """Return a list of all surveys from the database."""
    logger.info("Fetching all surveys")
    try:
        surveys = []
        survey_cursor = db.surveys.find()
        all_results = list(survey_cursor)
        logger.info("Fetched surveys: %d", len(all_results))
        survey_count = 0
        
        for survey in all_results:
            try:
                logger.info("Parsing survey with ID %s", survey.get('_id', 'unknown'))
                logger.info(survey)
                surveys.append(Survey(**survey))
                survey_count += 1
            except (ValidationError, ValueError, TypeError, KeyError) as e:
                logger.warning("Failed to parse survey with ID %s: %s", survey.get('_id', 'unknown'), e)
                continue
        
        logger.info("Successfully fetched %d surveys", survey_count)
        return surveys
        
    except PyMongoError as e:
        logger.error("Database error fetching surveys: %s", e)
        raise HTTPException(status_code=500, detail="Database error occurred while fetching surveys") from e
    except Exception as e:
        logger.error("Unexpected error fetching surveys: %s", e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e

@router.get("/surveys/{survey_id}", response_model=Survey)
async def get_survey(survey_id: str):
    """Return a single survey by its ID."""
    logger.info("Fetching survey with ID: %s", survey_id)
    try:
        survey = db.surveys.find_one({"_id": survey_id})
        
        if survey:
            logger.info("Successfully found survey: %s", survey_id)
            return Survey(**survey)
        
        logger.warning("Survey not found: %s", survey_id)
        raise HTTPException(status_code=404, detail="Survey not found")
        
    except HTTPException:
        raise
    except PyMongoError as e:
        logger.error("Database error fetching survey %s: %s", survey_id, e)
        raise HTTPException(status_code=500, detail="Database error occurred while fetching survey") from e
    except Exception as e:
        logger.error("Unexpected error fetching survey %s: %s", survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e
