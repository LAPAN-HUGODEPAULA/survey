from datetime import datetime

from bson import ObjectId
from pymongo.database import Database


class TemplateAuditRepository:
    def __init__(self, db: Database):
        self._col = db["clinical_template_audits"]

    def create(self, audit: dict) -> dict:
        audit["createdAt"] = audit.get("createdAt") or datetime.utcnow()
        result = self._col.insert_one(audit)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        doc.pop("id", None)
        return doc
