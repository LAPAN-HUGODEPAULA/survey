"""Service layer for handling email-related operations."""

from __future__ import annotations

import json
from typing import Any, Optional, Protocol

from bson.objectid import InvalidId, ObjectId
from pydantic.json import pydantic_encoder

from app.config.logging_config import logger
from app.config.settings import settings
from app.persistence.mongo.client import get_db
from app.persistence.repositories.patient_response_repo import PatientResponseRepository
from app.persistence.repositories.survey_response_repo import SurveyResponseRepository

_fast_mail: Optional[Any] = None
_message_schema_type: Any = None
_message_type_enum: Any = None


class _ResponseRepo(Protocol):
    def get_by_id(self, response_id: str) -> dict | None: ...


def _load_fastapi_mail() -> tuple[Any, Any, Any] | tuple[None, None, None]:
    try:
        from fastapi_mail import ConnectionConfig, FastMail, MessageSchema, MessageType
    except ModuleNotFoundError:
        logger.warning("fastapi_mail is not installed; skipping email send.")
        return None, None, None
    return ConnectionConfig, FastMail, (MessageSchema, MessageType)


def get_mail_client() -> Optional[Any]:
    global _fast_mail, _message_schema_type, _message_type_enum
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

    connection_config, fast_mail_cls, message_components = _load_fastapi_mail()
    if connection_config is None or fast_mail_cls is None or message_components is None:
        return None

    _message_schema_type, _message_type_enum = message_components

    logger.info(
        "SMTP configured with host=%s port=%s user=%s",
        settings.smtp_host,
        settings.smtp_port,
        settings.smtp_user,
    )
    conf = connection_config(
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
    _fast_mail = fast_mail_cls(conf)
    return _fast_mail


def _build_message(
    *,
    subject: str,
    recipients: list[str],
    body: str,
    attachments: list[Any] | None = None,
) -> Any | None:
    mail_client = get_mail_client()
    if mail_client is None or _message_schema_type is None or _message_type_enum is None:
        return None
    return _message_schema_type(
        subject=subject,
        recipients=recipients,
        body=body,
        subtype=_message_type_enum.plain,
        attachments=attachments or [],
    )


async def _send_response_email(
    repo: _ResponseRepo,
    response_id: str,
    *,
    subject_prefix: str,
    body_prefix: str,
    log_label: str,
) -> None:
    """Fetch a response by ID and send it via email."""
    logger.info("--- Preparing to send %s email for ID: %s ---", log_label, response_id)
    try:
        try:
            ObjectId(response_id)
        except InvalidId:
            logger.warning("Invalid ObjectId format for email sending: %s", response_id)
            return

        logger.info("Fetching %s from database for email...", log_label)
        response_dict = repo.get_by_id(response_id)

        if not response_dict:
            logger.error("%s with ID %s not found for email sending.", log_label, response_id)
            return

        logger.info("Preparing JSON string of %s for email...", log_label)
        response_json = json.dumps(response_dict, default=pydantic_encoder, indent=2)

        recipients = ["lapan.hugodepaula@gmail.com"]
        patient_email = response_dict.get("patient", {}).get("email")
        if patient_email:
            recipients.append(patient_email)

        message = _build_message(
            subject=f"{subject_prefix} {response_id}",
            recipients=recipients,
            body=f"{body_prefix}\n\n{response_json}",
        )
        if message is None:
            logger.warning("Email client unavailable; skipping send for %s %s", log_label, response_id)
            return

        mail_client = get_mail_client()
        if mail_client is None:
            logger.warning("Email client unavailable; skipping send for %s %s", log_label, response_id)
            return

        logger.info("Sending email...")
        await mail_client.send_message(message)
        logger.info("Email for %s %s sent successfully.", log_label, response_id)

    except Exception as e:
        logger.error("Failed to send email for %s %s: %s", log_label, response_id, e, exc_info=True)


async def send_survey_response_email(response_id: str):
    """Fetch a survey response by its ID and send it via email."""
    repo = SurveyResponseRepository(get_db())
    await _send_response_email(
        repo, response_id,
        subject_prefix="New Survey Response for Survey ID",
        body_prefix="New survey response received:",
        log_label="survey response",
    )


async def send_patient_response_email(response_id: str):
    """Fetch a patient survey response by its ID and send it via email."""
    repo = PatientResponseRepository(get_db())
    await _send_response_email(
        repo, response_id,
        subject_prefix="New Patient Survey Response ID",
        body_prefix="New patient survey response received:",
        log_label="patient response",
    )


async def send_patient_report_email(
    *,
    response_id: str,
    recipients: list[str],
    attachment_paths: list[str],
) -> None:
    """Send a patient report email with PDF attachments."""
    message = _build_message(
        subject=f"Relatório clínico do paciente {response_id}",
        recipients=recipients,
        body=(
            "Segue o relatório clínico em PDF gerado a partir da resposta do paciente.\n\n"
            f"ID da resposta: {response_id}"
        ),
        attachments=attachment_paths,
    )
    if message is None:
        logger.warning("Email client unavailable; skipping report send for %s", response_id)
        return

    mail_client = get_mail_client()
    if mail_client is None:
        logger.warning("Email client unavailable; skipping report send for %s", response_id)
        return

    await mail_client.send_message(message)
