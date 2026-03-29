"""Dependency providers for FastAPI repository injections."""

from fastapi import Depends
from pymongo.database import Database

from app.persistence.mongo.client import get_db
from app.persistence.repositories.persona_skill_repo import PersonaSkillRepository
from app.persistence.repositories.survey_repo import SurveyRepository
from app.persistence.repositories.survey_prompt_repo import SurveyPromptRepository
from app.persistence.repositories.survey_response_repo import SurveyResponseRepository
from app.persistence.repositories.patient_response_repo import PatientResponseRepository
from app.persistence.repositories.screener_repo import ScreenerRepository
from app.persistence.repositories.screener_access_link_repo import ScreenerAccessLinkRepository
from app.persistence.repositories.template_repo import TemplateRepository
from app.persistence.repositories.template_audit_repo import TemplateAuditRepository
from app.persistence.repositories.chat_session_repo import ChatSessionRepository
from app.persistence.repositories.chat_message_repo import ChatMessageRepository
from app.persistence.repositories.document_repo import DocumentRepository
from app.persistence.repositories.privacy_request_repo import PrivacyRequestRepository
from app.persistence.repositories.security_audit_repo import SecurityAuditRepository
from app.persistence.repositories.data_lifecycle_repo import DataLifecycleRepository

def get_database() -> Database:
    """Return the shared MongoDB database handle."""
    return get_db()

def get_survey_repo(db: Database = Depends(get_database)) -> SurveyRepository:
    """Build a survey repository for the current request."""
    return SurveyRepository(db)

def get_survey_prompt_repo(db: Database = Depends(get_database)) -> SurveyPromptRepository:
    """Build a survey prompt repository for the current request."""
    return SurveyPromptRepository(db)

def get_persona_skill_repo(db: Database = Depends(get_database)) -> PersonaSkillRepository:
    """Build a persona skill repository for the current request."""
    return PersonaSkillRepository(db)

def get_survey_response_repo(db: Database = Depends(get_database)) -> SurveyResponseRepository:
    """Build a survey response repository for the current request."""
    return SurveyResponseRepository(db)

def get_patient_response_repo(db: Database = Depends(get_database)) -> PatientResponseRepository:
    """Build a patient response repository for the current request."""
    return PatientResponseRepository(db)

def get_screener_repo(db: Database = Depends(get_database)) -> ScreenerRepository:
    """Build a screener repository for the current request."""
    return ScreenerRepository(db)


def get_screener_access_link_repo(
    db: Database = Depends(get_database),
) -> ScreenerAccessLinkRepository:
    """Build a screener access link repository for the current request."""
    return ScreenerAccessLinkRepository(db)


def get_template_repo(db: Database = Depends(get_database)) -> TemplateRepository:
    """Build a template repository for the current request."""
    return TemplateRepository(db)


def get_template_audit_repo(db: Database = Depends(get_database)) -> TemplateAuditRepository:
    """Build a template audit repository for the current request."""
    return TemplateAuditRepository(db)

def get_chat_session_repo(db: Database = Depends(get_database)) -> ChatSessionRepository:
    """Build a chat session repository for the current request."""
    return ChatSessionRepository(db)

def get_chat_message_repo(db: Database = Depends(get_database)) -> ChatMessageRepository:
    """Build a chat message repository for the current request."""
    return ChatMessageRepository(db)

def get_document_repo(db: Database = Depends(get_database)) -> DocumentRepository:
    """Build a document repository for the current request."""
    return DocumentRepository(db)

def get_privacy_request_repo(db: Database = Depends(get_database)) -> PrivacyRequestRepository:
    """Build a privacy request repository for the current request."""
    return PrivacyRequestRepository(db)

def get_security_audit_repo(db: Database = Depends(get_database)) -> SecurityAuditRepository:
    """Build a security audit repository for the current request."""
    return SecurityAuditRepository(db)

def get_data_lifecycle_repo(db: Database = Depends(get_database)) -> DataLifecycleRepository:
    """Build a data lifecycle repository for the current request."""
    return DataLifecycleRepository(db)
