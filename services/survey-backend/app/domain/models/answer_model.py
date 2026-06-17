from pydantic import BaseModel, ConfigDict

class Answer(BaseModel):
    id: int
    answer: str

    model_config = ConfigDict(extra='forbid')
