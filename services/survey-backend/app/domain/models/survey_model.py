from pydantic import BaseModel, Field, ConfigDict, model_validator
from typing import List, Optional
from datetime import datetime

from app.domain.models.instructions_model import Instructions
from app.domain.models.question_model import Question
from app.domain.models.survey_prompt_model import SurveyPromptAssociation


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
    prompt_associations: List[SurveyPromptAssociation] = Field(
        default_factory=list,
        alias="promptAssociations",
    )

    model_config = ConfigDict(extra='forbid', populate_by_name=True)

    @model_validator(mode="after")
    def validate_unique_prompt_outcomes(self) -> "Survey":
        """Keep only one prompt association per outcome type."""
        seen: set[str] = set()
        for association in self.prompt_associations:
            if association.outcome_type in seen:
                raise ValueError("promptAssociations must not repeat outcomeType values")
            seen.add(association.outcome_type)
        return self
