from pydantic import BaseModel, Field
from typing import List, Optional

class Answer(BaseModel):
    id: str
    answer_text: str

class Question(BaseModel):
    id: str
    question_text: str
    answers: List[Answer]

class Instructions(BaseModel):
    preamble: str
    question_text: str
    answers: List[Answer]

class Survey(BaseModel):
    survey_id: str = Field(..., alias="surveyId")
    survey_name: str = Field(..., alias="surveyName")
    survey_description: str = Field(..., alias="surveyDescription")
    creator_name: str = Field(..., alias="creatorName")
    creator_contact: str = Field(..., alias="creatorContact")
    created_at: str = Field(..., alias="createdAt")
    modified_at: str = Field(..., alias="modifiedAt")
    instructions: Instructions
    name: str
    questions: List[Question]
    final_notes: str = Field(..., alias="finalNotes")

