"""FastAPI router for patient survey responses."""

from typing import List

from bson.objectid import InvalidId, ObjectId
from fastapi import APIRouter, HTTPException, status
from pydantic import ValidationError
from pymongo.errors import PyMongoError

from config.database_config import db
from config.logging_config import logger
from models.survey_response_model import SurveyResponse

router = APIRouter()


@router.post("/patient_responses/", response_model=SurveyResponse, status_code=status.HTTP_201_CREATED)
async def create_patient_response(survey_response: SurveyResponse):
    """
    Create a patient survey response and persist it.
    """
    logger.info("--- Received request to create patient response ---")
    logger.info("Survey ID: %s, Patient: %s", survey_response.survey_id, survey_response.patient.name)
    try:
        logger.info("Dumping survey response model to dict...")
        survey_response_dict = survey_response.model_dump(by_alias=True)
        if survey_response_dict.get("_id") is None:
            del survey_response_dict["_id"]
        logger.info("Survey response data prepared for insertion.")

        logger.info("Inserting survey response into patient_responses collection...")
        response = db.patient_responses.insert_one(survey_response_dict)

        if not response.inserted_id:
            logger.error("Failed to create patient response for survey %s - No insertion ID returned", survey_response.survey_id)
            raise HTTPException(status_code=500, detail="Survey response could not be created")

        inserted_id = str(response.inserted_id)
        logger.info("Successfully created patient response with MongoDB ID: %s", inserted_id)

        survey_response.id = inserted_id
        logger.info("--- Returning created patient response ---")
        return survey_response

    except PyMongoError as e:
        logger.error("Database error creating patient response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="Database error occurred while creating survey response") from e
    except Exception as e:
        logger.error("Unexpected error creating patient response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e
