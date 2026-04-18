"""Decorator for auditing failed authorization attempts."""

import functools
from typing import Callable, Optional

from fastapi import Request, HTTPException, status
from starlette.responses import Response

from app.api.dependencies.correlation import CorrelationID
from app.api.dependencies.builder_auth import ScreenerModel
from app.domain.models.audit_models import ActorInfo, ResourceInfo
from app.services.builder_audit import BuilderAuditService


def audit_auth_failure(operation_type: str):
    """
    Decorator to audit authentication/authorization failures.

    This decorator should be wrapped around functions that raise auth exceptions.
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            request = kwargs.get('request')
            correlation_id = getattr(request.state, 'correlation_id', None)

            # Get email from request if available (for login attempts)
            email = ""
            if request.method == "POST" and request.headers.get("content-type", "").startswith("application/json"):
                try:
                    body = await request.body()
                    if body:
                        import json
                        data = json.loads(body.decode())
                        email = data.get("email", "")
                except Exception:
                    pass

            # Create audit record for the failure
            try:
                # Get builder audit service from context or dependency
                # This would typically be injected as a dependency
                await BuilderAuditService.record_event(
                    correlation_id=correlation_id or "unknown",
                    event_type=f"builder_auth_denied",
                    actor=ActorInfo(id="", email=email),
                    operation=f"auth_failure_{operation_type}",
                    status="failed",
                    resource=ResourceInfo(
                        type="authorization",
                        name=f"Builder access denied - {email}"
                    ),
                    outcome={
                        "operation": operation_type,
                        "email": email,
                        "ip_address": request.client.host if request.client else None,
                        "user_agent": request.headers.get("user-agent"),
                        "failure_reason": "Authorization denied"
                    }
                )
            except Exception:
                # Don't fail the original operation if audit fails
                pass

            # Execute the original function (which will raise the exception)
            return await func(*args, **kwargs)

        return wrapper
    return decorator


def create_audited_dependency(dependency_func: Callable, operation_type: str):
    """
    Create a dependency wrapper that audits failures.

    Usage:
        require_builder_admin = create_audited_dependency(
            original_require_builder_admin,
            "builder_admin_required"
        )
    """
    @functools.wraps(dependency_func)
    async def audited_dependency(*args, **kwargs):
        request = kwargs.get('request') if 'request' in kwargs else args[0] if args else None

        if not request:
            # No request context, can't audit
            return await dependency_func(*args, **kwargs)

        correlation_id = getattr(request.state, 'correlation_id', None)

        try:
            # Try the original dependency
            result = await dependency_func(*args, **kwargs)
            return result

        except HTTPException as e:
            # Audit the failure
            await audit_auth_failure_internal(
                correlation_id=correlation_id or "unknown",
                exception=e,
                operation_type=operation_type,
                request=request
            )
            raise

        except Exception as e:
            # Generic failure
            await audit_auth_failure_internal(
                correlation_id=correlation_id or "unknown",
                exception=e,
                operation_type=operation_type,
                request=request
            )
            raise

    return audited_dependency


async def audit_auth_failure_internal(
    correlation_id: str,
    exception: Exception,
    operation_type: str,
    request: Request
) -> None:
    """Internal function to record auth failures."""

    # Extract email from request if possible
    email = ""
    if request.method == "POST" and request.headers.get("content-type", "").startswith("application/json"):
        try:
            body = await request.body()
            if body:
                import json
                data = json.loads(body.decode())
                email = data.get("email", "")
        except Exception:
            pass

    # Create audit record
    await BuilderAuditService.record_event(
        correlation_id=correlation_id,
        event_type="builder_auth_denied",
        actor=ActorInfo(id="", email=email),
        operation=f"auth_failure_{operation_type}",
        status="failed",
        resource=ResourceInfo(
            type="authorization",
            name=f"Builder access denied - {email}"
        ),
        outcome={
            "operation": operation_type,
            "email": email,
            "ip_address": request.client.host if request.client else None,
            "user_agent": request.headers.get("user-agent"),
            "failure_reason": str(exception),
            "status_code": getattr(exception, 'status_code', 500)
        }
    )