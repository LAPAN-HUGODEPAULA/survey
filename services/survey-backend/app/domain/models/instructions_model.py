from pydantic import BaseModel, Field, ConfigDict
from typing import List

class Instructions(BaseModel):
    preamble: str
    question_text: str = Field(..., alias="questionText")
    answers: List[str]

    model_config = ConfigDict(extra='forbid')

