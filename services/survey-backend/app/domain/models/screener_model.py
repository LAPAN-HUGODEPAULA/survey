from typing import Optional, List
from pydantic import BaseModel, Field, EmailStr, validator
from pydantic_extra_types.brazil import CPF
from services.survey-backend.app.domain.models.abstract_model import AbstractModel


class ProfessionalCouncil(BaseModel):
    """
    Representa o conselho profissional do Screener.
    """
    type: Optional[str] = Field(None, description="Tipo do conselho profissional (ex: CRP, CRM)")
    registrationNumber: Optional[str] = Field(
        None, description="Número de registro no conselho profissional"
    )

    @validator("type")
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

    @validator("registrationNumber")
    def registration_number_required_if_council_type_not_none(cls, v, values):
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


class ScreenerModel(AbstractModel):
    """
    Modelo de dados para um Screener.
    """
    cpf: CPF = Field(..., description="CPF do Screener", unique=True)
    firstName: str = Field(..., description="Primeiro nome do Screener")
    surname: str = Field(..., description="Sobrenome do Screener")
    email: EmailStr = Field(..., description="Endereço de e-mail do Screener", unique=True)
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

    @validator("phone")
    def validate_phone_number(cls, value):
        # Basic phone number validation (e.g., only digits, min length)
        if not value.isdigit() or len(value) < 8:
            raise ValueError("Número de telefone inválido.")
        return value

    class Settings:
        name = "screeners"
