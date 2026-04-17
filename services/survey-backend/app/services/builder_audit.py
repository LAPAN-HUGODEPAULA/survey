"""Service for managing builder audit records with synchronization to security audit."""

import asyncio
import hashlib
from typing import Optional

from app.config.logging_config import logger
from app.domain.models.audit_models import (
    ActorInfo,
    BuilderAuditCreate,
    BuilderAuditLog,
    ResourceInfo
)
from app.domain.models.privacy_models import SecurityAuditLog
from app.persistence.repositories.builder_audit_repo import BuilderAuditRepository
from app.persistence.repositories.security_audit_repo import SecurityAuditRepository
from app.services.security_audit import SecurityAuditService


class BuilderAuditService:
    """Service for recording builder audit events with security synchronization."""

    def __init__(
        self,
        builder_repo: BuilderAuditRepository,
        security_repo: SecurityAuditRepository,
        security_service: SecurityAuditService
    ):
        self._builder_repo = builder_repo
        self._security_repo = security_repo
        self._security_service = security_service

    async def record_event(
        self,
        correlation_id: str,
        event_type: str,
        actor: ActorInfo,
        operation: str,
        status: str,
        resource: ResourceInfo,
        outcome: dict,
        payload: Optional[dict] = None
    ) -> BuilderAuditLog:
        """Record a builder audit event and synchronize with security audit."""

        # Create builder audit record
        audit_create = BuilderAuditCreate(
            correlation_id=correlation_id,
            event_type=event_type,
            actor=actor,
            operation=operation,
            status=status,
            resource=resource,
            outcome=outcome
        )

        if payload:
            audit_create.payload = payload

        # Write to builder collection
        builder_record = await self._builder_repo.create(audit_create.model_dump(by_alias=True))

        # Synchronize with security audit for platform visibility
        await self._security_service.record_event(
            event_type=f"builder_{operation}",
            actor=actor.model_dump(),
            target=resource.model_dump(),
            payload={
                "correlationId": correlation_id,
                "namespace": "builder",
                "operation": operation,
                "status": status,
                "outcome": outcome
            }
        )

        logger.info(
            "Recorded builder audit event: %s for %s (%s)",
            operation,
            actor.email,
            correlation_id
        )

        return builder_record

    async def record_survey_operation(
        self,
        correlation_id: str,
        actor: ActorInfo,
        operation: str,
        status: str,
        survey_id: str,
        version: datetime,
        display_name: str,
        payload: Optional[dict] = None
    ) -> BuilderAuditLog:
        """Record a survey-related audit operation."""

        resource = ResourceInfo(
            type="survey",
            id=survey_id,
            name=display_name
        )

        outcome = {
            "survey_id": survey_id,
            "version": version,
            "display_name": display_name
        }

        return await self.record_event(
            correlation_id=correlation_id,
            event_type=f"builder_{operation}_survey",
            actor=actor,
            operation=operation,
            status=status,
            resource=resource,
            outcome=outcome,
            payload=payload
        )

    async def record_prompt_operation(
        self,
        correlation_id: str,
        actor: ActorInfo,
        operation: str,
        status: str,
        prompt_key: str,
        name: str,
        prompt_text: str,
        version: datetime,
        payload: Optional[dict] = None
    ) -> BuilderAuditLog:
        """Record a prompt-related audit operation with content digest."""

        # Calculate content digest for tracking
        content_digest = hashlib.sha256(prompt_text.encode('utf-8')).hexdigest()

        resource = ResourceInfo(
            type="prompt",
            key=prompt_key,
            name=name
        )

        outcome = {
            "prompt_key": prompt_key,
            "name": name,
            "content_digest": content_digest,
            "version": version,
            "word_count": len(prompt_text.split())
        }

        return await self.record_event(
            correlation_id=correlation_id,
            event_type=f"builder_{operation}_prompt",
            actor=actor,
            operation=operation,
            status=status,
            resource=resource,
            outcome=outcome,
            payload=payload
        )

    async def record_auth_operation(
        self,
        correlation_id: str,
        email: str,
        operation: str,
        status: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        failure_reason: Optional[str] = None,
        session_duration: Optional[int] = None,
        payload: Optional[dict] = None
    ) -> BuilderAuditLog:
        """Record an authentication-related audit operation."""

        actor = ActorInfo(id="", email=email)  # ID might not be available for auth failures

        resource = ResourceInfo(
            type="authentication",
            name=f"Builder auth - {email}"
        )

        outcome = {
            "email": email,
            "ip_address": ip_address,
            "user_agent": user_agent,
            "success": status == "success",
            "failure_reason": failure_reason,
            "session_duration": session_duration
        }

        return await self.record_event(
            correlation_id=correlation_id,
            event_type=f"builder_{operation}_auth",
            actor=actor,
            operation=operation,
            status=status,
            resource=resource,
            outcome=outcome,
            payload=payload
        )

    async def initialize(self) -> None:
        """Initialize audit repository indexes."""
        await self._builder_repo.initialize_indexes()

    async def get_correlation_trace(self, correlation_id: str) -> dict:
        """Get full trace for a correlation ID across both collections."""
        # Get builder records
        builder_records = await self._builder_repo.list_by_correlation_id(correlation_id)

        # Format for easy consumption
        trace = {
            "correlation_id": correlation_id,
            "builder_events": [
                {
                    "timestamp": record.created_at,
                    "operation": record.operation,
                    "status": record.status,
                    "actor": record.actor.model_dump(),
                    "resource": record.resource.model_dump(),
                    "outcome": record.outcome
                }
                for record in builder_records
            ],
            "security_events": []  # Could be extended to query security audit
        }

        return trace