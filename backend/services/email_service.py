"""Service layer for handling email-related operations."""

import json
from bson.objectid import ObjectId, InvalidId
from fastapi_mail import MessageSchema, MessageType
from pydantic.json import pydantic_encoder

from config.database_config import db
from config.email_config import fast_mail
from config.logging_config import logger

async def send_survey_response_email(response_id: str):
    """
    Fetches a survey response by its ID and sends it via email.

    Args:
        response_id: The ID of the survey response to send.
    """
    logger.info("--- Preparing to send survey response email for ID: %s ---", response_id)
    try:
        try:
            oid = ObjectId(response_id)
        except InvalidId:
            logger.warning("Invalid ObjectId format for email sending: %s", response_id)
            return

        logger.info("Fetching survey response from database for email...")
        survey_response_dict = db.survey_responses.find_one({"_id": oid})

        if not survey_response_dict:
            logger.error("Survey response with ID %s not found for email sending.", response_id)
            return

        survey_response_dict['_id'] = str(survey_response_dict['_id'])
        
        logger.info("Preparing JSON string of survey response for email...")
        survey_response_json = json.dumps(survey_response_dict, default=pydantic_encoder, indent=2)

        logger.info("Composing email message...")
        
        recipients = ["lapan.hugodepaula@gmail.com"]
        patient_email = survey_response_dict.get('patient', {}).get('email')
        if patient_email:
            recipients.append(patient_email)

        message = MessageSchema(
            subject=f"New Survey Response for Survey ID {response_id}",
            recipients=recipients,
            body=f"""New survey response received:

{survey_response_json}""",
            subtype=MessageType.plain
        )

        logger.info("Sending email in background...")
        await fast_mail.send_message(message)
        logger.info("Email for survey response %s sent successfully.", response_id)

    except Exception as e:
        logger.error("Failed to send email for survey response %s: %s", response_id, e)
