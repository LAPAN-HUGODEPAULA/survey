from datetime import datetime, timedelta
import secrets
import string
from typing import Optional

import bcrypt
import jwt
from fastapi import APIRouter, Depends, Header, HTTPException, status
from fastapi_mail import MessageSchema, MessageType
from pydantic import BaseModel, EmailStr, Field

from app.config.logging_config import logger
from app.config.settings import settings
from app.integrations.email.service import get_mail_client
from app.persistence.deps import get_screener_repo
from app.persistence.repositories.screener_repo import ScreenerRepository
from app.domain.models.screener_model import ScreenerModel, Address, ProfessionalCouncil


router = APIRouter()

# Pydantic model for Screener registration request
class ScreenerRegister(BaseModel):
    cpf: str = Field(..., description="CPF do Screener")
    firstName: str = Field(..., description="Primeiro nome do Screener")
    surname: str = Field(..., description="Sobrenome do Screener")
    email: EmailStr = Field(..., description="Endereço de e-mail do Screener")
    password: str = Field(..., description="Senha do Screener")
    phone: str = Field(..., description="Número de telefone do Screener")
    address: Address = Field(..., description="Endereço profissional do Screener")
    professionalCouncil: ProfessionalCouncil = Field(
        ..., description="Informações do conselho profissional"
    )
    jobTitle: str = Field(..., description="Cargo/profissão do Screener")
    degree: str = Field(..., description="Formação acadêmica/grau do Screener")
    darvCourseYear: Optional[int] = Field(
        None, description="Ano de conclusão do curso DARV (opcional)"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "cpf": "111.111.111-11",
                "firstName": "Maria",
                "surname": "Henriques Moreira Vale",
                "email": "maria.vale@holhos.com",
                "password": "StrongPassword123",
                "phone": "31988447613",
                "address": {
                    "postalCode": "27090639",
                    "street": "Praça da Liberdade",
                    "number": "932",
                    "complement": "Apto 101",
                    "neighborhood": "Savassi",
                    "city": "Belo Horizonte",
                    "state": "MG",
                },
                "professionalCouncil": {
                    "type": "CRP",
                    "registrationNumber": "12543",
                },
                "jobTitle": "Psychologist",
                "degree": "Psychology",
                "darvCourseYear": 2019,
            }
        }


# Pydantic model for Screener login request
class ScreenerLogin(BaseModel):
    email: EmailStr = Field(..., description="Endereço de e-mail do Screener")
    password: str = Field(..., description="Senha do Screener")

    class Config:
        json_schema_extra = {
            "example": {
                "email": "maria.vale@holhos.com",
                "password": "StrongPassword123",
            }
        }


# Pydantic model for JWT token response
class Token(BaseModel):
    access_token: str
    token_type: str


class ScreenerProfile(BaseModel):
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
    darvCourseYear: Optional[int] = None


def _get_email_from_authorization_header(authorization: Optional[str]) -> str:
    if not authorization:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authentication scheme")
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except jwt.PyJWTError as exc:  # pragma: no cover - defensive
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc
    subject = payload.get("sub")
    if not subject:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
    return subject


@router.post("/screeners/register", response_model=ScreenerModel, status_code=status.HTTP_201_CREATED)
async def register_screener(
    screener_data: ScreenerRegister, repo: ScreenerRepository = Depends(get_screener_repo)
):
    """
    Registers a new screener in the system.
    """
    logger.info("Attempting to register new screener with email: %s", screener_data.email)

    # Hash the password
    hashed_password = bcrypt.hashpw(screener_data.password.encode('utf-8'), bcrypt.gensalt())

    # Create a ScreenerModel instance
    new_screener = ScreenerModel(
        cpf=screener_data.cpf,
        firstName=screener_data.firstName,
        surname=screener_data.surname,
        email=screener_data.email,
        password=hashed_password.decode('utf-8'),  # Store the hashed password as string
        phone=screener_data.phone,
        address=screener_data.address,
        professionalCouncil=screener_data.professionalCouncil,
        jobTitle=screener_data.jobTitle,
        degree=screener_data.degree,
        darvCourseYear=screener_data.darvCourseYear,
    )

    try:
        created_screener = repo.create(new_screener)
        logger.info("Screener registered successfully with email: %s", created_screener.email)
        return created_screener
    except ValueError as e:
        logger.warning("Screener registration failed: %s", e)
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(e)
        )
    except Exception as e:
        logger.error("Unexpected error during screener registration: %s", e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred during registration."
        )


