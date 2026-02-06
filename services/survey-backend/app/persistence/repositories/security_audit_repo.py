from datetime import datetime

from bson import ObjectId
from pymongo.database import Database


class SecurityAuditRepository:
    def __init__(self, db: Database):
        self._col = db["security_audit_logs"]

    def create(self, payload: dict) -> dict:
        payload["createdAt"] = payload.get("createdAt") or datetime.utcnow()
        result = self._col.insert_one(payload)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def get_latest(self) -> dict | None:
        latest = self._col.find_one(sort=[("createdAt", -1)])
        return self._normalize(latest)

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        doc.pop("id", None)
        return doc
