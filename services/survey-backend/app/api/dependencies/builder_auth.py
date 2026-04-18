"""Builder session helpers and FastAPI dependencies."""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any

import jwt
from fastapi import Depends, HTTPException, Request, Response, status

from app.config.settings import settings
from app.domain.models.screener_model import ScreenerModel
from app.persistence.deps import get_screener_repo
from app.persistence.repositories.screener_repo import ScreenerRepository

_BUILDER_SESSION_PURPOSE = "builder_session"
_BUILDER_CSRF_PURPOSE = "builder_csrf"


def build_auth_http_exception(
    *,
    status_code: int,
    code: str,
    user_message: str,
    operation: str,
    retryable: bool,
) -> HTTPException:
    return HTTPException(
        status_code=status_code,
        detail={
            "code": code,
            "userMessage": user_message,
            "retryable": retryable,
            "operation": operation,
        },
    )


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _builder_cookie_options() -> dict[str, Any]:
    options: dict[str, Any] = {
        "httponly": True,
        "secure": settings.is_production,
        "samesite": "lax",
        "path": "/",
        "max_age": settings.builder_session_expire_minutes * 60,
    }
    if settings.builder_cookie_domain:
        options["domain"] = settings.builder_cookie_domain
    return options


def create_builder_session_token(
    screener_id: str,
    expires_delta: timedelta | None = None,
) -> str:
    expiry = _utcnow() + (
        expires_delta or timedelta(minutes=settings.builder_session_expire_minutes)
    )
    return jwt.encode(
        {
            "sub": screener_id,
            "purpose": _BUILDER_SESSION_PURPOSE,
            "exp": expiry,
        },
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )


def create_builder_csrf_token(
    screener_id: str,
    expires_delta: timedelta | None = None,
) -> str:
    expiry = _utcnow() + (
        expires_delta or timedelta(minutes=settings.builder_session_expire_minutes)
    )
    return jwt.encode(
        {
            "sub": screener_id,
            "purpose": _BUILDER_CSRF_PURPOSE,
            "exp": expiry,
        },
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )


def set_builder_auth_cookies(
    response: Response,
    *,
    session_token: str,
    csrf_token: str,
) -> None:
    cookie_options = _builder_cookie_options()
    response.set_cookie(
        key=settings.builder_session_cookie_name,
        value=session_token,
        **cookie_options,
    )
    response.set_cookie(
        key=settings.builder_csrf_cookie_name,
        value=csrf_token,
        **cookie_options,
    )


def clear_builder_auth_cookies(response: Response) -> None:
    delete_options = {"path": "/"}
    if settings.builder_cookie_domain:
        delete_options["domain"] = settings.builder_cookie_domain
    response.delete_cookie(settings.builder_session_cookie_name, **delete_options)
    response.delete_cookie(settings.builder_csrf_cookie_name, **delete_options)


def _decode_token(
    token: str,
    *,
    purpose: str,
    operation: str,
    expired_code: str,
    invalid_code: str,
    expired_message: str,
    invalid_message: str,
    status_code: int,
) -> dict[str, Any]:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except jwt.ExpiredSignatureError as exc:
        raise build_auth_http_exception(
            status_code=status_code,
            code=expired_code,
            user_message=expired_message,
            operation=operation,
            retryable=True,
        ) from exc
    except jwt.PyJWTError as exc:
        raise build_auth_http_exception(
            status_code=status_code,
            code=invalid_code,
            user_message=invalid_message,
            operation=operation,
            retryable=True,
        ) from exc

    if payload.get("purpose") != purpose or not payload.get("sub"):
        raise build_auth_http_exception(
            status_code=status_code,
            code=invalid_code,
            user_message=invalid_message,
            operation=operation,
            retryable=True,
        )
    return payload


def _decode_builder_session_cookie(token: str) -> str:
    payload = _decode_token(
        token,
        purpose=_BUILDER_SESSION_PURPOSE,
        operation="builder_session",
        expired_code="BUILDER_SESSION_EXPIRED",
        invalid_code="BUILDER_SESSION_INVALID",
        expired_message="Sua sessão administrativa expirou. Faça login novamente.",
        invalid_message="Sua sessão administrativa não é mais válida. Faça login novamente.",
        status_code=status.HTTP_401_UNAUTHORIZED,
    )
    return str(payload["sub"])


def _validate_builder_csrf_token(token: str, screener_id: str) -> None:
    payload = _decode_token(
        token,
        purpose=_BUILDER_CSRF_PURPOSE,
        operation="builder_write",
        expired_code="BUILDER_CSRF_INVALID",
        invalid_code="BUILDER_CSRF_INVALID",
        expired_message="Atualize a sessão do construtor antes de salvar alterações.",
        invalid_message="Atualize a sessão do construtor antes de salvar alterações.",
        status_code=status.HTTP_403_FORBIDDEN,
    )
    if str(payload["sub"]) != screener_id:
        raise build_auth_http_exception(
            status_code=status.HTTP_403_FORBIDDEN,
            code="BUILDER_CSRF_INVALID",
            user_message="Atualize a sessão do construtor antes de salvar alterações.",
            operation="builder_write",
            retryable=True,
        )


def get_authenticated_builder_session(
    request: Request,
    repo: ScreenerRepository = Depends(get_screener_repo),
) -> ScreenerModel:
    session_cookie = request.cookies.get(settings.builder_session_cookie_name)
    if not session_cookie:
        raise build_auth_http_exception(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="BUILDER_LOGIN_REQUIRED",
            user_message="Faça login para acessar o construtor administrativo.",
            operation="builder_session",
            retryable=True,
        )

    screener_id = _decode_builder_session_cookie(session_cookie)
    screener = repo.find_by_id(screener_id)
    if not screener or not screener.id:
        raise build_auth_http_exception(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="BUILDER_SESSION_INVALID",
            user_message="Sua sessão administrativa não é mais válida. Faça login novamente.",
            operation="builder_session",
            retryable=True,
        )
    return screener


def require_builder_admin(
    screener: ScreenerModel = Depends(get_authenticated_builder_session),
) -> ScreenerModel:
    if not screener.isBuilderAdmin:
        raise build_auth_http_exception(
            status_code=status.HTTP_403_FORBIDDEN,
            code="BUILDER_ADMIN_REVOKED",
            user_message="Sua conta não tem mais acesso administrativo ao construtor.",
            operation="builder_session",
            retryable=False,
        )
    return screener


def require_builder_csrf(
    request: Request,
    screener: ScreenerModel = Depends(require_builder_admin),
) -> ScreenerModel:
    csrf_cookie = request.cookies.get(settings.builder_csrf_cookie_name)
    csrf_header = request.headers.get(settings.builder_csrf_header_name)
    if not csrf_cookie or not csrf_header or csrf_cookie != csrf_header:
        raise build_auth_http_exception(
            status_code=status.HTTP_403_FORBIDDEN,
            code="BUILDER_CSRF_INVALID",
            user_message="Atualize a sessão do construtor antes de salvar alterações.",
            operation="builder_write",
            retryable=True,
        )

    _validate_builder_csrf_token(csrf_header, screener.id or "")
    return screener
