from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional
from datetime import datetime

from app.domain.models.instructions_model import Instructions
from app.domain.models.question_model import Question  


class Survey(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    survey_displayname: str = Field(..., alias="surveyDisplayName")
    survey_name: str = Field(..., alias="surveyName")
    survey_description: str = Field(..., alias="surveyDescription")
    creator_id: str = Field(..., alias="creatorId")
    creator_name: Optional[str] = Field(default=None, alias="creatorName")
    creator_contact: Optional[str] = Field(default=None, alias="creatorContact")
    created_at: datetime = Field(..., alias="createdAt")
    modified_at: datetime = Field(..., alias="modifiedAt")
    instructions: Instructions
    questions: List[Question]
    final_notes: str = Field(..., alias="finalNotes")

    model_config = ConfigDict(extra='forbid')
