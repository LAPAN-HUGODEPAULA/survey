import base64
import os
from pathlib import Path

from clinical_writer_agent.transcription_models import TranscriptionRequest
from clinical_writer_agent.transcription_service import transcribe


def test_transcribe_with_preview_text(tmp_path: Path, monkeypatch) -> None:
    audio_bytes = b"fake-audio"
    payload = TranscriptionRequest(
        audioBase64=base64.b64encode(audio_bytes).decode("utf-8"),
        audioFormat="audio/webm",
        previewText="Preview text",
        metadata={"requestId": "test-req"},
    )
    monkeypatch.setenv("TRANSCRIPTION_AUDIO_DIR", str(tmp_path))
    monkeypatch.setenv("TRANSCRIPTION_DELETE_LOG_PATH", str(tmp_path / "audit.log"))
    result = transcribe(payload)

    assert result.text == "Preview text"
    assert result.provider == "stub"
    assert result.processing_time_ms >= 0
    assert (tmp_path / "audit.log").exists()
