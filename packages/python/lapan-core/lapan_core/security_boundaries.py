"""Security helpers for filesystem and outbound URL boundaries."""

from __future__ import annotations

import ipaddress
import os
from pathlib import Path
from urllib.parse import urlparse


class SecurityBoundaryError(ValueError):
    """Raised when an operation crosses a configured security boundary."""


def get_safe_write_path(base_dir: str | Path, filename: str | Path) -> Path:
    """Return a write path contained by base_dir and not targeting a symlink."""
    base_path = Path(base_dir).expanduser()
    candidate_name = Path(filename)
    if candidate_name.is_absolute():
        raise SecurityBoundaryError("Absolute write paths are not allowed.")

    resolved_base = Path(os.path.realpath(base_path))
    candidate_path = base_path / candidate_name
    resolved_candidate = Path(os.path.realpath(candidate_path))

    try:
        resolved_candidate.relative_to(resolved_base)
    except ValueError as exc:
        raise SecurityBoundaryError("Write path escapes the configured base directory.") from exc

    if candidate_path.exists() and candidate_path.is_symlink():
        raise SecurityBoundaryError("Refusing to write through a symlink.")

    # Both paths passed realpath containment checks before directory creation.
    resolved_base.mkdir(parents=True, exist_ok=True)  # skylos: ignore
    resolved_candidate.parent.mkdir(parents=True, exist_ok=True)
    return resolved_candidate


def write_bytes_to_safe_path(base_dir: str | Path, filename: str | Path, data: bytes) -> Path:
    """Write bytes to a safe path without following final-component symlinks."""
    safe_path = get_safe_write_path(base_dir, filename)
    flags = os.O_WRONLY | os.O_CREAT | os.O_TRUNC
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW

    fd = os.open(safe_path, flags, 0o600)  # skylos: ignore
    with os.fdopen(fd, "wb") as handle:
        handle.write(data)
    return safe_path


def write_text_to_safe_path(
    base_dir: str | Path,
    filename: str | Path,
    text: str,
    *,
    encoding: str = "utf-8",
) -> Path:
    """Write text to a safe path without following final-component symlinks."""
    return write_bytes_to_safe_path(base_dir, filename, text.encode(encoding))


def append_text_to_safe_path(
    base_dir: str | Path,
    filename: str | Path,
    text: str,
    *,
    encoding: str = "utf-8",
) -> Path:
    """Append text to a safe path without following final-component symlinks."""
    safe_path = get_safe_write_path(base_dir, filename)
    flags = os.O_WRONLY | os.O_CREAT | os.O_APPEND
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW

    fd = os.open(safe_path, flags, 0o600)  # skylos: ignore
    with os.fdopen(fd, "a", encoding=encoding) as handle:
        handle.write(text)
    return safe_path


def validate_outbound_url(
    url: str,
    allowed_hosts: list[str] | tuple[str, ...] | set[str],
    *,
    allow_loopback: bool = False,
) -> str:
    """Validate an outbound HTTP(S) URL against host and IP safety policy."""
    parsed = urlparse(url)
    if parsed.scheme not in {"http", "https"}:
        raise SecurityBoundaryError("Outbound URL must use http or https.")
    if not parsed.hostname:
        raise SecurityBoundaryError("Outbound URL must include a host.")

    host = parsed.hostname.lower()
    normalized_allowed_hosts = {_extract_allowed_host(value) for value in allowed_hosts}
    normalized_allowed_hosts.discard(None)
    if host not in normalized_allowed_hosts:
        raise SecurityBoundaryError("Outbound URL host is not allowed.")

    _validate_host_address(host, allow_loopback=allow_loopback)
    return url


def _extract_allowed_host(value: str) -> str | None:
    parsed = urlparse(value)
    host = parsed.hostname if parsed.scheme else value.split(":", maxsplit=1)[0]
    return host.lower() if host else None


def _validate_host_address(host: str, *, allow_loopback: bool) -> None:
    if host == "localhost":
        if allow_loopback:
            return
        raise SecurityBoundaryError("Loopback outbound URLs are not allowed.")

    try:
        address = ipaddress.ip_address(host)
    except ValueError:
        return

    if address.is_loopback and not allow_loopback:
        raise SecurityBoundaryError("Loopback outbound URLs are not allowed.")
    if address.is_link_local:
        raise SecurityBoundaryError("Link-local outbound URLs are not allowed.")
    if address.is_unspecified or address.is_multicast:
        raise SecurityBoundaryError("Unsafe outbound IP address is not allowed.")
