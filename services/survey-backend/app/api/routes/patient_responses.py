"""FastAPI router for patient survey responses."""

from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import Any, Optional

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, status
from pydantic import BaseModel, ConfigDict, Field, ValidationError

from app.config.settings import settings
from app.config.logging_config import logger
from app.domain.models.agent_response_model import AgentResponse
from app.domain.models.agent_response_model import AgentArtifactResponse
from app.domain.models.survey_response_model import SurveyResponse
from app.domain.models.survey_response_with_agent import SurveyResponseWithAgent
from app.integrations.clinical_writer.client import send_to_langgraph_agent
from app.integrations.email.service import (
    send_patient_report_email,
    send_patient_response_email,
)
from app.persistence.deps import (
    get_agent_access_point_repo,
    get_patient_response_repo,
    get_persona_skill_repo,
    get_survey_repo,
)
from app.persistence.repositories.agent_access_point_repo import AgentAccessPointRepository
from app.persistence.repositories.patient_response_repo import PatientResponseRepository
from app.persistence.repositories.persona_skill_repo import PersonaSkillRepository
from app.persistence.repositories.survey_repo import SurveyRepository
from app.services.access_point_selection import resolve_access_point_selection
from app.services.survey_prompt_selection import (
    hydrate_survey_persona_defaults,
)

router = APIRouter()


class SendReportEmailRequest(BaseModel):
    """Payload for report email delivery."""

    report_text: str | None = Field(default=None, alias="reportText")
    model_config = ConfigDict(populate_by_name=True)


