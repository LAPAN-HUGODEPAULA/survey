from __future__ import annotations

from datetime import datetime
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, Header, HTTPException, Query, status

from app.config.settings import settings
from app.domain.models.template_models import (
    TemplateAuditRecord,
    TemplateCreateRequest,
    TemplatePreviewRequest,
    TemplatePreviewResponse,
    TemplateRecord,
    TemplateUpdateRequest,
)
from app.persistence.deps import get_template_audit_repo, get_template_repo
from app.persistence.repositories.template_audit_repo import TemplateAuditRepository
from app.persistence.repositories.template_repo import TemplateRepository
from app.services.document_generation import render_html
from app.services.template_service import (
    SUPPORTED_DOCUMENT_TYPES,
    bump_patch,
    merge_placeholders,
    normalize_document_type,
    render_template,
    validate_conditions,
)

router = APIRouter()


def _get_email_from_authorization_header(authorization: Optional[str]) -> str:
    if not authorization:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authentication scheme")
    # Token is used in screener routes; here we trust it for identity only.
    import jwt

    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except jwt.PyJWTError as exc:  # pragma: no cover - defensive
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc
    email = payload.get("sub")
    if not email:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
    return email


def _is_admin(email: str) -> bool:
    return email in settings.template_admin_emails


def _record_audit(
    repo: TemplateAuditRepository,
    action: str,
    template: dict | None,
    actor: str | None,
    status_value: str | None = None,
    metadata: dict | None = None,
) -> None:
    payload = TemplateAuditRecord(
        template_id=template.get("_id") if template else None,
        template_group_id=template.get("templateGroupId") if template else None,
        version=template.get("version") if template else None,
        action=action,
        status=status_value or (template.get("status") if template else None),
        actor=actor,
        metadata=metadata or {},
    )
    repo.create(payload.model_dump(by_alias=True, exclude_none=True))


def _require_admin(
    authorization: Optional[str],
    audit_repo: TemplateAuditRepository,
    action: str,
    template: dict | None = None,
) -> str:
    email = _get_email_from_authorization_header(authorization)
    if not _is_admin(email):
        _record_audit(
            audit_repo,
            action="unauthorized",
            template=template or {},
            actor=email,
            status_value="denied",
            metadata={"attemptedAction": action},
        )
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
    return email


@router.get("/templates/document-types")
async def list_document_types() -> list[dict[str, str]]:
    return SUPPORTED_DOCUMENT_TYPES


@router.get("/templates", response_model=list[TemplateRecord])
async def list_templates(
    document_type: Optional[str] = Query(default=None, alias="documentType"),
    query: Optional[str] = Query(default=None, alias="q"),
    include_all: bool = Query(default=False, alias="includeAll"),
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
    repo: TemplateRepository = Depends(get_template_repo),
    audit_repo: TemplateAuditRepository = Depends(get_template_audit_repo),
) -> list[TemplateRecord]:
    template_query: dict = {}
    if document_type:
        template_query["documentType"] = document_type
    if query:
        template_query["name"] = {"$regex": query, "$options": "i"}

    if include_all:
        _require_admin(authorization, audit_repo, action="list_all_templates")
    else:
        template_query["status"] = "active"

    records = repo.list(template_query, sort=[("updatedAt", -1)])
    return [TemplateRecord.model_validate(item) for item in records]


@router.get("/templates/recommendations", response_model=list[TemplateRecord])
async def recommend_templates(
    document_type: Optional[str] = Query(default=None, alias="documentType"),
    repo: TemplateRepository = Depends(get_template_repo),
) -> list[TemplateRecord]:
    template_query: dict = {"status": "active"}
    if document_type:
        template_query["documentType"] = document_type
    records = repo.list(template_query, sort=[("updatedAt", -1)])
    return [TemplateRecord.model_validate(item) for item in records]


@router.get("/templates/{template_id}", response_model=TemplateRecord)
async def get_template(
    template_id: str,
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
    repo: TemplateRepository = Depends(get_template_repo),
    audit_repo: TemplateAuditRepository = Depends(get_template_audit_repo),
) -> TemplateRecord:
    template = repo.get_by_id(template_id)
    if not template:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    if template.get("status") != "active":
        _require_admin(authorization, audit_repo, action="get_template", template=template)
    return TemplateRecord.model_validate(template)


@router.post("/templates", response_model=TemplateRecord, status_code=status.HTTP_201_CREATED)
async def create_template(
    payload: TemplateCreateRequest,
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
    repo: TemplateRepository = Depends(get_template_repo),
    audit_repo: TemplateAuditRepository = Depends(get_template_audit_repo),
) -> TemplateRecord:
    actor = _require_admin(authorization, audit_repo, action="create_template")
    if not payload.body.strip():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Template body is required")
    document_type = normalize_document_type(payload.document_type)
    placeholders = merge_placeholders(payload.body, payload.placeholders)
    conditions = validate_conditions(payload.conditions)

    new_id = ObjectId()
    template = {
        "_id": new_id,
        "templateGroupId": str(new_id),
        "name": payload.name,
        "documentType": document_type,
        "version": "1.0.0",
        "status": "draft",
        "body": payload.body,
        "placeholders": placeholders,
        "conditions": conditions,
        "createdAt": datetime.utcnow(),
        "updatedAt": datetime.utcnow(),
        "createdBy": actor,
        "updatedBy": actor,
    }
    created = repo.create(template)
    _record_audit(audit_repo, "create", created, actor, status_value="draft")
    return TemplateRecord.model_validate(created)


