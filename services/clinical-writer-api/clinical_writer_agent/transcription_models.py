from __future__ import annotations

from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field, field_validator


class TranscriptionRequest(BaseModel):
    audio_base64: str = Field(..., alias="audioBase64")
    audio_format: str = Field(..., alias="audioFormat")
    sample_rate: Optional[int] = Field(default=None, alias="sampleRate")
    channels: Optional[int] = None
    duration_seconds: Optional[float] = Field(default=None, alias="durationSeconds")
    language: str = Field(default="pt-BR")
    clinical_mode: bool = Field(default=True, alias="clinicalMode")
    confidence_threshold: Optional[float] = Field(default=None, alias="confidenceThreshold")
    preview_text: Optional[str] = Field(default=None, alias="previewText")
    metadata: Dict[str, Any] = Field(default_factory=dict)

    @field_validator("audio_base64")
    @classmethod
    def audio_must_not_be_empty(cls, value: str) -> str:
        if not value or not value.strip():
            raise ValueError("audioBase64 must not be empty")
        return value

    @field_validator("audio_format")
    @classmethod
    def audio_format_must_not_be_empty(cls, value: str) -> str:
        if not value or not value.strip():
            raise ValueError("audioFormat must not be empty")
        return value


class TranscriptionSegment(BaseModel):
    start_seconds: float = Field(..., alias="startSeconds")
    end_seconds: float = Field(..., alias="endSeconds")
    text: str
    confidence: Optional[float] = None


class TranscriptionResponse(BaseModel):
    request_id: str = Field(..., alias="requestId")
    text: str
    confidence: Optional[float] = None
    segments: List[TranscriptionSegment] = Field(default_factory=list)
    processing_time_ms: int = Field(..., alias="processingTimeMs")
    provider: str
    language: str
    warnings: List[str] = Field(default_factory=list)
    metadata: Dict[str, Any] = Field(default_factory=dict)
