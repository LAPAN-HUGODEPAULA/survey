from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, Header, HTTPException, Request, status

from app.config.settings import settings
from app.domain.models.privacy_models import (
    DataLifecycleJob,
    PrivacyRequest,
    PrivacyRequestCreate,
    PrivacyRequestUpdate,
)
from app.persistence.deps import (
    get_data_lifecycle_repo,
    get_privacy_request_repo,
    get_security_audit_repo,
)
from app.persistence.repositories.data_lifecycle_repo import DataLifecycleRepository
from app.persistence.repositories.privacy_request_repo import PrivacyRequestRepository
from app.persistence.repositories.security_audit_repo import SecurityAuditRepository
from app.services.security_audit import SecurityAuditService


router = APIRouter()


def _assert_privacy_admin(
    token: Optional[str],
    audit_repo: SecurityAuditRepository,
    request: Request,
) -> None:
    if not token:
        _record_admin_failure(audit_repo, request)
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    if token != settings.privacy_admin_token:
        _record_admin_failure(audit_repo, request)
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Invalid admin token")


def _record_admin_failure(audit_repo: SecurityAuditRepository, request: Request) -> None:
    audit = SecurityAuditService(audit_repo)
    audit.record_event(
        "admin_auth_failed",
        actor={"source": "privacy_admin_header"},
        target={"path": request.url.path},
        payload={"ip": request.client.host if request.client else None},
    )


def _create_lifecycle_job(
    repo: DataLifecycleRepository,
    request_record: dict,
    action: str,
) -> DataLifecycleJob:
    job_payload = {
        "requestId": request_record["_id"],
        "action": action,
        "subjectType": request_record.get("subjectType"),
        "subjectId": request_record.get("subjectId"),
        "status": "queued",
        "metadata": request_record.get("metadata"),
    }
    created = repo.create(job_payload)
    return DataLifecycleJob.model_validate(created)


@router.post("/privacy/requests", response_model=PrivacyRequest, status_code=status.HTTP_201_CREATED)
async def create_privacy_request(
    payload: PrivacyRequestCreate,
    request: Request,
    repo: PrivacyRequestRepository = Depends(get_privacy_request_repo),
    audit_repo: SecurityAuditRepository = Depends(get_security_audit_repo),
):
    created = repo.create(payload.model_dump(by_alias=True))
    audit = SecurityAuditService(audit_repo)
    audit.record_event(
        "privacy_request_created",
        actor={"email": payload.requester_email},
        target={"requestId": created.get("_id")},
        payload={"requestType": payload.request_type, "subjectType": payload.subject_type},
    )
    return PrivacyRequest.model_validate(created)


@router.get("/privacy/requests", response_model=list[PrivacyRequest])
async def list_privacy_requests(
    request: Request,
    status: Optional[str] = None,
    admin_token: Optional[str] = Header(default=None, alias="X-Privacy-Admin-Token"),
    repo: PrivacyRequestRepository = Depends(get_privacy_request_repo),
    audit_repo: SecurityAuditRepository = Depends(get_security_audit_repo),
):
    _assert_privacy_admin(admin_token, audit_repo, request)
    items = repo.list_all(status=status)
    return [PrivacyRequest.model_validate(item) for item in items]


@router.get("/privacy/requests/{request_id}", response_model=PrivacyRequest)
async def get_privacy_request(
    request_id: str,
    request: Request,
    admin_token: Optional[str] = Header(default=None, alias="X-Privacy-Admin-Token"),
    repo: PrivacyRequestRepository = Depends(get_privacy_request_repo),
    audit_repo: SecurityAuditRepository = Depends(get_security_audit_repo),
):
    _assert_privacy_admin(admin_token, audit_repo, request)
    found = repo.get_by_id(request_id)
    if not found:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Privacy request not found")
    return PrivacyRequest.model_validate(found)


@router.patch("/privacy/requests/{request_id}", response_model=PrivacyRequest)
async def update_privacy_request(
    request_id: str,
    payload: PrivacyRequestUpdate,
    request: Request,
    admin_token: Optional[str] = Header(default=None, alias="X-Privacy-Admin-Token"),
    repo: PrivacyRequestRepository = Depends(get_privacy_request_repo),
    audit_repo: SecurityAuditRepository = Depends(get_security_audit_repo),
    lifecycle_repo: DataLifecycleRepository = Depends(get_data_lifecycle_repo),
):
    _assert_privacy_admin(admin_token, audit_repo, request)
    updates = payload.model_dump(by_alias=True, exclude_unset=True)
    if updates.get("status") == "fulfilled":
        updates["fulfilledAt"] = datetime.utcnow()
    updated = repo.update(request_id, updates)
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Privacy request not found")

    lifecycle_action = None
    request_type = updated.get("requestType")
    if updates.get("status") == "fulfilled":
        if request_type == "deletion":
            lifecycle_action = "delete"
        elif request_type == "anonymization":
            lifecycle_action = "anonymize"
        elif request_type == "consent_revocation":
            lifecycle_action = "revoke_consent"
        elif request_type == "access":
            lifecycle_action = "export"

    if lifecycle_action:
        _create_lifecycle_job(lifecycle_repo, updated, lifecycle_action)

    audit = SecurityAuditService(audit_repo)
    audit.record_event(
        "privacy_request_updated",
        actor={"admin": True, "token": "present"},
        target={"requestId": updated.get("_id")},
        payload={"status": updated.get("status"), "requestType": request_type},
    )

    return PrivacyRequest.model_validate(updated)
