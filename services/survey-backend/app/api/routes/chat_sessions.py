from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel, Field

from app.api.ws.chat_manager import chat_manager
from app.domain.models.chat_session_model import ChatSession
from app.persistence.deps import get_chat_session_repo
from app.persistence.repositories.chat_session_repo import ChatSessionRepository


router = APIRouter()


class ChatSessionCreate(BaseModel):
    patient_id: Optional[str] = Field(default=None, alias="patientId")
    phase: Optional[str] = None
    metadata: Optional[dict] = None

    model_config = {"populate_by_name": True, "extra": "forbid"}


class ChatSessionUpdate(BaseModel):
    status: Optional[str] = None
    phase: Optional[str] = None
    metadata: Optional[dict] = None

    model_config = {"populate_by_name": True, "extra": "forbid"}


@router.post("/chat/sessions", response_model=ChatSession)
async def create_session(
    payload: ChatSessionCreate,
    repo: ChatSessionRepository = Depends(get_chat_session_repo),
):
    session = ChatSession(
        patient_id=payload.patient_id,
        phase=payload.phase or "intake",
        status="active",
        metadata=payload.metadata,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    created = repo.create(session.model_dump(by_alias=True))
    chat_session = ChatSession(**created)
    await chat_manager.broadcast(
        chat_session.id,
        {"type": "session_created", "session": chat_session.model_dump(by_alias=True)},
    )
    return chat_session


@router.get("/chat/sessions", response_model=list[ChatSession])
def list_sessions(
    status: Optional[str] = None,
    repo: ChatSessionRepository = Depends(get_chat_session_repo),
):
    sessions = repo.list_by_status(status=status)
    return [ChatSession(**session) for session in sessions]


@router.get("/chat/sessions/{session_id}", response_model=ChatSession)
def get_session(
    session_id: str,
    repo: ChatSessionRepository = Depends(get_chat_session_repo),
):
    found = repo.get_by_id(session_id)
    if not found:
        raise HTTPException(status_code=404, detail="Session not found")
    return ChatSession(**found)


@router.patch("/chat/sessions/{session_id}", response_model=ChatSession)
async def update_session(
    session_id: str,
    payload: ChatSessionUpdate,
    repo: ChatSessionRepository = Depends(get_chat_session_repo),
):
    updates = payload.model_dump(by_alias=True, exclude_unset=True)
    updated = repo.update(session_id, updates)
    if not updated:
        raise HTTPException(status_code=404, detail="Session not found")
    chat_session = ChatSession(**updated)
    await chat_manager.broadcast(
        chat_session.id,
        {"type": "session_updated", "session": chat_session.model_dump(by_alias=True)},
    )
    return chat_session


@router.post("/chat/sessions/{session_id}/complete", response_model=ChatSession)
async def complete_session(
    session_id: str,
    repo: ChatSessionRepository = Depends(get_chat_session_repo),
):
    updated = repo.complete(session_id)
    if not updated:
        raise HTTPException(status_code=404, detail="Session not found")
    chat_session = ChatSession(**updated)
    await chat_manager.broadcast(
        chat_session.id,
        {"type": "session_completed", "session": chat_session.model_dump(by_alias=True)},
    )
    return chat_session


@router.websocket("/chat/sessions/{session_id}/ws")
async def chat_ws(session_id: str, websocket: WebSocket):
    await chat_manager.connect(session_id, websocket)
    try:
        await websocket.send_json({"type": "connected", "sessionId": session_id})
        while True:
            data = await websocket.receive_json()
            if isinstance(data, dict) and data.get("type") == "ping":
                await websocket.send_json({"type": "pong"})
    except WebSocketDisconnect:
        chat_manager.disconnect(session_id, websocket)
