import base64
import os
from datetime import datetime, timedelta, timezone
from pathlib import Path

from clinical_writer_agent.transcription_models import TranscriptionRequest
from clinical_writer_agent.transcription_retention import cleanup_stale_audio_files
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


def test_cleanup_stale_audio_files_deletes_only_expired_files(tmp_path: Path) -> None:
    old_file = tmp_path / "old.webm"
    old_file.write_bytes(b"old")
    fresh_file = tmp_path / "fresh.webm"
    fresh_file.write_bytes(b"fresh")
    old_time = datetime.now(timezone.utc) - timedelta(hours=1)
    fresh_time = datetime.now(timezone.utc)
    old_timestamp = old_time.timestamp()
    fresh_timestamp = fresh_time.timestamp()
    os.utime(old_file, (old_timestamp, old_timestamp))
    os.utime(fresh_file, (fresh_timestamp, fresh_timestamp))

    deleted = cleanup_stale_audio_files(
        str(tmp_path),
        audit_log_path=str(tmp_path / "audit.log"),
        max_age_seconds=30 * 60,
        now=datetime.now(timezone.utc),
    )

    assert deleted == ["old.webm"]
    assert not old_file.exists()
    assert fresh_file.exists()
    assert (tmp_path / "audit.log").exists()
