"""Service layer for handling email-related operations."""

import json
from typing import Optional
from bson.objectid import ObjectId, InvalidId
from fastapi_mail import ConnectionConfig, FastMail, MessageSchema, MessageType
from pydantic.json import pydantic_encoder

from app.config.logging_config import logger
from app.config.settings import settings
from app.persistence.mongo.client import get_db
from app.persistence.repositories.survey_response_repo import SurveyResponseRepository
from app.persistence.repositories.patient_response_repo import PatientResponseRepository

_fast_mail: Optional[FastMail] = None

def get_mail_client() -> Optional[FastMail]:
    global _fast_mail
    if _fast_mail is not None:
        return _fast_mail

    if not settings.smtp_host or not settings.smtp_user or not settings.smtp_password:
        missing = [
            name
            for name, value in (
                ("SMTP_HOST/MAIL_SERVER", settings.smtp_host),
                ("SMTP_USER/MAIL_USERNAME", settings.smtp_user),
                ("SMTP_PASSWORD/MAIL_PASSWORD", settings.smtp_password),
            )
            if not value
        ]
        logger.warning("SMTP not configured; missing %s. Skipping email send.", ", ".join(missing))
        return None

    logger.info(
        "SMTP configured with host=%s port=%s user=%s",
        settings.smtp_host,
        settings.smtp_port,
        settings.smtp_user,
    )
    conf = ConnectionConfig(
        MAIL_USERNAME=settings.smtp_user,
        MAIL_PASSWORD=settings.smtp_password,
        MAIL_FROM=settings.smtp_user,
        MAIL_PORT=settings.smtp_port,
        MAIL_SERVER=settings.smtp_host,
        MAIL_STARTTLS=True,
        MAIL_SSL_TLS=False,
        USE_CREDENTIALS=True,
        VALIDATE_CERTS=True,
    )
    _fast_mail = FastMail(conf)
    return _fast_mail

async def send_survey_response_email(response_id: str):
    """
    Fetches a survey response by its ID and sends it via email.

    Args:
        response_id: The ID of the survey response to send.
    """
    logger.info("--- Preparing to send survey response email for ID: %s ---", response_id)
    try:
        try:
            ObjectId(response_id)
        except InvalidId:
            logger.warning("Invalid ObjectId format for email sending: %s", response_id)
            return

        logger.info("Fetching survey response from database for email...")
        repo = SurveyResponseRepository(get_db())
        survey_response_dict = next((item for item in repo.list_all() if str(item.get("_id")) == response_id), None)

        if not survey_response_dict:
            logger.error("Survey response with ID %s not found for email sending.", response_id)
            return

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

        mail_client = get_mail_client()
        if mail_client is None:
            logger.warning("Email client unavailable; skipping send for survey response %s", response_id)
            return

        logger.info("Sending email in background...")
        await mail_client.send_message(message)
        logger.info("Email for survey response %s sent successfully.", response_id)

    except Exception as e:
        logger.error("Failed to send email for survey response %s: %s", response_id, e, exc_info=True)


async def send_patient_response_email(response_id: str):
    """
    Fetches a patient survey response by its ID and sends it via email.

    Args:
        response_id: The ID of the patient survey response to send.
    """
    logger.info("--- Preparing to send patient response email for ID: %s ---", response_id)
    try:
        try:
            ObjectId(response_id)
        except InvalidId:
            logger.warning("Invalid ObjectId format for patient email sending: %s", response_id)
            return

        logger.info("Fetching patient response from database for email...")
        repo = PatientResponseRepository(get_db())
        patient_response_dict = next((item for item in repo.list_all() if str(item.get("_id")) == response_id), None)

        if not patient_response_dict:
            logger.error("Patient response with ID %s not found for email sending.", response_id)
            return

        logger.info("Preparing JSON string of patient response for email...")
        patient_response_json = json.dumps(patient_response_dict, default=pydantic_encoder, indent=2)

        logger.info("Composing patient response email message...")
        recipients = ["lapan.hugodepaula@gmail.com"]
        patient_email = patient_response_dict.get('patient', {}).get('email')
        if patient_email:
            recipients.append(patient_email)

        message = MessageSchema(
            subject=f"New Patient Survey Response ID {response_id}",
            recipients=recipients,
            body=f"""New patient survey response received:

{patient_response_json}""",
            subtype=MessageType.plain
        )

        mail_client = get_mail_client()
        if mail_client is None:
            logger.warning("Email client unavailable; skipping send for patient response %s", response_id)
            return

        logger.info("Sending patient email in background...")
        await mail_client.send_message(message)
        logger.info("Patient response email for %s sent successfully.", response_id)

    except Exception as e:
        logger.error("Failed to send email for patient response %s: %s", response_id, e, exc_info=True)
