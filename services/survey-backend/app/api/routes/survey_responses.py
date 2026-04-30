"""FastAPI router for survey responses."""

from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import List, Optional
from typing import Any

from bson.objectid import InvalidId, ObjectId
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, ConfigDict, Field, ValidationError

from app.config.settings import settings
from app.config.logging_config import logger
from app.domain.models.agent_response_model import AgentResponse
from app.domain.models.survey_response_model import SurveyResponse
from app.domain.models.survey_response_with_agent import SurveyResponseWithAgent
from app.integrations.clinical_writer.client import send_to_langgraph_agent
from app.integrations.email.service import (
    send_patient_report_email,
    send_survey_response_email,
)
from app.persistence.deps import (
    get_agent_access_point_repo,
    get_persona_skill_repo,
    get_screener_access_link_repo,
    get_screener_repo,
    get_survey_repo,
    get_survey_response_repo,
)
from app.persistence.repositories.agent_access_point_repo import AgentAccessPointRepository
from app.persistence.repositories.persona_skill_repo import PersonaSkillRepository
from app.persistence.repositories.screener_access_link_repo import ScreenerAccessLinkRepository
from app.persistence.repositories.screener_repo import ScreenerRepository
from app.persistence.repositories.survey_repo import SurveyRepository
from app.persistence.repositories.survey_response_repo import SurveyResponseRepository
from app.domain.models.agent_response_model import AgentArtifactResponse
from app.services.access_point_selection import resolve_access_point_selection
from app.services.survey_prompt_selection import (
    hydrate_survey_persona_defaults,
)

router = APIRouter()


class SendReportEmailRequest(BaseModel):
    """Payload for report email delivery."""

    report_text: str | None = Field(default=None, alias="reportText")
    model_config = ConfigDict(populate_by_name=True)


@router.post("/survey_responses/", response_model=SurveyResponseWithAgent, status_code=status.HTTP_201_CREATED)
async def create_survey_response(
    survey_response: SurveyResponse,
    background_tasks: BackgroundTasks,
    repo: SurveyResponseRepository = Depends(get_survey_response_repo),
    access_link_repo: ScreenerAccessLinkRepository = Depends(get_screener_access_link_repo),
    screener_repo: ScreenerRepository = Depends(get_screener_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
    persona_repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
    access_point_repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
):
    """
    Create a survey response, persist it, trigger an email, and enrich with AI agent output.
    """
    logger.info("--- Received request to create survey response ---")
    patient_name = survey_response.patient.name if survey_response.patient else "Anonymous"
    logger.info("Survey ID: %s, Patient: %s", survey_response.survey_id, patient_name)
    try:
        if survey_response.access_link_token:
            link = access_link_repo.find_by_token(survey_response.access_link_token)
            if not link:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Prepared assessment is no longer available",
                )
            if not screener_repo.find_by_id(link.screener_id) or not survey_repo.get_by_id(link.survey_id):
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Prepared assessment is no longer available",
                )
            survey_response.screener_id = link.screener_id
            survey_response.survey_id = link.survey_id

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

        logger.info("Inserting survey response into database...")
        created = repo.create(survey_response_dict)

        if not created:
            logger.error("Failed to create survey response for survey %s - No insertion ID returned", survey_response.survey_id)
            raise HTTPException(status_code=500, detail="Survey response could not be created")

        inserted_id = str(created.get("_id"))
        logger.info("Successfully created survey response with MongoDB ID: %s", inserted_id)

        logger.info("Adding email sending task to background for response ID: %s", inserted_id)
        background_tasks.add_task(send_survey_response_email, inserted_id)

        survey_response.id = inserted_id
        response_payload = survey_response.model_dump(by_alias=True)
        agent_response: Optional[AgentResponse] = None
        agent_responses: list[AgentArtifactResponse] = []

        try:
            logger.info("Sending survey response to LangGraph agent for processing...")
            runtime_points = _resolve_runtime_access_points(
                selection,
                access_point_repo=access_point_repo,
                survey_id=survey_response.survey_id,
                source_app="survey-frontend",
                flow_key="thank_you.auto_analysis",
            )
            for runtime_point in runtime_points:
                agent_result = await send_to_langgraph_agent(
                    response_payload,
                    input_type="survey7",
                    prompt_key=runtime_point.prompt_key,
                    persona_skill_key=runtime_point.persona_skill_key,
                    output_profile=runtime_point.output_profile,
                    source_app="survey-frontend",
                    patient_ref=survey_response.patient.email if survey_response.patient else None,
                )
                artifact = AgentArtifactResponse(
                    accessPointKey=runtime_point.access_point_key,
                    **agent_result,
                )
                agent_responses.append(artifact)
            agent_response = agent_responses[0] if agent_responses else None
            logger.info("Received agent response for survey %s.", inserted_id)
        except ValueError as exc:
            logger.warning("Invalid prompt selection for survey %s: %s", inserted_id, exc)
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        except ValidationError as exc:
            logger.error("Invalid data returned by agent for survey %s: %s", inserted_id, exc)
            agent_response = AgentResponse(error_message="Invalid agent response format")
        except Exception as exc:
            logger.error("Failed to enrich survey response %s with agent output: %s", inserted_id, exc)

        logger.info("--- Returning created survey response with agent output ---")
        return SurveyResponseWithAgent(
            **response_payload,
            agent_response=agent_response,
            agent_responses=agent_responses,
        )

    except ValueError as exc:
        logger.warning(
            "Invalid survey configuration for survey %s: %s",
            survey_response.survey_id,
            exc,
        )
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error creating survey response for survey %s: %s", survey_response.survey_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e


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


