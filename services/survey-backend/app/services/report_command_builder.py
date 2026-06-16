"""Helpers for building report delivery commands from stored responses."""

from __future__ import annotations

from typing import Any

from fastapi import HTTPException

from app.api.models.report_delivery_models import SendReportEmailResponse

from .clinical_text_resolver import ClinicalTextResolver
from .report_delivery import (
    ReportDeliveryService,
    SendReportCommand,
    SendReportResult,
)


def build_send_report_command(
    *,
    response_id: str,
    response: dict[str, Any],
    override_text: str | None,
    response_label: str,
    clinical_text_resolver: ClinicalTextResolver,
) -> SendReportCommand:
    """Validate delivery inputs and build the report delivery command."""
    patient_email = _extract_patient_email(response)
    if not patient_email:
        raise HTTPException(
            status_code=422,
            detail=f"{response_label} does not contain an email address.",
        )

    report_text = clinical_text_resolver.resolve(response, override_text)
    if not report_text:
        raise HTTPException(
            status_code=422,
            detail="No report data available to generate PDF.",
        )

    return SendReportCommand(
        response_id=response_id,
        patient_email=patient_email,
        report_text=report_text,
    )


async def deliver_response_report(
    *,
    response_id: str,
    response: dict[str, Any],
    override_text: str | None,
    response_label: str,
    clinical_text_resolver: ClinicalTextResolver,
    report_delivery_service: ReportDeliveryService,
) -> SendReportResult:
    """Build the delivery command and execute the report delivery service."""
    command = build_send_report_command(
        response_id=response_id,
        response=response,
        override_text=override_text,
        response_label=response_label,
        clinical_text_resolver=clinical_text_resolver,
    )
    return await report_delivery_service.execute(command)


async def send_report_email_response(
    *,
    response_id: str,
    response: dict[str, Any] | None,
    override_text: str | None,
    response_label: str,
    missing_detail: str,
    log_label: str,
    clinical_text_resolver: ClinicalTextResolver,
    report_delivery_service: ReportDeliveryService,
    logger: Any,
) -> SendReportEmailResponse:
    """Deliver the report and build the shared API response payload."""
    if not response:
        raise HTTPException(status_code=404, detail=missing_detail)

    try:
        result = await deliver_response_report(
            response_id=response_id,
            response=response,
            override_text=override_text,
            response_label=response_label,
            clinical_text_resolver=clinical_text_resolver,
            report_delivery_service=report_delivery_service,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error(
            "Failed to send report email for %s %s: %s",
            log_label,
            response_id,
            exc,
            exc_info=True,
        )
        raise HTTPException(
            status_code=500,
            detail="Failed to send report email.",
        ) from exc

    return SendReportEmailResponse(
        status=result.status,
        responseId=result.response_id,
        recipients=result.recipients,
    )


async def send_patient_report_email_response(
    *,
    response_id: str,
    response: dict[str, Any] | None,
    override_text: str | None,
    clinical_text_resolver: ClinicalTextResolver,
    report_delivery_service: ReportDeliveryService,
    logger: Any,
) -> SendReportEmailResponse:
    """Deliver a patient response report email."""
    return await send_report_email_response(
        response_id=response_id,
        response=response,
        override_text=override_text,
        response_label="Patient response",
        missing_detail="Patient response not found.",
        log_label="patient response",
        clinical_text_resolver=clinical_text_resolver,
        report_delivery_service=report_delivery_service,
        logger=logger,
    )


async def send_survey_report_email_response(
    *,
    response_id: str,
    response: dict[str, Any] | None,
    override_text: str | None,
    clinical_text_resolver: ClinicalTextResolver,
    report_delivery_service: ReportDeliveryService,
    logger: Any,
) -> SendReportEmailResponse:
    """Deliver a survey response report email."""
    return await send_report_email_response(
        response_id=response_id,
        response=response,
        override_text=override_text,
        response_label="Survey response",
        missing_detail="Survey response not found.",
        log_label="survey response",
        clinical_text_resolver=clinical_text_resolver,
        report_delivery_service=report_delivery_service,
        logger=logger,
    )


def _extract_patient_email(response: dict[str, Any]) -> str:
    patient = response.get("patient")
    if not isinstance(patient, dict):
        return ""
    return str(patient.get("email", "")).strip()
