from fastapi import Depends
from pymongo.database import Database

from app.persistence.mongo.client import get_db
from app.persistence.repositories.survey_repo import SurveyRepository
from app.persistence.repositories.survey_response_repo import SurveyResponseRepository
from app.persistence.repositories.patient_response_repo import PatientResponseRepository
from app.persistence.repositories.screener_repo import ScreenerRepository # Added import
from app.persistence.repositories.template_repo import TemplateRepository
from app.persistence.repositories.template_audit_repo import TemplateAuditRepository
from app.persistence.repositories.chat_session_repo import ChatSessionRepository
from app.persistence.repositories.chat_message_repo import ChatMessageRepository
from app.persistence.repositories.document_repo import DocumentRepository
from app.persistence.repositories.privacy_request_repo import PrivacyRequestRepository
from app.persistence.repositories.security_audit_repo import SecurityAuditRepository
from app.persistence.repositories.data_lifecycle_repo import DataLifecycleRepository

def get_database() -> Database:
    return get_db()

def get_survey_repo(db: Database = Depends(get_database)) -> SurveyRepository:
    return SurveyRepository(db)

def get_survey_response_repo(db: Database = Depends(get_database)) -> SurveyResponseRepository:
    return SurveyResponseRepository(db)

def get_patient_response_repo(db: Database = Depends(get_database)) -> PatientResponseRepository:
    return PatientResponseRepository(db)

def get_screener_repo(db: Database = Depends(get_database)) -> ScreenerRepository: # Added function
    return ScreenerRepository(db)


def get_template_repo(db: Database = Depends(get_database)) -> TemplateRepository:
    return TemplateRepository(db)


def get_template_audit_repo(db: Database = Depends(get_database)) -> TemplateAuditRepository:
    return TemplateAuditRepository(db)

def get_chat_session_repo(db: Database = Depends(get_database)) -> ChatSessionRepository:
    return ChatSessionRepository(db)

def get_chat_message_repo(db: Database = Depends(get_database)) -> ChatMessageRepository:
    return ChatMessageRepository(db)

def get_document_repo(db: Database = Depends(get_database)) -> DocumentRepository:
    return DocumentRepository(db)

def get_privacy_request_repo(db: Database = Depends(get_database)) -> PrivacyRequestRepository:
    return PrivacyRequestRepository(db)

def get_security_audit_repo(db: Database = Depends(get_database)) -> SecurityAuditRepository:
    return SecurityAuditRepository(db)

def get_data_lifecycle_repo(db: Database = Depends(get_database)) -> DataLifecycleRepository:
    return DataLifecycleRepository(db)
