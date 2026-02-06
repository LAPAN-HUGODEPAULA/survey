from datetime import datetime
from typing import Optional, Dict, Any

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.api.ws.chat_manager import chat_manager
from app.domain.models.chat_message_model import ChatMessage
from app.persistence.deps import get_chat_message_repo
from app.persistence.repositories.chat_message_repo import ChatMessageRepository


router = APIRouter()


class ChatMessageCreate(BaseModel):
    role: str
    message_type: str = Field(..., alias="messageType")
    content: str
    metadata: Optional[Dict[str, Any]] = None

    model_config = {"populate_by_name": True, "extra": "forbid"}


class ChatMessageUpdate(BaseModel):
    content: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None

    model_config = {"populate_by_name": True, "extra": "forbid"}


@router.post("/chat/sessions/{session_id}/messages", response_model=ChatMessage)
async def create_message(
    session_id: str,
    payload: ChatMessageCreate,
    repo: ChatMessageRepository = Depends(get_chat_message_repo),
):
    message = ChatMessage(
        session_id=session_id,
        role=payload.role,
        message_type=payload.message_type,
        content=payload.content,
        metadata=payload.metadata,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    created = repo.create(message.model_dump(by_alias=True))
    chat_message = ChatMessage(**created)
    await chat_manager.broadcast(
        session_id,
        {"type": "message_created", "message": chat_message.model_dump(by_alias=True)},
    )
    return chat_message


@router.get("/chat/sessions/{session_id}/messages", response_model=list[ChatMessage])
def list_messages(
    session_id: str,
    repo: ChatMessageRepository = Depends(get_chat_message_repo),
):
    messages = repo.list_by_session(session_id)
    return [ChatMessage(**msg) for msg in messages]


@router.patch("/chat/messages/{message_id}", response_model=ChatMessage)
async def update_message(
    message_id: str,
    payload: ChatMessageUpdate,
    repo: ChatMessageRepository = Depends(get_chat_message_repo),
):
    existing = repo.get_by_id(message_id)
    if not existing:
        raise HTTPException(status_code=404, detail="Message not found")
    edits = existing.get("editHistory") or []
    if payload.content is not None and payload.content != existing.get("content"):
        edits.append(
            {
                "content": existing.get("content"),
                "editedAt": datetime.utcnow().isoformat(),
            }
        )
    updates = payload.model_dump(by_alias=True, exclude_unset=True)
    if edits:
        updates["editHistory"] = edits
    updated = repo.update(message_id, updates)
    if not updated:
        raise HTTPException(status_code=404, detail="Message not found")
    chat_message = ChatMessage(**updated)
    await chat_manager.broadcast(
        chat_message.session_id,
        {"type": "message_updated", "message": chat_message.model_dump(by_alias=True)},
    )
    return chat_message


@router.delete("/chat/messages/{message_id}", response_model=ChatMessage)
async def delete_message(
    message_id: str,
    repo: ChatMessageRepository = Depends(get_chat_message_repo),
):
    deleted = repo.soft_delete(message_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Message not found")
    chat_message = ChatMessage(**deleted)
    await chat_manager.broadcast(
        chat_message.session_id,
        {"type": "message_deleted", "message": chat_message.model_dump(by_alias=True)},
    )
    return chat_message
