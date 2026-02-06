from datetime import datetime

from bson import ObjectId
from pymongo.database import Database


class DataLifecycleRepository:
    def __init__(self, db: Database):
        self._col = db["data_lifecycle_jobs"]

    def create(self, payload: dict) -> dict:
        payload["createdAt"] = payload.get("createdAt") or datetime.utcnow()
        payload["updatedAt"] = payload.get("updatedAt") or datetime.utcnow()
        result = self._col.insert_one(payload)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def list_by_request(self, request_id: str) -> list[dict]:
        return [
            self._normalize(doc)
            for doc in self._col.find({"requestId": request_id}).sort("createdAt", -1)
        ]

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        doc.pop("id", None)
        return doc
