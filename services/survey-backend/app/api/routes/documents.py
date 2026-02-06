from fastapi import APIRouter, Depends, HTTPException

from app.domain.models.document_models import (
    DocumentPreviewRequest,
    DocumentExportRequest,
    DocumentPreview,
    DocumentRecord,
)
from app.persistence.deps import (
    get_chat_session_repo,
    get_chat_message_repo,
    get_document_repo,
)
from app.persistence.repositories.chat_session_repo import ChatSessionRepository
from app.persistence.repositories.chat_message_repo import ChatMessageRepository
from app.persistence.repositories.document_repo import DocumentRepository
from app.services.document_generation import (
    build_body_from_messages,
    build_title,
    build_metadata,
    render_html,
    detect_missing_fields,
    validate_compliance,
)


router = APIRouter()


@router.post("/documents/preview", response_model=DocumentPreview)
def preview_document(
    payload: DocumentPreviewRequest,
    sessions: ChatSessionRepository = Depends(get_chat_session_repo),
    messages: ChatMessageRepository = Depends(get_chat_message_repo),
):
    session = sessions.get_by_id(payload.session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    message_list = messages.list_by_session(payload.session_id)
    title = payload.title or build_title(payload.document_type)
    body = payload.body or build_body_from_messages(message_list)
    metadata = build_metadata(session, payload.document_type)
    html = render_html(title, body, metadata)
    missing_fields = detect_missing_fields(title, body, metadata)
    return DocumentPreview(
        html=html,
        title=title,
        body=body,
        missing_fields=missing_fields,
        metadata=metadata,
    )


@router.post("/documents/export", response_model=DocumentRecord)
def export_document(
    payload: DocumentExportRequest,
    sessions: ChatSessionRepository = Depends(get_chat_session_repo),
    documents: DocumentRepository = Depends(get_document_repo),
):
    session = sessions.get_by_id(payload.session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    validate_compliance(payload.title, payload.body)
    metadata = build_metadata(session, payload.document_type)
    if payload.metadata:
        metadata.update(payload.metadata)
    html = render_html(payload.title, payload.body, metadata)
    record = DocumentRecord(
        session_id=payload.session_id,
        document_type=payload.document_type,
        title=payload.title,
        body=payload.body,
        html=html,
        metadata=metadata,
    )
    created = documents.create(record.model_dump(by_alias=True))
    return DocumentRecord(**created)


@router.get("/documents/{document_id}", response_model=DocumentRecord)
def get_document(
    document_id: str,
    documents: DocumentRepository = Depends(get_document_repo),
):
    found = documents.get_by_id(document_id)
    if not found:
        raise HTTPException(status_code=404, detail="Document not found")
    return DocumentRecord(**found)
