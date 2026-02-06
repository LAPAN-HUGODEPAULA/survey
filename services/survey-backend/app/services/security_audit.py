import hashlib
import json
from typing import Optional

from app.config.logging_config import logger
from app.domain.models.privacy_models import SecurityAuditLog
from app.persistence.repositories.security_audit_repo import SecurityAuditRepository


def compute_audit_hash(payload: dict, prev_hash: str | None) -> str:
    serialized = json.dumps(payload, sort_keys=True, default=str).encode("utf-8")
    seed = (prev_hash or "").encode("utf-8") + serialized
    return hashlib.sha256(seed).hexdigest()


class SecurityAuditService:
    def __init__(self, repo: SecurityAuditRepository):
        self._repo = repo

    def record_event(
        self,
        event_type: str,
        actor: Optional[dict] = None,
        target: Optional[dict] = None,
        payload: Optional[dict] = None,
    ) -> SecurityAuditLog:
        latest = self._repo.get_latest()
        prev_hash = latest.get("hash") if latest else None
        audit_payload = {
            "eventType": event_type,
            "actor": actor,
            "target": target,
            "payload": payload,
            "prevHash": prev_hash,
        }
        audit_payload["hash"] = compute_audit_hash(audit_payload, prev_hash)
        created = self._repo.create(audit_payload)
        self._emit_security_alert(event_type, actor, target)
        return SecurityAuditLog.model_validate(created)

    def _emit_security_alert(self, event_type: str, actor: Optional[dict], target: Optional[dict]) -> None:
        if event_type in {"access_denied", "admin_auth_failed"}:
            logger.warning("Security alert: %s actor=%s target=%s", event_type, actor, target)
