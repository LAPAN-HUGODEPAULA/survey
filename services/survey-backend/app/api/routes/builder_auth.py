"""Authentication endpoints for the survey-builder administrative shell."""

from __future__ import annotations

import bcrypt
from fastapi import APIRouter, Depends, Response, status
from pydantic import BaseModel, ConfigDict, Field

from app.api.dependencies.builder_auth import (
    build_auth_http_exception,
    clear_builder_auth_cookies,
    create_builder_csrf_token,
    create_builder_session_token,
    require_builder_admin,
    set_builder_auth_cookies,
)
from app.api.dependencies.correlation import CorrelationID
from app.api.decorators.builder_audit import audit_auth_operation
from app.api.models.auth_models import ScreenerLogin, ScreenerProfile
from app.domain.models.screener_model import ScreenerModel
from app.persistence.deps import get_screener_repo
from app.persistence.repositories.screener_repo import ScreenerRepository

router = APIRouter()


class BuilderSessionResponse(BaseModel):
    """Authenticated builder session payload used by the Flutter admin shell."""

    profile: ScreenerProfile
    csrfToken: str = Field(..., alias="csrfToken")

    model_config = ConfigDict(populate_by_name=True)


def _to_profile(screener: ScreenerModel) -> ScreenerProfile:
    profile_data = screener.model_dump(by_alias=True, exclude={"password"})
    return ScreenerProfile.model_validate(profile_data)


@router.post("/builder/login", response_model=BuilderSessionResponse)
@audit_auth_operation("login")
async def login_builder(
    payload: ScreenerLogin,
    response: Response,
    repo: ScreenerRepository = Depends(get_screener_repo),
    correlation_id: CorrelationID,
) -> BuilderSessionResponse:
    screener = repo.find_by_email(payload.email)
    if not screener or not bcrypt.checkpw(
        payload.password.encode("utf-8"),
        screener.password.encode("utf-8"),
    ):
        raise build_auth_http_exception(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="INVALID_CREDENTIALS",
            user_message="E-mail ou senha incorretos.",
            operation="builder_login",
            retryable=True,
        )

    if not screener.isBuilderAdmin:
        raise build_auth_http_exception(
            status_code=status.HTTP_403_FORBIDDEN,
            code="BUILDER_ADMIN_REQUIRED",
            user_message="Esta conta não tem permissão para acessar o construtor administrativo.",
            operation="builder_login",
            retryable=False,
        )

    session_token = create_builder_session_token(screener.id or "")
    csrf_token = create_builder_csrf_token(screener.id or "")
    set_builder_auth_cookies(
        response,
        session_token=session_token,
        csrf_token=csrf_token,
    )
    return BuilderSessionResponse(profile=_to_profile(screener), csrfToken=csrf_token)


@router.get("/builder/session", response_model=BuilderSessionResponse)
async def get_builder_session(
    response: Response,
    screener: ScreenerModel = Depends(require_builder_admin),
) -> BuilderSessionResponse:
    session_token = create_builder_session_token(screener.id or "")
    csrf_token = create_builder_csrf_token(screener.id or "")
    set_builder_auth_cookies(
        response,
        session_token=session_token,
        csrf_token=csrf_token,
    )
    return BuilderSessionResponse(profile=_to_profile(screener), csrfToken=csrf_token)


@router.post("/builder/logout", status_code=status.HTTP_204_NO_CONTENT)
@audit_auth_operation("logout")
async def logout_builder(
    response: Response,
    correlation_id: CorrelationID,
) -> None:
    clear_builder_auth_cookies(response)
