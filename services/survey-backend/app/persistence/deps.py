from fastapi import Depends
from pymongo.database import Database

from app.persistence.mongo.client import get_db
from app.persistence.repositories.survey_repo import SurveyRepository
from app.persistence.repositories.survey_response_repo import SurveyResponseRepository
from app.persistence.repositories.patient_response_repo import PatientResponseRepository

def get_database() -> Database:
    return get_db()

def get_survey_repo(db: Database = Depends(get_database)) -> SurveyRepository:
    return SurveyRepository(db)

def get_survey_response_repo(db: Database = Depends(get_database)) -> SurveyResponseRepository:
    return SurveyResponseRepository(db)

def get_patient_response_repo(db: Database = Depends(get_database)) -> PatientResponseRepository:
    return PatientResponseRepository(db)
