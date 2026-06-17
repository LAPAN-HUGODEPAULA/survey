"""Bearer-token screener authentication and role-based authorization dependencies."""

from __future__ import annotations

from typing import Optional

import jwt
from fastapi import Depends, Header, status

from app.api.dependencies.builder_auth import build_auth_http_exception
from app.config.settings import settings
from app.domain.models.screener_model import ScreenerModel
from app.persistence.deps import get_screener_repo
from app.persistence.repositories.screener_repo import ScreenerRepository


def require_screener(
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
    repo: ScreenerRepository = Depends(get_screener_repo),
) -> ScreenerModel:
    """Validate a Bearer JWT and resolve the authenticated screener.

    Extracts the ``sub`` claim (email), looks up the screener in MongoDB, and
    returns the domain model.  Raises 401 on missing/invalid/expired tokens or
    unknown screener accounts.
    """
    if not authorization:
        raise build_auth_http_exception(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="SCREENER_AUTH_REQUIRED",
            user_message="Autenticação necessária.",
            operation="screener_auth",
            retryable=True,
        )

    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise build_auth_http_exception(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="SCREENER_AUTH_INVALID_SCHEME",
            user_message="Esquema de autenticação inválido.",
            operation="screener_auth",
            retryable=True,
        )

    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except jwt.ExpiredSignatureError as exc:
        raise build_auth_http_exception(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="SCREENER_TOKEN_EXPIRED",
            user_message="Sua sessão expirou. Faça login novamente.",
            operation="screener_auth",
            retryable=True,
        ) from exc
    except jwt.PyJWTError as exc:
        raise build_auth_http_exception(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="SCREENER_TOKEN_INVALID",
            user_message="Token inválido.",
            operation="screener_auth",
            retryable=True,
        ) from exc

    subject = payload.get("sub")
    if not subject:
        raise build_auth_http_exception(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="SCREENER_TOKEN_INVALID",
            user_message="Token sem identificação.",
            operation="screener_auth",
            retryable=True,
        )

    screener = repo.find_by_email(subject)
    if not screener or not screener.id:
        raise build_auth_http_exception(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="SCREENER_NOT_FOUND",
            user_message="Screener não encontrado.",
            operation="screener_auth",
            retryable=True,
        )

    return screener


def require_template_admin(
    screener: ScreenerModel = Depends(require_screener),
) -> ScreenerModel:
    """Require the authenticated screener to hold builder-admin privileges.

    This replaces the legacy ``settings.template_admin_emails`` allow-list
    with the database-level ``isBuilderAdmin`` flag on the screener record.
    """
    if not screener.isBuilderAdmin:
        raise build_auth_http_exception(
            status_code=status.HTTP_403_FORBIDDEN,
            code="TEMPLATE_ADMIN_REVOKED",
            user_message="Sua conta não tem acesso administrativo a modelos de documento.",
            operation="template_admin",
            retryable=False,
        )
    return screener
