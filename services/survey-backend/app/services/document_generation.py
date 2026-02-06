from __future__ import annotations

from datetime import datetime
from typing import Dict, Any, List


def build_body_from_messages(messages: List[Dict[str, Any]]) -> str:
    lines: list[str] = []
    for msg in messages:
        if msg.get("deletedAt"):
            continue
        role = msg.get("role") or "unknown"
        content = msg.get("content") or ""
        if not content:
            continue
        lines.append(f"{role.title()}: {content}")
    return "\n".join(lines).strip()


def build_title(document_type: str) -> str:
    base = document_type.replace("_", " ").title()
    return f"Clinical Document - {base}".strip()


def build_metadata(session: Dict[str, Any], document_type: str) -> Dict[str, Any]:
    return {
        "sessionId": session.get("_id"),
        "phase": session.get("phase"),
        "status": session.get("status"),
        "documentType": document_type,
        "createdAt": datetime.utcnow().isoformat(),
        "patientId": session.get("patientId"),
    }


def render_html(title: str, body: str, metadata: Dict[str, Any]) -> str:
    phase = metadata.get("phase") or "unknown"
    session_id = metadata.get("sessionId") or "unknown"
    patient_id = metadata.get("patientId") or "unknown"
    created_at = metadata.get("createdAt") or ""
    escaped_body = body.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    escaped_body = escaped_body.replace("\n", "<br/>")
    return (
        "<html><head><meta charset=\"utf-8\"/>"
        "<title>{title}</title></head><body>"
        "<h1>{title}</h1>"
        "<p><strong>Session:</strong> {session_id}</p>"
        "<p><strong>Phase:</strong> {phase}</p>"
        "<p><strong>Patient:</strong> {patient_id}</p>"
        "<p><strong>Generated:</strong> {created_at}</p>"
        "<hr/>"
        "<div>{body}</div>"
        "</body></html>"
    ).format(
        title=title,
        session_id=session_id,
        phase=phase,
        patient_id=patient_id,
        created_at=created_at,
        body=escaped_body,
    )


def detect_missing_fields(title: str, body: str, metadata: Dict[str, Any]) -> list[str]:
    missing: list[str] = []
    if not title.strip():
        missing.append("title")
    if not body.strip():
        missing.append("body")
    if not metadata.get("patientId"):
        missing.append("patientId")
    return missing


def validate_compliance(title: str, body: str) -> None:
    if not title.strip():
        raise ValueError("Document title is required.")
    if not body.strip():
        raise ValueError("Document body is required.")
