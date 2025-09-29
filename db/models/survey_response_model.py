from pydantic import BaseModel, Field, ConfigDict, NaiveDatetime
from typing import List, Optional
from datetime import datetime

from app.models.patient_model import Patient
from app.models.answer_model import Answer

class SurveyResponse(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    survey_id: str = Field(..., alias="surveyId")
    creator_name: str = Field(..., alias="creatorName")
    creator_contact: str = Field(..., alias="creatorContact")
    test_date: datetime = Field(..., alias="testDate")
    screener_name: str = Field(..., alias="screenerName")
    screener_email: str = Field(..., alias="screenerEmail")
    patient: Patient
    answers: List[Answer]

    model_config = ConfigDict(extra='forbid')

