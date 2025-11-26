from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional
from datetime import datetime

from models.instructions_model import Instructions
from models.question_model import Question  


class Survey(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id")
    survey_displayname: str = Field(..., alias="surveyDisplayName")
    survey_name: str = Field(..., alias="surveyName")
    survey_description: str = Field(..., alias="surveyDescription")
    creator_name: str = Field(..., alias="creatorName")
    creator_contact: str = Field(..., alias="creatorContact")
    created_at: datetime = Field(..., alias="createdAt")
    modified_at: datetime = Field(..., alias="modifiedAt")
    instructions: Instructions
    questions: List[Question]
    final_notes: str = Field(..., alias="finalNotes")

    model_config = ConfigDict(extra='forbid')


