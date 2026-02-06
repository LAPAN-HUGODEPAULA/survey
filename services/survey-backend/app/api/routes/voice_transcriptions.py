from __future__ import annotations

from fastapi import APIRouter, HTTPException, status

from app.domain.models.transcription_models import (
    TranscriptionRequest,
    TranscriptionResponse,
)
from app.integrations.clinical_writer.client import send_to_langgraph_transcription

router = APIRouter()


@router.post("/voice/transcriptions", response_model=TranscriptionResponse)
async def transcribe_audio(payload: TranscriptionRequest) -> TranscriptionResponse:
    try:
        result = await send_to_langgraph_transcription(payload.model_dump(by_alias=True))
    except Exception as exc:  # pragma: no cover - defensive
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Failed to transcribe audio: {exc}",
        ) from exc
    return TranscriptionResponse.model_validate(result)