@router.post("/screeners/login", response_model=Token)
async def login_for_access_token(
    screener_data: ScreenerLogin, repo: ScreenerRepository = Depends(get_screener_repo)
):
    """
    Authenticates a screener and returns an access token.
    """
    logger.info("Attempting to log in screener with email: %s", screener_data.email)

    screener = repo.find_by_email(screener_data.email)
    if not screener:
        logger.warning("Authentication failed: Screener with email %s not found.", screener_data.email)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas."
        )

    # Verify password
    if not bcrypt.checkpw(screener_data.password.encode('utf-8'), screener.password.encode('utf-8')):
        logger.warning("Authentication failed: Incorrect password for screener %s.", screener_data.email)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas."
        )

    # Generate JWT token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode = {"sub": screener.email}
    expire = datetime.utcnow() + access_token_expires
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

    logger.info("Screener %s logged in successfully.", screener_data.email)
    return {"access_token": encoded_jwt, "token_type": "bearer"}


# Pydantic model for password recovery request
class ScreenerPasswordRecoveryRequest(BaseModel):
    email: EmailStr = Field(..., description="Endereço de e-mail do Screener para recuperação de senha")

    class Config:
        json_schema_extra = {
            "example": {
                "email": "maria.vale@holhos.com",
            }
        }


@router.post("/screeners/recover-password", status_code=status.HTTP_200_OK)
async def recover_password(
    recovery_request: ScreenerPasswordRecoveryRequest,
    repo: ScreenerRepository = Depends(get_screener_repo)
):
    """
    Generates a new random password for the screener and sends it to their registered email.
    """
    logger.info("Attempting to recover password for screener with email: %s", recovery_request.email)

    screener = repo.find_by_email(recovery_request.email)
    if not screener:
        # For security reasons, respond generically even if email not found
        logger.warning("Password recovery requested for unknown email: %s", recovery_request.email)
        return {"message": "Se o e-mail estiver registrado, uma nova senha será enviada."}

    # Generate a new random password
    new_password = ''.join(secrets.choice(string.ascii_letters + string.digits) for i in range(12))
    hashed_new_password = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt())

    # Update screener's password in the database
    updated_screener = repo.update(
        screener_id=str(screener.id),
        data_to_update={"password": hashed_new_password.decode('utf-8')}
    )

    if not updated_screener:
        logger.error("Failed to update password for screener %s after recovery.", recovery_request.email)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao redefinir a senha."
        )

    # Send new password to email
    mail_client = get_mail_client()
    if mail_client is None:
        logger.warning(
            "Email client unavailable; skipping password recovery email for %s",
            recovery_request.email
        )
        return {"message": "Se o e-mail estiver registrado, uma nova senha será enviada. No entanto, o serviço de e-mail não está configurado."}

    message = MessageSchema(
        subject="Recuperação de Senha - LAPAN Survey",
        recipients=[recovery_request.email],
        body=f"""Prezado(a) {screener.firstName},

Sua nova senha para o sistema LAPAN Survey é: {new_password}

Por favor, faça login com esta senha e altere-a o mais rápido possível para uma de sua preferência.

Atenciosamente,
Equipe LAPAN
""",
        subtype=MessageType.plain
    )
    await mail_client.send_message(message)

    logger.info("New password generated and sent to %s", recovery_request.email)
    return {"message": "Se o e-mail estiver registrado, uma nova senha será enviada."}


@router.get("/screeners/me", response_model=ScreenerProfile)
async def get_current_screener(
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
    repo: ScreenerRepository = Depends(get_screener_repo),
):
    email = _get_email_from_authorization_header(authorization)
    screener = repo.find_by_email(email)
    if not screener or not screener.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Screener not found")
    profile_data = screener.model_dump(by_alias=True, exclude={"password"})
    return ScreenerProfile.model_validate(profile_data)
