from pydantic import BaseModel, ConfigDict, Field, field_validator
from typing import List, Optional
from datetime import datetime

from app.domain.models._key_validation import normalize_key
from app.domain.models.instructions_model import Instructions
from app.domain.models.question_model import Question
from app.domain.models.survey_prompt_model import SurveyPromptReference


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
    prompt: Optional[SurveyPromptReference] = None
    persona_skill_key: Optional[str] = Field(default=None, alias="personaSkillKey")
    output_profile: Optional[str] = Field(default=None, alias="outputProfile")

    model_config = ConfigDict(extra='forbid', populate_by_name=True)

    @field_validator("persona_skill_key", "output_profile")
    @classmethod
    def validate_optional_key_fields(cls, value: str | None, info) -> str | None:
        """Normalize optional runtime keys used for persona configuration."""
        return normalize_key(value, field_name=info.field_name, optional=True)
