from __future__ import annotations

import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

import logging

logger = logging.getLogger("clinical_writer")


def store_audio(
    audio_bytes: bytes,
    request_id: str,
    audio_format: str,
    directory: str,
) -> Path:
    Path(directory).mkdir(parents=True, exist_ok=True)
    safe_format = audio_format.replace("/", "_").replace(";", "_").replace(" ", "_")
    filename = f"{request_id}.{safe_format}"
    path = Path(directory) / filename
    path.write_bytes(audio_bytes)
    return path


def delete_audio(path: Path, audit_log_path: Optional[str] = None) -> None:
    if path.exists():
        path.unlink()
        _write_audit_log(path.name, audit_log_path)


def _write_audit_log(filename: str, audit_log_path: Optional[str]) -> None:
    if not audit_log_path:
        logger.info("Audio deletion audit: file=%s deleted_at=%s", filename, datetime.now(timezone.utc))
        return
    try:
        Path(audit_log_path).parent.mkdir(parents=True, exist_ok=True)
        with open(audit_log_path, "a", encoding="utf-8") as handle:
            handle.write(f"{datetime.now(timezone.utc).isoformat()} file={filename}\n")
    except Exception as exc:  # pragma: no cover - defensive
        logger.warning("Failed to write audio deletion audit: %s", exc)
