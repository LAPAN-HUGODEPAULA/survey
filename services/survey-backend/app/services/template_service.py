from __future__ import annotations

from datetime import datetime
import re
from typing import Any, Dict, Iterable, List, Tuple


SUPPORTED_DOCUMENT_TYPES: list[dict[str, str]] = [
    {"id": "consultation_record", "label": "Consultation Record"},
    {"id": "prescription", "label": "Prescription"},
    {"id": "referral", "label": "Referral"},
    {"id": "certificate", "label": "Certificate"},
    {"id": "technical_report", "label": "Technical Report"},
    {"id": "clinical_progress", "label": "Clinical Progress"},
]

SUPPORTED_DOCUMENT_TYPE_IDS = {item["id"] for item in SUPPORTED_DOCUMENT_TYPES}

PLACEHOLDER_PATTERN = re.compile(r"\{\{\s*([\w\.\-]+)\s*\}\}")


def normalize_document_type(value: str) -> str:
    if value not in SUPPORTED_DOCUMENT_TYPE_IDS:
        raise ValueError("Unsupported document type.")
    return value


def extract_placeholders(body: str) -> list[str]:
    return sorted({match.group(1) for match in PLACEHOLDER_PATTERN.finditer(body or "")})


def merge_placeholders(body: str, placeholders: Iterable[str] | None) -> list[str]:
    derived = set(extract_placeholders(body))
    provided = set([p for p in (placeholders or []) if p])
    return sorted(derived.union(provided))


def validate_conditions(conditions: List[Dict[str, Any]] | None) -> list[dict]:
    if not conditions:
        return []
    normalized: list[dict] = []
    for condition in conditions:
        if not isinstance(condition, dict):
            raise ValueError("Invalid condition format.")
        field = condition.get("field")
        section = condition.get("section")
        if not field or not section:
            raise ValueError("Invalid condition format.")
        normalized.append(
            {
                "field": field,
                "equals": condition.get("equals"),
                "section": section,
            }
        )
    return normalized


def bump_patch(version: str) -> str:
    parts = version.split(".")
    if len(parts) != 3 or not all(p.isdigit() for p in parts):
        return "1.0.0"
    major, minor, patch = (int(p) for p in parts)
    return f"{major}.{minor}.{patch + 1}"


def build_metadata(template: Dict[str, Any], actor: str | None = None) -> Dict[str, Any]:
    return {
        "templateId": template.get("_id"),
        "templateGroupId": template.get("templateGroupId"),
        "documentType": template.get("documentType"),
        "version": template.get("version"),
        "status": template.get("status"),
        "actor": actor,
        "createdAt": datetime.utcnow().isoformat(),
    }


def _get_value(data: Dict[str, Any], field: str) -> Any:
    current: Any = data
    for part in field.split("."):
        if isinstance(current, dict) and part in current:
            current = current[part]
        else:
            return None
    return current


def _render_placeholders(body: str, data: Dict[str, Any]) -> Tuple[str, list[str]]:
    missing: list[str] = []

    def replace(match: re.Match[str]) -> str:
        key = match.group(1)
        value = _get_value(data, key)
        if value is None:
            if key not in missing:
                missing.append(key)
            return match.group(0)
        return str(value)

    rendered = PLACEHOLDER_PATTERN.sub(replace, body or "")
    return rendered, missing


def apply_conditions(body: str, conditions: List[Dict[str, Any]] | None, data: Dict[str, Any]) -> str:
    if not conditions:
        return body
    appended_sections: list[str] = []
    for condition in conditions:
        field = condition.get("field")
        expected = condition.get("equals")
        section = condition.get("section") or ""
        if not field or not section:
            continue
        actual = _get_value(data, field)
        if actual == expected:
            appended_sections.append(str(section))
    if not appended_sections:
        return body
    return "\n".join([body, *appended_sections]).strip()


def render_template(body: str, conditions: List[Dict[str, Any]] | None, data: Dict[str, Any]) -> Tuple[str, list[str]]:
    conditioned = apply_conditions(body, conditions, data)
    rendered, missing = _render_placeholders(conditioned, data)
    return rendered, missing
