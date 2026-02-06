from datetime import datetime
from typing import Any, Optional

from bson import ObjectId
from pymongo.database import Database


class ChatSessionRepository:
    def __init__(self, db: Database):
        self._col = db["chat_sessions"]

    def create(self, session_dict: dict) -> dict:
        result = self._col.insert_one(session_dict)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def get_by_id(self, session_id: str) -> Optional[dict]:
        found = self._col.find_one({"_id": ObjectId(session_id)})
        return self._normalize(found) if found else None

    def list_by_status(self, status: Optional[str] = None) -> list[dict]:
        query: dict[str, Any] = {}
        if status:
            query["status"] = status
        return [self._normalize(x) for x in self._col.find(query)]

    def update(self, session_id: str, updates: dict) -> Optional[dict]:
        updates.pop("_id", None)
        updates["updatedAt"] = datetime.utcnow()
        self._col.update_one({"_id": ObjectId(session_id)}, {"$set": updates})
        updated = self._col.find_one({"_id": ObjectId(session_id)})
        return self._normalize(updated) if updated else None

    def complete(self, session_id: str) -> Optional[dict]:
        updates = {
            "status": "completed",
            "completedAt": datetime.utcnow(),
            "updatedAt": datetime.utcnow(),
        }
        self._col.update_one({"_id": ObjectId(session_id)}, {"$set": updates})
        updated = self._col.find_one({"_id": ObjectId(session_id)})
        return self._normalize(updated) if updated else None

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        doc.pop("id", None)
        return doc
