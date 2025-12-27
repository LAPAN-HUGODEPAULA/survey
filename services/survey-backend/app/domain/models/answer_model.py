from pydantic import BaseModel, Field, ConfigDict, NaiveDatetime

class Answer(BaseModel):
    id: int
    answer: str

    model_config = ConfigDict(extra='forbid')
