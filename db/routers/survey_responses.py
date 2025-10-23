"""FastAPI router for survey responses."""

from typing import List

from bson.objectid import InvalidId, ObjectId
from fastapi import APIRouter, BackgroundTasks, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import ValidationError
from pymongo.errors import PyMongoError

from config.database_config import db
from config.logging_config import logger
from models.survey_response_model import SurveyResponse
from services.email_service import send_survey_response_email

router = APIRouter()


@router.post("/survey_responses/", response_model=SurveyResponse, status_code=status.HTTP_201_CREATED)
async def create_survey_response(survey_response: SurveyResponse, background_tasks: BackgroundTasks):
    """
    Create a survey response, persist it, and trigger a background task to send a notification email.
    """
    logger.info("--- Received request to create survey response ---")
    logger.info("Survey ID: %s, Patient: %s", survey_response.survey_id, survey_response.patient.name)
    try:
        logger.info("Dumping survey response model to dict...")
        survey_response_dict = survey_response.model_dump(by_alias=True)
        if survey_response_dict.get("_id") is None:
            del survey_response_dict["_id"]
        logger.info("Survey response data prepared for insertion.")

        logger.info("Inserting survey response into database...")
        response = db.survey_responses.insert_one(survey_response_dict)

        if not response.inserted_id:
            logger.error("Failed to create survey response for survey %s - No insertion ID returned", survey_response.survey_id)
            raise HTTPException(status_code=500, detail="Survey response could not be created")

        inserted_id = str(response.inserted_id)
        logger.info("Successfully created survey response with MongoDB ID: %s", inserted_id)

        logger.info("Adding email sending task to background for response ID: %s", inserted_id)
        background_tasks.add_task(send_survey_response_email, inserted_id)

        survey_response.id = inserted_id
        logger.info("--- Returning created survey response ---")
        return survey_response

    except PyMongoError as e:
        logger.error("Database error creating survey response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="Database error occurred while creating survey response") from e
    except Exception as e:
        logger.error("Unexpected error creating survey response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e


@router.post("/survey_responses/{response_id}/send_email", status_code=status.HTTP_202_ACCEPTED)
async def resend_survey_email(response_id: str, background_tasks: BackgroundTasks):
    """
    Triggers a background task to send the survey response email for a given response ID.
    """
    logger.info("--- Received request to resend email for survey response ID: %s ---", response_id)
    
    # Optional: Check if the response_id is valid and exists before dispatching the task
    try:
        oid = ObjectId(response_id)
        if not db.survey_responses.find_one({"_id": oid}):
            logger.warning("Attempted to resend email for a non-existent survey response: %s", response_id)
            raise HTTPException(status_code=404, detail=f"Survey response with id {response_id} not found")
    except InvalidId:
        logger.warning("Invalid ObjectId format for email resending: %s", response_id)
        raise HTTPException(status_code=400, detail="Invalid response ID format")
    except PyMongoError as e:
        logger.error("Database error checking survey response existence for email resend: %s", e)
        raise HTTPException(status_code=500, detail="Database error occurred")

    background_tasks.add_task(send_survey_response_email, response_id)
    logger.info("Email resend task added to background for response ID: %s", response_id)
    
    return JSONResponse(
        content={"message": "Email sending process initiated."},
        status_code=status.HTTP_202_ACCEPTED
    )

@router.get("/survey_responses/", response_model=List[SurveyResponse])
async def get_survey_responses():
    """Return a list of all survey responses from the database."""
    logger.info("--- Received request to get all survey responses ---")
    try:
        survey_responses = []
        logger.info("Fetching survey responses from database...")
        responses_cursor = db.survey_responses.find()
        all_responses = list(responses_cursor)
        logger.info("Fetched %d survey responses from database.", len(all_responses))
        
        logger.info("Parsing fetched survey responses...")
        responses_count = 0
        for survey_response in all_responses:
            try:
                logger.debug("Parsing survey response with ID %s", survey_response.get('_id', 'unknown'))
                if '_id' in survey_response:
                    survey_response['_id'] = str(survey_response['_id'])

                survey_responses.append(SurveyResponse(**survey_response))
                responses_count += 1
            except (ValidationError, ValueError, TypeError, KeyError) as e:
                logger.warning("Failed to parse survey response with ID %s: %s", survey_response.get('_id', 'unknown'), e)
                continue

        logger.info("Successfully parsed %d survey responses.", responses_count)
        logger.info("--- Returning survey responses ---")
        return survey_responses
        
    except PyMongoError as e:
        logger.error("Database error fetching survey response: %s", e)
        raise HTTPException(status_code=500, detail="Database error occurred while fetching survey responses") from e
    except Exception as e:
        logger.error("Unexpected error fetching survey response: %s", e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e

@router.get("/survey_responses/{response_id}", response_model=SurveyResponse)
async def get_survey_response(response_id: str):
    """Return a single survey response by its ID."""
    logger.info(f"--- Received request to get survey response with id: {response_id} ---")
    try:
        logger.info(f"Converting response_id to ObjectId and fetching from database...")
        try:
            oid = ObjectId(response_id)
        except InvalidId:
            logger.warning("Invalid ObjectId format: %s", response_id)
            raise HTTPException(status_code=400, detail="Invalid response ID format")

        survey_response = db.survey_responses.find_one({"_id": oid})
        
        if survey_response:
            logger.info("Successfully found survey response: %s", response_id)
            if '_id' in survey_response:
                survey_response['_id'] = str(survey_response['_id'])
            
            logger.info(f"--- Returning survey response with id: {response_id} ---")
            return SurveyResponse(**survey_response)
        
        logger.warning("Survey response not found: %s", response_id)
        raise HTTPException(status_code=404, detail="Survey response not found")
        
    except HTTPException:
        raise
    except PyMongoError as e:
        logger.error("Database error fetching survey response %s: %s", response_id, e)
        raise HTTPException(status_code=500, detail="Database error occurred while fetching survey response") from e
    except Exception as e:
        logger.error("Unexpected error fetching survey response %s: %s", response_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e
