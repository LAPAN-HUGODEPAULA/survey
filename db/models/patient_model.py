from bson import ObjectId
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional

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
    family_history: Optional[str] = Field(default="", alias="family_history")
    social_history: Optional[str] = Field(default="", alias="social_history")
    medical_history: Optional[str] = Field(default="", alias="medical_history")
    medication_history: Optional[str] = Field(default="", alias="medication_history")
    model_config = ConfigDict(populate_by_name=True, extra='forbid')
