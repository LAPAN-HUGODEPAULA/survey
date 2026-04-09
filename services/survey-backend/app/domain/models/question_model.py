from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional

class Question(BaseModel):
    id: int
    question_text: str = Field(..., alias="questionText")
    answers: List[str]
    label: Optional[str] = Field(default=None, alias="label")

    model_config = ConfigDict(extra='forbid')
