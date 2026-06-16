"""Dependency providers for response orchestration and report delivery."""

from __future__ import annotations

from fastapi import Depends

from app.config.settings import settings
from app.integrations.clinical_writer import send_to_langgraph_agent
from app.integrations.email.service import send_patient_report_email
from app.persistence.deps import (
    get_agent_access_point_repo,
    get_patient_response_repo,
    get_persona_skill_repo,
    get_screener_access_link_repo,
    get_screener_repo,
    get_survey_repo,
    get_survey_response_repo,
    get_system_settings_repo,
)
from app.persistence.repositories.agent_access_point_repo import AgentAccessPointRepository
from app.persistence.repositories.patient_response_repo import PatientResponseRepository
from app.persistence.repositories.persona_skill_repo import PersonaSkillRepository
from app.persistence.repositories.screener_access_link_repo import ScreenerAccessLinkRepository
from app.persistence.repositories.screener_repo import ScreenerRepository
from app.persistence.repositories.survey_repo import SurveyRepository
from app.persistence.repositories.survey_response_repo import SurveyResponseRepository
from app.persistence.repositories.system_settings_repo import SystemSettingsRepository
from app.services.clinical_text_resolver import ClinicalTextResolver
from app.services.report_delivery import ReportDeliveryService
from app.services.report_pdf import ReportlabPDFCompiler
from app.services.response_submission import (
    PatientSubmissionOrchestrator,
    SurveySubmissionOrchestrator,
)


def get_clinical_text_resolver() -> ClinicalTextResolver:
    """Build the shared clinical text resolver."""
    return ClinicalTextResolver()


def get_report_pdf_compiler() -> ReportlabPDFCompiler:
    """Build the shared ReportLab PDF compiler."""
    return ReportlabPDFCompiler()


def get_report_delivery_service(
    pdf_compiler: ReportlabPDFCompiler = Depends(get_report_pdf_compiler),
) -> ReportDeliveryService:
    """Build the command-based report delivery service."""
    return ReportDeliveryService(
        pdf_compiler=pdf_compiler,
        email_sender=send_patient_report_email,
        copy_recipient=settings.smtp_user or "lapan.hugodepaula@gmail.com",
    )


def get_patient_submission_orchestrator(
    response_repo: PatientResponseRepository = Depends(get_patient_response_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
    persona_repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
    access_point_repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
    system_settings_repo: SystemSettingsRepository = Depends(get_system_settings_repo),
) -> PatientSubmissionOrchestrator:
    """Build the patient response submission orchestrator."""
    return PatientSubmissionOrchestrator(
        response_repo=response_repo,
        survey_repo=survey_repo,
        persona_repo=persona_repo,
        access_point_repo=access_point_repo,
        system_settings_repo=system_settings_repo,
        agent_runner=send_to_langgraph_agent,
    )


def get_survey_submission_orchestrator(
    response_repo: SurveyResponseRepository = Depends(get_survey_response_repo),
    access_link_repo: ScreenerAccessLinkRepository = Depends(get_screener_access_link_repo),
    screener_repo: ScreenerRepository = Depends(get_screener_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
    persona_repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
    access_point_repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
    system_settings_repo: SystemSettingsRepository = Depends(get_system_settings_repo),
) -> SurveySubmissionOrchestrator:
    """Build the survey response submission orchestrator."""
    return SurveySubmissionOrchestrator(
        response_repo=response_repo,
        survey_repo=survey_repo,
        persona_repo=persona_repo,
        access_point_repo=access_point_repo,
        system_settings_repo=system_settings_repo,
        access_link_repo=access_link_repo,
        screener_repo=screener_repo,
        agent_runner=send_to_langgraph_agent,
    )
