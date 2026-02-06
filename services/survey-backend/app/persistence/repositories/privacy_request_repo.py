from datetime import datetime

from bson import ObjectId
from pymongo.database import Database


class PrivacyRequestRepository:
    def __init__(self, db: Database):
        self._col = db["privacy_requests"]

    def create(self, payload: dict) -> dict:
        payload["createdAt"] = payload.get("createdAt") or datetime.utcnow()
        payload["updatedAt"] = payload.get("updatedAt") or datetime.utcnow()
        result = self._col.insert_one(payload)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def list_all(self, status: str | None = None) -> list[dict]:
        query = {"status": status} if status else {}
        return [self._normalize(doc) for doc in self._col.find(query).sort("createdAt", -1)]

    def get_by_id(self, request_id: str) -> dict | None:
        try:
            oid = ObjectId(request_id)
        except Exception:
            return None
        found = self._col.find_one({"_id": oid})
        return self._normalize(found)

    def update(self, request_id: str, updates: dict) -> dict | None:
        try:
            oid = ObjectId(request_id)
        except Exception:
            return None
        updates["updatedAt"] = updates.get("updatedAt") or datetime.utcnow()
        result = self._col.find_one_and_update(
            {"_id": oid},
            {"$set": updates},
            return_document=True,
        )
        return self._normalize(result)

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        doc.pop("id", None)
        return doc
