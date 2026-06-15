from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

import logging

from lapan_core import append_text_to_safe_path, write_bytes_to_safe_path

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
