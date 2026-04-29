"""Shared key normalization logic for domain model field validators."""

from __future__ import annotations

_BASE_ALLOWED = frozenset("abcdefghijklmnopqrstuvwxyz0123456789:_-")

_EXTRA_CHAR_LABELS: dict[str, str] = {
    ".": "period",
}


def normalize_key(
    value: str | None,
    *,
    field_name: str,
    allowed_extra_chars: str = "",
    optional: bool = False,
) -> str | None:
    """Normalize a code-safe key: strip, lowercase, validate charset.

    Returns the normalized string, or None when *optional* is True and *value*
    is None or blank.
    """
    if optional and (value is None or not value.strip()):
        return None

    normalized = (value or "").strip()
    if not normalized:
        raise ValueError(f"{field_name} must not be blank")

    allowed = _BASE_ALLOWED | frozenset(allowed_extra_chars)
    lowered = normalized.lower()
    if any(ch not in allowed for ch in lowered):
        parts = ["lowercase letters", "digits", "colon", "underscore", "hyphen"]
        for ch in sorted(allowed_extra_chars):
            parts.append(_EXTRA_CHAR_LABELS.get(ch, ch))
        raise ValueError(
            f"{field_name} must contain only {', '.join(parts)}"
        )
    return lowered
