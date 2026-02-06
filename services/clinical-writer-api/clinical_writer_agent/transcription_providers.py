from __future__ import annotations

from dataclasses import dataclass
from typing import List, Optional

from .transcription_models import TranscriptionSegment


@dataclass
class TranscriptionResult:
    text: str
    confidence: Optional[float]
    segments: List[TranscriptionSegment]
    provider: str
    language: str
    warnings: List[str]


@dataclass
class TranscriptionConfig:
    language: str
    clinical_mode: bool
    confidence_threshold: Optional[float]
    preview_text: Optional[str]


class TranscriptionProvider:
    name: str = "base"

    def transcribe(self, audio_bytes: bytes, config: TranscriptionConfig) -> TranscriptionResult:
        raise NotImplementedError


class StubTranscriptionProvider(TranscriptionProvider):
    name = "stub"

    def transcribe(self, audio_bytes: bytes, config: TranscriptionConfig) -> TranscriptionResult:
        text = (config.preview_text or "").strip()
        warnings: list[str] = []
        if not text:
            warnings.append("Preview text not provided; returning empty transcription.")
        segment = TranscriptionSegment(
            startSeconds=0.0,
            endSeconds=0.0,
            text=text,
            confidence=0.0 if text else None,
        )
        return TranscriptionResult(
            text=text,
            confidence=0.0 if text else None,
            segments=[segment] if text else [],
            provider=self.name,
            language=config.language,
            warnings=warnings,
        )
