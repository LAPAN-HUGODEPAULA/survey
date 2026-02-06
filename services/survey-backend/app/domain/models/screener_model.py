from datetime import datetime
import re
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


class ProfessionalCouncil(BaseModel):
    """
    Representa o conselho profissional do Screener.
    """
    type: Optional[str] = Field(None, description="Tipo do conselho profissional (ex: CRP, CRM)")
    registrationNumber: Optional[str] = Field(
        None, description="Número de registro no conselho profissional"
    )

    @field_validator("type")
    @classmethod
    def validate_council_type(cls, value):
        if value is not None and value not in [
            "CFEP",
            "CRP",
            "COREN",
            "CRM",
            "CREFITO",
            "CREFONO",
            "CRN",
            "none",  # Allow 'none' for cases without a council
        ]:
            raise ValueError(
                "Tipo de conselho profissional inválido. "
                "Valores permitidos: CFEP, CRP, COREN, CRM, CREFITO, CREFONO, CRN, none."
            )
        return value

    @field_validator("registrationNumber")
    @classmethod
    def registration_number_required_if_council_type_not_none(cls, v, info):
        values = info.data
        if values.get("type") and values["type"] != "none" and not v:
            raise ValueError(
                "O número de registro é obrigatório se o tipo de conselho não for 'none'."
            )
        return v


class Address(BaseModel):
    """
    Representa o endereço profissional do Screener.
    """
    postalCode: str = Field(..., description="CEP")
    street: str = Field(..., description="Logradouro")
    number: str = Field(..., description="Número")
    complement: Optional[str] = Field(None, description="Complemento")
    neighborhood: str = Field(..., description="Bairro")
    city: str = Field(..., description="Cidade")
    state: str = Field(..., description="Estado (UF)")


class ScreenerModel(BaseModel):
    """
    Modelo de dados para um Screener.
    """
    id: Optional[str] = Field(default=None, alias="_id")
    cpf: str = Field(..., description="CPF do Screener", json_schema_extra={"unique": True})
    firstName: str = Field(..., description="Primeiro nome do Screener")
    surname: str = Field(..., description="Sobrenome do Screener")
    email: EmailStr = Field(..., description="Endereço de e-mail do Screener", json_schema_extra={"unique": True})
    password: str = Field(..., description="Senha do Screener (hash)")
    phone: str = Field(..., description="Número de telefone do Screener")
    address: Address = Field(..., description="Endereço profissional do Screener")
    professionalCouncil: ProfessionalCouncil = Field(
        ..., description="Informações do conselho profissional"
    )
    jobTitle: str = Field(..., description="Cargo/profissão do Screener")
    degree: str = Field(..., description="Formação acadêmica/grau do Screener")
    darvCourseYear: Optional[int] = Field(
        None,
        description="Ano de conclusão do curso DARV (opcional), deve ser maior ou igual a 2000",
        ge=2000,
    )

    @field_validator("phone")
    @classmethod
    def validate_phone_number(cls, value):
        # Basic phone number validation (e.g., only digits, min length)
        if not value.isdigit() or len(value) < 8:
            raise ValueError("Número de telefone inválido.")
        return value

    @field_validator("cpf")
    @classmethod
    def validate_cpf(cls, value: str) -> str:
        digits = re.sub(r"\D", "", value or "")
        if len(digits) != 11:
            raise ValueError("CPF deve conter 11 dígitos.")
        return digits

    createdAt: Optional[datetime] = Field(default=None, alias="createdAt")
    updatedAt: Optional[datetime] = Field(default=None, alias="updatedAt")

    model_config = ConfigDict(populate_by_name=True, extra="forbid")
