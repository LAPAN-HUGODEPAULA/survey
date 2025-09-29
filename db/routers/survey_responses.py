"""FastAPI router for survey responses."""

import json
from typing import List

from fastapi import APIRouter, BackgroundTasks, HTTPException
from fastapi_mail import MessageSchema, MessageType
from pydantic import ValidationError
from pydantic.json import pydantic_encoder
from pymongo.errors import PyMongoError

from config.database_config import db
from config.email_config import fast_mail
from config.logging_config import logger
from models.survey_response_model import SurveyResponse

router = APIRouter()

@router.post("/survey_responses/", response_model=SurveyResponse)
async def create_survey_response(survey_response: SurveyResponse, background_tasks: BackgroundTasks):
    """Create a survey response, persist it, and send notification email."""
    logger.info("Creating new survey response for survey: %s, patient: %s", survey_response.survey_id, survey_response.patient.name)
    try:
        survey_response_dict = survey_response.model_dump(by_alias=True)
        logger.info("Survey response data prepared for insertion: survey_id=%s", survey_response.id)
        
        response = db.survey_responses.insert_one(survey_response_dict)
        
        if not response.inserted_id:
            logger.error("Failed to create survey response for survey %s - No insertion ID returned", survey_response.id)
            raise HTTPException(status_code=500, detail="Survey response could not be created")

        logger.info("Successfully created survey response with MongoDB ID: %s", response.inserted_id)

        # Prepare JSON string of survey response for email
        survey_response_json = json.dumps(survey_response_dict, default=pydantic_encoder, indent=2)

        # Compose email message
        message = MessageSchema(
            subject=f"New Survey Response for Survey ID {response.inserted_id}",
            recipients=["lapan.hugodepaula@gmail.com", survey_response_dict.get('patient', {}).get('email')], 
            body=f"New survey response received:\n\n{survey_response_json}",
            subtype= MessageType.plain
        )

        # Add send_email task to background
        background_tasks.add_task(fast_mail.send_message, message)


        return survey_response
        
    except PyMongoError as e:
        logger.error("Database error creating survey response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="Database error occurred while creating survey response") from e
    except Exception as e:
        logger.error("Unexpected error creating survey response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e

@router.get("/survey_responses/", response_model=List[SurveyResponse])
async def get_survey_responses():
    """Return a list of all survey responses from the database."""
    logger.info("Fetching all survey responses")
    try:
        survey_responses = []
        responses_cursor = db.survey_responses.find()
        all_responses = list(responses_cursor)
        logger.info("Fetched survey responses: %d", len(all_responses))
        responses_count = 0

        for survey_response in all_responses:
            try:
                logger.info("Parsing survey response with ID %s", survey_response.get('_id', 'unknown'))
                logger.info(survey_response)
                if '_id' in survey_response:
                    survey_response['_id'] = str(survey_response['_id'])

                survey_responses.append(SurveyResponse(**survey_response))
                responses_count += 1
            except (ValidationError, ValueError, TypeError, KeyError) as e:
                logger.warning("Failed to parse survey response with ID %s: %s", survey_response.get('_id', 'unknown'), e)
                continue

        logger.info("Successfully fetched %d survey responses", responses_count)
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
    logger.info("Fetching survey response with ID: %s", response_id)
    try:
        survey_response = db.survey_responses.find_one({"_id": response_id})
        
        if survey_response:
            logger.info("Successfully found survey response: %s", response_id)
            if '_id' in survey_response:
                survey_response['_id'] = str(survey_response['_id'])
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