@router.post("/survey_responses/{response_id}/send_report_email", status_code=status.HTTP_200_OK)
async def send_report_email(
    response_id: str,
    payload: SendReportEmailRequest | None = None,
    repo: SurveyResponseRepository = Depends(get_survey_response_repo),
):
    """Generate a report PDF and send it to the patient email."""
    response = repo.get_raw_by_id(response_id)
    if not response:
        raise HTTPException(status_code=404, detail="Survey response not found.")

    patient_email = (
        response.get("patient", {}).get("email", "").strip()
        if isinstance(response.get("patient"), dict)
        else ""
    )
    if not patient_email:
        raise HTTPException(
            status_code=422,
            detail="Survey response does not contain an email address.",
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
            "Failed to send report email for survey response %s: %s",
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
    alternatives = response.get("agentResponses")
    if isinstance(alternatives, list):
        candidate_payloads.extend(
            item for item in alternatives if isinstance(item, dict)
        )

    for payload in candidate_payloads:
        report = payload.get("report")
        if isinstance(report, dict):
            serialized = _report_dict_to_text(report)
            if serialized.strip():
                return serialized
        medical_record = payload.get("medical_record")
        if isinstance(medical_record, str) and medical_record.strip():
            return medical_record.strip()
        error_message = payload.get("error_message")
        if isinstance(error_message, str) and error_message.strip():
            return error_message.strip()

    return ""


def _report_dict_to_text(report: dict[str, Any]) -> str:
    title = str(report.get("title") or "").strip()
    subtitle = str(report.get("subtitle") or "").strip()
    sections = report.get("sections")
    lines: list[str] = []
    if title:
        lines.append(title)
    if subtitle:
        lines.append(subtitle)
    if isinstance(sections, list):
        for section in sections:
            if not isinstance(section, dict):
                continue
            heading = str(section.get("heading") or "").strip()
            body = str(section.get("body") or "").strip()
            if heading:
                lines.append("")
                lines.append(heading)
            if body:
                lines.append(body)
    return "\n".join(lines).strip()


def _generate_report_pdf(report_text: str) -> bytes:
    try:
        from reportlab.lib.pagesizes import A4
        from reportlab.lib.styles import getSampleStyleSheet
        from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer
    except Exception as exc:  # pragma: no cover - dependency guard
        raise HTTPException(
            status_code=500,
            detail="PDF generation dependency is unavailable.",
        ) from exc

    story = []
    styles = getSampleStyleSheet()
    body_style = styles["BodyText"]
    for raw_line in report_text.splitlines():
        line = raw_line.strip()
        if not line:
            story.append(Spacer(1, 8))
            continue
        story.append(Paragraph(line.replace("&", "&amp;"), body_style))
        story.append(Spacer(1, 6))

    with NamedTemporaryFile(suffix=".pdf", delete=False) as tmp_file:
        temp_path = tmp_file.name

    doc = SimpleDocTemplate(
        temp_path,
        pagesize=A4,
        leftMargin=36,
        rightMargin=36,
        topMargin=42,
        bottomMargin=42,
    )
    doc.build(story)
    pdf_bytes = Path(temp_path).read_bytes()
    Path(temp_path).unlink(missing_ok=True)
    return pdf_bytes


def _write_temp_pdf(pdf_bytes: bytes, response_id: str) -> str:
    with NamedTemporaryFile(
        suffix=f"_{response_id}_report.pdf",
        delete=False,
    ) as tmp_file:
        tmp_file.write(pdf_bytes)
        return tmp_file.name


@router.post("/survey_responses/{response_id}/send_email", status_code=status.HTTP_202_ACCEPTED)
async def resend_survey_email(
    response_id: str,
    background_tasks: BackgroundTasks,
    repo: SurveyResponseRepository = Depends(get_survey_response_repo),
):
    """
    Triggers a background task to send the survey response email for a given response ID.
    """
    logger.info("--- Received request to resend email for survey response ID: %s ---", response_id)

    # Optional: Check if the response_id is valid and exists before dispatching the task
    try:
        ObjectId(response_id)
        existing = next((item for item in repo.list_all() if str(item.get("_id")) == response_id), None)
        if not existing:
            logger.warning("Attempted to resend email for a non-existent survey response: %s", response_id)
            raise HTTPException(status_code=404, detail=f"Survey response with id {response_id} not found")
    except InvalidId:
        logger.warning("Invalid ObjectId format for email resending: %s", response_id)
        raise HTTPException(status_code=400, detail="Invalid response ID format")

    background_tasks.add_task(send_survey_response_email, response_id)
    logger.info("Email resend task added to background for response ID: %s", response_id)

    return JSONResponse(
        content={"message": "Email sending process initiated."},
        status_code=status.HTTP_202_ACCEPTED
    )

@router.get("/survey_responses/", response_model=List[SurveyResponse])
async def get_survey_responses(repo: SurveyResponseRepository = Depends(get_survey_response_repo)):
    """Return a list of all survey responses from the database."""
    logger.info("--- Received request to get all survey responses ---")
    try:
        survey_responses = []
        logger.info("Fetching survey responses from database...")
        all_responses = repo.list_all()
        logger.info("Fetched %d survey responses from database.", len(all_responses))

        logger.info("Parsing fetched survey responses...")
        responses_count = 0
        for survey_response in all_responses:
            try:
                logger.debug("Parsing survey response with ID %s", survey_response.get("_id", "unknown"))

                survey_responses.append(SurveyResponse(**survey_response))
                responses_count += 1
            except (ValidationError, ValueError, TypeError, KeyError) as e:
                logger.warning("Failed to parse survey response with ID %s: %s", survey_response.get("_id", "unknown"), e)
                continue

        logger.info("Successfully parsed %d survey responses.", responses_count)
        logger.info("--- Returning survey responses ---")
        return survey_responses

    except Exception as e:
        logger.error("Unexpected error fetching survey response: %s", e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e

@router.get("/survey_responses/{response_id}", response_model=SurveyResponse)
async def get_survey_response(response_id: str, repo: SurveyResponseRepository = Depends(get_survey_response_repo)):
    """Return a single survey response by its ID."""
    logger.info(f"--- Received request to get survey response with id: {response_id} ---")
    try:
        logger.info("Validating response_id format and fetching from database...")
        try:
            ObjectId(response_id)
        except InvalidId:
            logger.warning("Invalid ObjectId format: %s", response_id)
            raise HTTPException(status_code=400, detail="Invalid response ID format")

        survey_response = next((item for item in repo.list_all() if str(item.get("_id")) == response_id), None)

        if survey_response:
            logger.info("Successfully found survey response: %s", response_id)
            logger.info(f"--- Returning survey response with id: {response_id} ---")
            return SurveyResponse(**survey_response)

        logger.warning("Survey response not found: %s", response_id)
        raise HTTPException(status_code=404, detail="Survey response not found")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error fetching survey response %s: %s", response_id, e)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") from e
