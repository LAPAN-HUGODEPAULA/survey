"""Shared authentication request and response models."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.domain.models.screener_model import Address, ProfessionalCouncil


class ScreenerLogin(BaseModel):
    """Credentials used to exchange email and password for an access token."""

    email: EmailStr = Field(..., description="Endereço de e-mail do Screener")
    password: str = Field(..., description="Senha do Screener")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "email": "maria.vale@holhos.com",
                "password": "StrongPassword123",
            }
        }
    )


class Token(BaseModel):
    """JWT bearer token returned after successful authentication."""

    access_token: str
    token_type: str


class ScreenerProfile(BaseModel):
    """Public screener profile returned to clients after authentication."""

    id: str = Field(..., alias="_id")
    cpf: str
    firstName: str
    surname: str
    email: EmailStr
    phone: str
    address: Address
    professionalCouncil: ProfessionalCouncil
    jobTitle: str
    degree: str
    isBuilderAdmin: bool = False
    darvCourseYear: Optional[int] = None
    initialNoticeAcceptedAt: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True, populate_by_name=True)
