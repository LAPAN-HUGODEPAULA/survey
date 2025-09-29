from bson import ObjectId
from pydantic import BaseModel, Field, ConfigDict, NaiveDatetime
from typing import List

class Patient(BaseModel):
    name: str
    email: str
    birth_date: str = Field(..., alias="birthDate")
    gender: str
    ethnicity: str
    education_level: str = Field(..., alias="educationLevel")
    profession: str
    medication: List[str]
    diagnoses: List[str]
    model_config = ConfigDict(extra='forbid')
