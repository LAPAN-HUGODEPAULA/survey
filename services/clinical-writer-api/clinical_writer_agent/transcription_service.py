from __future__ import annotations

import base64
import os
import time
import uuid
from typing import Optional

import logging

from .transcription_models import TranscriptionRequest, TranscriptionResponse
from .transcription_providers import (
    TranscriptionConfig,
    TranscriptionProvider,
    TranscriptionResult,
    StubTranscriptionProvider,
)
from .transcription_retention import delete_audio, store_audio

logger = logging.getLogger("clinical_writer")

def _get_provider_name() -> str:
    return os.getenv("TRANSCRIPTION_PROVIDER", "stub")


def _get_audio_dir() -> str:
    return os.getenv("TRANSCRIPTION_AUDIO_DIR", "/tmp/clinical-writer-audio")


def _get_delete_log() -> str:
    return os.getenv("TRANSCRIPTION_DELETE_LOG_PATH", "/tmp/clinical-writer-audio-deletions.log")


def _get_max_bytes() -> int:
    return int(os.getenv("TRANSCRIPTION_MAX_BYTES", str(5 * 1024 * 1024)))


def get_provider() -> TranscriptionProvider:
    if _get_provider_name() == "stub":
        return StubTranscriptionProvider()
    return StubTranscriptionProvider()


def _decode_audio(payload: TranscriptionRequest) -> bytes:
    try:
        raw = base64.b64decode(payload.audio_base64)
    except Exception as exc:  # pragma: no cover - defensive
        raise ValueError("Invalid base64 audio payload") from exc
    if len(raw) > _get_max_bytes():
        raise ValueError("Audio payload exceeds max size")
    return raw


def transcribe(payload: TranscriptionRequest) -> TranscriptionResponse:
    request_id = payload.metadata.get("requestId") or str(uuid.uuid4())
    provider = get_provider()
    start = time.monotonic()

    audio_bytes = _decode_audio(payload)
    stored_path = store_audio(
        audio_bytes,
        request_id=request_id,
        audio_format=payload.audio_format,
        directory=_get_audio_dir(),
    )

    config = TranscriptionConfig(
        language=payload.language,
        clinical_mode=payload.clinical_mode,
        confidence_threshold=payload.confidence_threshold,
        preview_text=payload.preview_text,
    )

    warnings: list[str] = []
    try:
        result: TranscriptionResult = provider.transcribe(audio_bytes, config)
    except Exception as exc:  # pragma: no cover - defensive
        logger.error("Transcription provider error: %s", exc)
        result = StubTranscriptionProvider().transcribe(audio_bytes, config)
        warnings.append("Transcription provider failed; returning preview text.")

    try:
        delete_audio(stored_path, _get_delete_log())
    except Exception as exc:  # pragma: no cover - defensive
        logger.warning("Failed to delete audio file: %s", exc)
        warnings.append("Audio deletion failed; retention policy may be delayed.")

    elapsed_ms = int((time.monotonic() - start) * 1000)

    return TranscriptionResponse(
        requestId=request_id,
        text=result.text,
        confidence=result.confidence,
        segments=result.segments,
        processingTimeMs=elapsed_ms,
        provider=result.provider,
        language=result.language,
        warnings=[*result.warnings, *warnings],
        metadata=payload.metadata,
    )
