"""Decorator for auditing builder administrative operations."""

import functools
from datetime import datetime
from typing import Any, Callable, Optional

from fastapi import HTTPException, Request, status
from pymongo.errors import DuplicateKeyError

from app.api.dependencies.correlation import CorrelationID
from app.api.dependencies.builder_auth import ScreenerModel
from app.domain.models.audit_models import ActorInfo, ResourceInfo
from app.services.builder_audit import BuilderAuditService
from app.services.audit_privacy import AuditPrivacyService


def audit_builder_operation(operation_type: str):
    """
    Decorator to audit builder administrative operations.

    Args:
        operation_type: The specific operation being performed (e.g., "create_survey")
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs) -> Any:
            # Extract dependencies
            request = kwargs.get('request')
            screener = kwargs.get('screener')
            correlation_id = kwargs.get('correlation_id', getattr(request.state, 'correlation_id', None))

            if not correlation_id:
                raise ValueError("Correlation ID is required for audit logging")

            # Initialize audit context
            audit_context = {
                "correlation_id": correlation_id,
                "operation": operation_type,
                "timestamp": datetime.utcnow(),
                "actor": ActorInfo(id=screener.id, email=screener.email),
                "resource": extract_resource_info(kwargs, operation_type),
                "status": "success"
            }

            try:
                # Execute the operation
                result = await func(*args, **kwargs)

                # Update audit context with success
                audit_context.update({
                    "status": "success",
                    "outcome": extract_outcome(result, operation_type),
                    "payload": extract_request_payload(kwargs, operation_type)
                })

            except Exception as e:
                # Update audit context with failure
                audit_context.update({
                    "status": "failed",
                    "error": {
                        "type": type(e).__name__,
                        "message": str(e)
                    },
                    "payload": extract_request_payload(kwargs, operation_type)
                })

                # Re-raise the exception
                raise

            # Write audit record (fire-and-forget)
            try:
                await audit_context.get("builder_audit_service").record_event(
                    correlation_id=correlation_id,
                    event_type=f"builder_{operation_type}",
                    actor=audit_context["actor"],
                    operation=operation_type,
                    status=audit_context["status"],
                    resource=audit_context["resource"],
                    outcome=audit_context.get("outcome", {}),
                    payload=audit_context.get("payload")
                )
            except Exception as audit_error:
                # Don't fail the original operation if audit fails
                # Log the error but continue
                audit_context["builder_audit_service"].logger.error(
                    "Failed to record audit event: %s", audit_error
                )

            return result

        return wrapper
    return decorator


def extract_resource_info(kwargs: dict, operation_type: str) -> ResourceInfo:
    """Extract resource information from request parameters."""
    if "survey_id" in kwargs:
        return ResourceInfo(
            type="survey",
            id=kwargs["survey_id"]
        )
    elif "prompt_key" in kwargs:
        return ResourceInfo(
            type="prompt",
            key=kwargs["prompt_key"]
        )
    elif "persona_skill_key" in kwargs:
        return ResourceInfo(
            type="persona_skill",
            key=kwargs["persona_skill_key"]
        )
    elif "access_point_key" in kwargs:
        return ResourceInfo(
            type="agent_access_point",
            key=kwargs["access_point_key"]
        )
    else:
        # Generic resource type
        return ResourceInfo(type="unknown")


def extract_outcome(result: Any, operation_type: str) -> dict:
    """Extract outcome data from operation result."""
    outcome = {}

    if operation_type.startswith(("create_", "update_", "delete_")):
        # Handle common operations
        if hasattr(result, 'id'):
            outcome["id"] = str(result.id)
        if hasattr(result, 'modified_at'):
            outcome["version"] = result.modified_at
        if hasattr(result, 'created_at'):
            outcome["version"] = result.created_at

        # Type-specific outcomes
        if operation_type.endswith("_survey") and hasattr(result, 'survey_display_name'):
            outcome["survey_id"] = str(result.id)
            outcome["display_name"] = result.survey_display_name
        elif operation_type.endswith("_prompt") and hasattr(result, 'prompt_key'):
            outcome["prompt_key"] = result.prompt_key
            outcome["name"] = result.name
            if hasattr(result, 'prompt_text'):
                # Privacy: don't store full text, just digest
                from app.services.audit_privacy import AuditPrivacyService
                outcome["content_digest"] = AuditPrivacyService.compute_content_digest(
                    result.prompt_text
                )
                outcome["word_count"] = len(result.prompt_text.split())

    return outcome


def extract_request_payload(kwargs: dict, operation_type: str) -> Optional[dict]:
    """Extract sanitized request payload for audit."""
    if operation_type == "login":
        # Extract only email for login attempts
        return {"email": kwargs.get("payload", {}).get("email")}

    # For other operations, sanitize the request body
    request_body = kwargs.get("payload", kwargs.get("data"))
    if not request_body:
        return None

    # Apply privacy rules based on operation type
    if operation_type.endswith("_prompt"):
        from app.services.audit_privacy import AuditPrivacyService
        sanitized = AuditPrivacyService.minimize_outcome_data(
            request_body, "prompts"
        )
        return sanitized if sanitized else None

    # For simplicity, just include basic info
    return {
        "timestamp": datetime.utcnow().isoformat(),
        "operation": operation_type
    }


# Helper decorator for authentication operations
def audit_auth_operation(operation_type: str):
    """Specialized decorator for authentication operations."""
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs) -> Any:
            request = kwargs.get('request')
            correlation_id = getattr(request.state, 'correlation_id', None)

            if not correlation_id:
                raise ValueError("Correlation ID is required for audit logging")

            # Extract auth details
            email = kwargs.get("payload", {}).get("email") if operation_type == "login" else ""
            ip_address = request.client.host if request.client else None
            user_agent = request.headers.get("user-agent")

            # Get screener if available (only for successful auth)
            screener = kwargs.get('screener')
            actor = ActorInfo(id="", email=email)  # ID might not be available for failed auth
            if screener and operation_type == "login":
                actor = ActorInfo(id=screener.id, email=screener.email)

            try:
                result = await func(*args, **kwargs)

                # Record successful auth
                await record_auth_audit(
                    correlation_id=correlation_id,
                    event_type=f"builder_{operation_type}_auth",
                    actor=actor,
                    operation=operation_type,
                    status="success",
                    resource=ResourceInfo(
                        type="authentication",
                        name=f"Builder {operation_type} - {email}"
                    ),
                    outcome={
                        "email": email,
                        "ip_address": ip_address,
                        "user_agent": user_agent,
                        "success": True
                    }
                )

                return result

            except (HTTPException, Exception) as e:
                # Record failed auth
                await record_auth_audit(
                    correlation_id=correlation_id,
                    event_type=f"builder_{operation_type}_auth",
                    actor=actor,
                    operation=operation_type,
                    status="failed",
                    resource=ResourceInfo(
                        type="authentication",
                        name=f"Builder {operation_type} - {email}"
                    ),
                    outcome={
                        "email": email,
                        "ip_address": ip_address,
                        "user_agent": user_agent,
                        "success": False,
                        "failure_reason": str(e)
                    }
                )

                raise

        return wrapper
    return decorator


async def record_auth_audit(**audit_data) -> None:
    """Helper function to record authentication audit events."""
    # This would be called by the auth decorator
    # Implementation similar to the main audit service
    pass