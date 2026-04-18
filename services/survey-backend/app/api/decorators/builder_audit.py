"""Best-effort decorators for builder authentication and admin audit events."""

from __future__ import annotations

import functools
from collections.abc import Callable
from typing import Any

from fastapi import HTTPException, Request

from app.config.logging_config import logger
from app.domain.models.audit_models import ActorInfo, ResourceInfo
from app.persistence.mongo.client import get_db
from app.persistence.repositories.builder_audit_repo import BuilderAuditRepository
from app.persistence.repositories.security_audit_repo import SecurityAuditRepository
from app.services.builder_audit import BuilderAuditService
from app.services.security_audit import SecurityAuditService


def _build_audit_service() -> BuilderAuditService:
    db = get_db()
    security_repo = SecurityAuditRepository(db)
    return BuilderAuditService(
        builder_repo=BuilderAuditRepository(db),
        security_repo=security_repo,
        security_service=SecurityAuditService(security_repo),
    )


def _extract_failure_reason(error: Exception) -> str:
    if isinstance(error, HTTPException):
        detail = error.detail
        if isinstance(detail, dict):
            return str(detail.get("userMessage") or detail.get("code") or detail)
        return str(detail)
    return str(error)


def _request_client_ip(request: Request | None) -> str | None:
    if not request or not request.client:
        return None
    return request.client.host


def _request_user_agent(request: Request | None) -> str | None:
    if not request:
        return None
    return request.headers.get("user-agent")


def _auth_email(kwargs: dict[str, Any], result: Any = None) -> str:
    payload = kwargs.get("payload")
    if payload is not None and getattr(payload, "email", None):
        return str(payload.email)

    screener = kwargs.get("screener")
    if screener is not None and getattr(screener, "email", None):
        return str(screener.email)

    profile = getattr(result, "profile", None)
    if profile is not None and getattr(profile, "email", None):
        return str(profile.email)

    return ""


def _record_auth_event(
    *,
    operation_type: str,
    status: str,
    kwargs: dict[str, Any],
    result: Any = None,
    error: Exception | None = None,
) -> None:
    request = kwargs.get("request")
    correlation_id = kwargs.get("correlation_id") or getattr(
        getattr(request, "state", None),
        "correlation_id",
        "unknown",
    )

    try:
        _build_audit_service().record_auth_operation(
            correlation_id=correlation_id or "unknown",
            email=_auth_email(kwargs, result),
            operation=operation_type,
            status=status,
            ip_address=_request_client_ip(request),
            user_agent=_request_user_agent(request),
            failure_reason=_extract_failure_reason(error) if error else None,
        )
    except Exception as audit_error:
        logger.warning("Builder auth audit logging failed: %s", audit_error)


def audit_auth_operation(operation_type: str) -> Callable:
    """Audit authentication endpoints without changing their response semantics."""

    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            try:
                result = await func(*args, **kwargs)
            except Exception as error:
                _record_auth_event(
                    operation_type=operation_type,
                    status="failed",
                    kwargs=kwargs,
                    error=error,
                )
                raise

            _record_auth_event(
                operation_type=operation_type,
                status="success",
                kwargs=kwargs,
                result=result,
            )
            return result

        return wrapper

    return decorator


def _resource_from_kwargs(operation_type: str, kwargs: dict[str, Any]) -> ResourceInfo:
    if "prompt_key" in kwargs:
        return ResourceInfo(type="prompt", key=str(kwargs["prompt_key"]))
    if "persona_skill_key" in kwargs:
        return ResourceInfo(type="persona_skill", key=str(kwargs["persona_skill_key"]))
    if "access_point_key" in kwargs:
        return ResourceInfo(type="agent_access_point", key=str(kwargs["access_point_key"]))
    if "survey_id" in kwargs:
        return ResourceInfo(type="survey", id=str(kwargs["survey_id"]))
    return ResourceInfo(type="builder_operation", name=operation_type)


def audit_builder_operation(operation_type: str) -> Callable:
    """Audit non-auth builder operations on a best-effort basis."""

    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            request = kwargs.get("request")
            correlation_id = kwargs.get("correlation_id") or getattr(
                getattr(request, "state", None),
                "correlation_id",
                "unknown",
            )
            screener = kwargs.get("screener")
            actor = ActorInfo(
                id=str(getattr(screener, "id", "") or ""),
                email=str(getattr(screener, "email", "") or ""),
            )
            resource = _resource_from_kwargs(operation_type, kwargs)

            try:
                result = await func(*args, **kwargs)
            except Exception as error:
                try:
                    _build_audit_service().record_event(
                        correlation_id=correlation_id or "unknown",
                        event_type=f"builder_{operation_type}",
                        actor=actor,
                        operation=operation_type,
                        status="failed",
                        resource=resource,
                        outcome={"error": _extract_failure_reason(error)},
                    )
                except Exception as audit_error:
                    logger.warning("Builder audit logging failed: %s", audit_error)
                raise

            try:
                _build_audit_service().record_event(
                    correlation_id=correlation_id or "unknown",
                    event_type=f"builder_{operation_type}",
                    actor=actor,
                    operation=operation_type,
                    status="success",
                    resource=resource,
                    outcome={"ok": True},
                )
            except Exception as audit_error:
                logger.warning("Builder audit logging failed: %s", audit_error)
            return result

        return wrapper

    return decorator