@router.post("/patient_responses/", response_model=SurveyResponseWithAgent, status_code=status.HTTP_201_CREATED)
async def create_patient_response(
    survey_response: SurveyResponse,
    background_tasks: BackgroundTasks,
    repo: PatientResponseRepository = Depends(get_patient_response_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
    persona_repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
    access_point_repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
):
    """
    Create a patient survey response, persist it, trigger an email, and enrich with AI agent output.
    """
    logger.info("--- Received request to create patient response ---")
    patient_name = survey_response.patient.name if survey_response.patient else "Anonymous"
    logger.info("Survey ID: %s, Patient: %s", survey_response.survey_id, patient_name)
    try:
        resolved_survey = survey_repo.get_by_id(survey_response.survey_id)
        resolved_survey = hydrate_survey_persona_defaults(
            resolved_survey,
            requested_persona_skill_key=survey_response.persona_skill_key,
            requested_output_profile=survey_response.output_profile,
            get_persona_by_key=persona_repo.get_by_key,
            get_persona_by_output_profile=persona_repo.get_by_output_profile,
        )
        selection = resolve_access_point_selection(
            survey=resolved_survey,
            requested_access_point_key=survey_response.access_point_key,
            requested_prompt_key=survey_response.prompt_key,
            requested_persona_skill_key=survey_response.persona_skill_key,
            requested_output_profile=survey_response.output_profile,
            input_type="survey7",
            get_access_point_by_key=access_point_repo.get_by_key,
        )
        survey_response.access_point_key = selection.access_point_key
        survey_response.prompt_key = selection.prompt_key
        survey_response.persona_skill_key = selection.persona_skill_key
        survey_response.output_profile = selection.output_profile

        logger.info("Dumping survey response model to dict...")
        survey_response_dict = survey_response.model_dump(by_alias=True)
        if survey_response_dict.get("_id") is None:
            survey_response_dict.pop("_id", None)
        logger.info("Survey response data prepared for insertion.")

        logger.info("Inserting survey response into patient_responses collection...")
        created = repo.create(survey_response_dict)

        if not created:
            logger.error("Failed to create patient response for survey %s - No insertion ID returned", survey_response.survey_id)
            raise HTTPException(status_code=500, detail="Survey response could not be created")

        inserted_id = str(created.get("_id"))
        logger.info("Successfully created patient response with MongoDB ID: %s", inserted_id)

        background_tasks.add_task(send_patient_response_email, inserted_id)

        survey_response.id = inserted_id
        response_payload = survey_response.model_dump(by_alias=True)
        agent_response: Optional[AgentResponse] = None
        agent_responses: list[AgentArtifactResponse] = []

        try:
            logger.info("Sending patient response to LangGraph agent for processing...")
            runtime_points = _resolve_runtime_access_points(
                selection,
                access_point_repo=access_point_repo,
                survey_id=survey_response.survey_id,
                source_app="survey-patient",
                flow_key="thank_you.auto_analysis",
            )
            for runtime_point in runtime_points:
                agent_result = await send_to_langgraph_agent(
                    response_payload,
                    input_type="survey7",
                    prompt_key=runtime_point.prompt_key,
                    persona_skill_key=runtime_point.persona_skill_key,
                    output_profile=runtime_point.output_profile,
                    source_app="survey-patient",
                    patient_ref=survey_response.patient.email if survey_response.patient else None,
                )
                artifact = AgentArtifactResponse(
                    accessPointKey=runtime_point.access_point_key,
                    **agent_result,
                )
                agent_responses.append(artifact)
            agent_response = agent_responses[0] if agent_responses else None
            logger.info("Received agent response for patient response %s.", inserted_id)
        except ValueError as exc:
            logger.warning("Invalid prompt selection for patient response %s: %s", inserted_id, exc)
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        except ValidationError as exc:
            logger.error("Invalid data returned by agent for patient response %s: %s", inserted_id, exc)
            agent_response = AgentResponse(error_message="Invalid agent response format")
        except Exception as exc:
            logger.error("Failed to enrich patient response %s with agent output: %s", inserted_id, exc)

        if agent_responses:
            repo.update_fields(
                inserted_id,
                {
                    "agentResponse": agent_response.model_dump(by_alias=True)
                    if agent_response is not None
                    else None,
                    "agentResponses": [
                        item.model_dump(by_alias=True) for item in agent_responses
                    ],
                },
            )

        logger.info("--- Returning created patient response with agent output ---")
        return SurveyResponseWithAgent(
            **response_payload,
            agent_response=agent_response,
            agent_responses=agent_responses,
        )

    except ValueError as exc:
        logger.warning(
            "Invalid survey configuration for patient response %s: %s",
            survey_response.survey_id,
            exc,
        )
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error creating patient response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e


@router.post("/patient_responses/{response_id}/send_report_email", status_code=status.HTTP_200_OK)
async def send_report_email(
    response_id: str,
    payload: SendReportEmailRequest | None = None,
    repo: PatientResponseRepository = Depends(get_patient_response_repo),
):
    """Generate a report PDF and send it to the patient email."""
    response = repo.get_by_id(response_id)
    if not response:
        raise HTTPException(status_code=404, detail="Patient response not found.")

    patient_email = (
        response.get("patient", {}).get("email", "").strip()
        if isinstance(response.get("patient"), dict)
        else ""
    )
    if not patient_email:
        raise HTTPException(
            status_code=422,
            detail="Patient response does not contain an email address.",
        )

    report_text = _resolve_report_text(response, payload.report_text if payload else None)
    if not report_text:
        raise HTTPException(
            status_code=422,
            detail="No report data available to generate PDF.",
        )

    pdf_bytes = _generate_report_pdf(report_text)
    recipients = _resolve_report_recipients(patient_email)
    temp_file_path = _write_temp_pdf(pdf_bytes, response_id)
    try:
        await send_patient_report_email(
            response_id=response_id,
            recipients=recipients,
            attachment_paths=[temp_file_path],
        )
    except Exception as exc:
        logger.error(
            "Failed to send report email for patient response %s: %s",
            response_id,
            exc,
            exc_info=True,
        )
        raise HTTPException(
            status_code=500,
            detail="Failed to send report email.",
        ) from exc
    finally:
        Path(temp_file_path).unlink(missing_ok=True)

    return {
        "status": "sent",
        "responseId": response_id,
        "recipients": recipients,
    }


def _resolve_runtime_access_points(
    primary_selection,
    *,
    access_point_repo: AgentAccessPointRepository,
    survey_id: str,
    source_app: str,
    flow_key: str,
):
    runtime_points = [primary_selection]
    configured = access_point_repo.list_for_runtime(
        source_app=source_app,
        flow_key=flow_key,
        survey_id=survey_id,
    )
    seen_keys = {primary_selection.access_point_key, None}
    for item in configured:
        access_point_key = item.get("accessPointKey")
        if access_point_key in seen_keys:
            continue
        seen_keys.add(access_point_key)
        runtime_points.append(
            type(primary_selection)(
                access_point_key=access_point_key,
                prompt_key=item["promptKey"],
                persona_skill_key=item.get("personaSkillKey"),
                output_profile=item.get("outputProfile"),
            )
        )
    return runtime_points


def _resolve_report_recipients(patient_email: str) -> list[str]:
    recipients = [patient_email]
    lapan_copy_email = settings.smtp_user or "lapan.hugodepaula@gmail.com"
    if lapan_copy_email and lapan_copy_email.lower() != patient_email.lower():
        recipients.append(lapan_copy_email)
    return recipients


def _resolve_report_text(response: dict[str, Any], override_text: str | None) -> str:
    if override_text and override_text.strip():
        return override_text.strip()

    candidate_payloads: list[dict[str, Any]] = []
    primary = response.get("agentResponse")
    if isinstance(primary, dict):
        candidate_payloads.append(primary)
    artifacts = response.get("agentResponses")
    if isinstance(artifacts, list):
        candidate_payloads.extend(item for item in artifacts if isinstance(item, dict))

    for payload in candidate_payloads:
        medical_record = payload.get("medicalRecord")
        if isinstance(medical_record, str) and medical_record.strip():
            return medical_record.strip()
        report = payload.get("report")
        if isinstance(report, dict):
            rendered = _report_dict_to_text(report).strip()
            if rendered:
                return rendered
    return ""


def _report_dict_to_text(report: dict[str, Any], level: int = 0) -> str:
    lines: list[str] = []
    indent = "  " * level
    for key, value in report.items():
        label = key.replace("_", " ").strip().capitalize()
        if value is None:
            continue
        if isinstance(value, str):
            content = value.strip()
            if content:
                lines.append(f"{indent}{label}: {content}")
            continue
        if isinstance(value, dict):
            nested = _report_dict_to_text(value, level + 1).strip()
            if nested:
                lines.append(f"{indent}{label}:")
                lines.append(nested)
            continue
        if isinstance(value, list):
            if not value:
                continue
            lines.append(f"{indent}{label}:")
            for item in value:
                if isinstance(item, dict):
                    nested = _report_dict_to_text(item, level + 2).strip()
                    if nested:
                        lines.append(f"{indent}  -")
                        lines.append(nested)
                else:
                    item_text = str(item).strip()
                    if item_text:
                        lines.append(f"{indent}  - {item_text}")
            continue
        lines.append(f"{indent}{label}: {value}")
    return "\n".join(lines)


def _generate_report_pdf(report_text: str) -> bytes:
    try:
        from fpdf import FPDF
    except ModuleNotFoundError as exc:
        raise HTTPException(
            status_code=503,
            detail="PDF generation dependency is not installed.",
        ) from exc

    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    pdf.set_font("Helvetica", size=11)
    for line in report_text.splitlines() or [" "]:
        pdf.multi_cell(0, 6, text=line if line.strip() else " ")
    return bytes(pdf.output(dest="S"))


def _write_temp_pdf(pdf_bytes: bytes, response_id: str) -> str:
    with NamedTemporaryFile(
        mode="wb",
        suffix=f"_{response_id}.pdf",
        prefix="patient_report_",
        delete=False,
    ) as temp_file:
        temp_file.write(pdf_bytes)
        return temp_file.name
