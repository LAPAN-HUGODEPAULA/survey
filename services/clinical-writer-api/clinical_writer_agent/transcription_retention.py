from __future__ import annotations

import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

import logging

from lapan_core import (
    SecurityBoundaryError,
    append_text_to_safe_path,
    get_safe_write_path,
    write_bytes_to_safe_path,
)

logger = logging.getLogger("clinical_writer")


def store_audio(
    audio_bytes: bytes,
    request_id: str,
    audio_format: str,
    directory: str,
) -> Path:
    safe_format = audio_format.replace("/", "_").replace(";", "_").replace(" ", "_")
    filename = f"{request_id}.{safe_format}"
    return write_bytes_to_safe_path(directory, filename, audio_bytes)


def delete_audio(path: Path, audit_log_path: Optional[str] = None) -> None:
    if path.exists():
        path.unlink()
        _write_audit_log(path.name, audit_log_path)


def cleanup_stale_audio_files(
    directory: str,
    *,
    audit_log_path: Optional[str] = None,
    max_age_seconds: int = 30 * 60,
    now: datetime | None = None,
) -> list[str]:
    """Delete stranded audio files older than the configured retention window."""
    base_dir = Path(directory).expanduser()
    if not base_dir.exists():
        return []

    resolved_base = base_dir.resolve()
    reference_time = now or datetime.now(timezone.utc)
    cutoff_timestamp = reference_time.timestamp() - max_age_seconds
    deleted_files: list[str] = []

    for candidate in resolved_base.iterdir():
        if not candidate.exists() or not candidate.is_file():
            continue
        try:
            safe_path = get_safe_write_path(resolved_base, candidate.name)
        except SecurityBoundaryError:
            logger.warning("Skipping unsafe stranded audio candidate: %s", candidate)
            continue
        if safe_path.stat().st_mtime > cutoff_timestamp:
            continue
        safe_path.unlink()
        _write_audit_log(safe_path.name, audit_log_path)
        deleted_files.append(safe_path.name)

    return deleted_files


def cleanup_startup_audio_residue() -> list[str]:
    """Run startup cleanup using the same retention configuration as transcription."""
    directory = os.getenv("TRANSCRIPTION_AUDIO_DIR", "/tmp/clinical-writer-audio")
    audit_log_path = os.getenv(
        "TRANSCRIPTION_DELETE_LOG_PATH",
        "/tmp/clinical-writer-audio-deletions.log",
    )
    max_age_seconds = int(
        os.getenv("TRANSCRIPTION_STARTUP_CLEANUP_MAX_AGE_SECONDS", str(30 * 60))
    )
    return cleanup_stale_audio_files(
        directory,
        audit_log_path=audit_log_path,
        max_age_seconds=max_age_seconds,
    )


def _write_audit_log(filename: str, audit_log_path: Optional[str]) -> None:
    if not audit_log_path:
        logger.info("Audio deletion audit: file=%s deleted_at=%s", filename, datetime.now(timezone.utc))
        return
    try:
        requested_path = Path(audit_log_path)
        append_text_to_safe_path(
            requested_path.parent,
            requested_path.name,
            f"{datetime.now(timezone.utc).isoformat()} file={filename}\n",
        )
    except Exception as exc:  # pragma: no cover - defensive
        logger.warning("Failed to write audio deletion audit: %s", exc)