@router.put("/templates/{template_id}", response_model=TemplateRecord)
async def update_template(
    template_id: str,
    payload: TemplateUpdateRequest,
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
    repo: TemplateRepository = Depends(get_template_repo),
    audit_repo: TemplateAuditRepository = Depends(get_template_audit_repo),
) -> TemplateRecord:
    existing = repo.get_by_id(template_id)
    if not existing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    actor = _require_admin(authorization, audit_repo, action="update_template", template=existing)
    if not payload.body.strip():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Template body is required")

    document_type = normalize_document_type(payload.document_type or existing.get("documentType"))
    placeholders = merge_placeholders(payload.body, payload.placeholders)
    conditions = validate_conditions(payload.conditions)
    new_version = bump_patch(existing.get("version") or "1.0.0")

    new_id = ObjectId()
    template = {
        "_id": new_id,
        "templateGroupId": existing.get("templateGroupId") or str(existing.get("_id")),
        "name": payload.name or existing.get("name"),
        "documentType": document_type,
        "version": new_version,
        "status": "draft",
        "body": payload.body,
        "placeholders": placeholders,
        "conditions": conditions,
        "createdAt": datetime.utcnow(),
        "updatedAt": datetime.utcnow(),
        "createdBy": existing.get("createdBy") or actor,
        "updatedBy": actor,
    }
    created = repo.create(template)
    _record_audit(audit_repo, "update", created, actor, status_value="draft")
    return TemplateRecord.model_validate(created)


@router.post("/templates/{template_id}/approve", response_model=TemplateRecord)
async def approve_template(
    template_id: str,
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
    repo: TemplateRepository = Depends(get_template_repo),
    audit_repo: TemplateAuditRepository = Depends(get_template_audit_repo),
) -> TemplateRecord:
    template = repo.get_by_id(template_id)
    if not template:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    actor = _require_admin(authorization, audit_repo, action="approve_template", template=template)

    group_id = template.get("templateGroupId")
    if group_id:
        repo.update_many(
            {"templateGroupId": group_id, "status": "active", "_id": {"$ne": ObjectId(template_id)}},
            {"status": "archived", "updatedBy": actor},
        )
    updated = repo.update(
        template_id,
        {
            "status": "active",
            "approvedAt": datetime.utcnow(),
            "approvedBy": actor,
            "updatedBy": actor,
        },
    )
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    _record_audit(audit_repo, "approve", updated, actor, status_value="active")
    return TemplateRecord.model_validate(updated)


@router.post("/templates/{template_id}/archive", response_model=TemplateRecord)
async def archive_template(
    template_id: str,
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
    repo: TemplateRepository = Depends(get_template_repo),
    audit_repo: TemplateAuditRepository = Depends(get_template_audit_repo),
) -> TemplateRecord:
    template = repo.get_by_id(template_id)
    if not template:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    actor = _require_admin(authorization, audit_repo, action="archive_template", template=template)
    updated = repo.update(
        template_id,
        {"status": "archived", "updatedBy": actor},
    )
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    _record_audit(audit_repo, "archive", updated, actor, status_value="archived")
    return TemplateRecord.model_validate(updated)


@router.post("/templates/{template_id}/preview", response_model=TemplatePreviewResponse)
async def preview_template(
    template_id: str,
    payload: TemplatePreviewRequest,
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
    repo: TemplateRepository = Depends(get_template_repo),
    audit_repo: TemplateAuditRepository = Depends(get_template_audit_repo),
) -> TemplatePreviewResponse:
    template = repo.get_by_id(template_id)
    if not template:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    if template.get("status") != "active":
        _require_admin(authorization, audit_repo, action="preview_template", template=template)

    data = payload.sample_data or {}
    rendered_body, missing = render_template(
        template.get("body", ""),
        template.get("conditions"),
        data,
    )
    title = template.get("name") or "Clinical Template"
    patient_data = data.get("patient") if isinstance(data.get("patient"), dict) else {}
    patient_id = None
    if isinstance(patient_data, dict):
        patient_id = patient_data.get("medicalRecordId") or patient_data.get("id")
    metadata = {
        "templateId": template.get("_id"),
        "templateGroupId": template.get("templateGroupId"),
        "documentType": template.get("documentType"),
        "version": template.get("version"),
        "generatedAt": datetime.utcnow().isoformat(),
        "patientId": patient_id,
        "sessionId": data.get("sessionId"),
    }
    html = render_html(title, rendered_body, metadata)
    return TemplatePreviewResponse(
        html=html,
        title=title,
        body=rendered_body,
        missing_fields=missing,
        metadata=metadata,
    )
