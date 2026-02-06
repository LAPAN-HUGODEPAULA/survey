from datetime import datetime
from typing import Optional

from bson import ObjectId
from pymongo.database import Database


class ChatMessageRepository:
    def __init__(self, db: Database):
        self._col = db["chat_messages"]

    def create(self, message_dict: dict) -> dict:
        result = self._col.insert_one(message_dict)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def list_by_session(self, session_id: str) -> list[dict]:
        query = {"sessionId": session_id}
        return [self._normalize(x) for x in self._col.find(query).sort("createdAt", 1)]

    def get_by_id(self, message_id: str) -> Optional[dict]:
        found = self._col.find_one({"_id": ObjectId(message_id)})
        return self._normalize(found) if found else None

    def update(self, message_id: str, updates: dict) -> Optional[dict]:
        updates.pop("_id", None)
        updates["updatedAt"] = datetime.utcnow()
        self._col.update_one({"_id": ObjectId(message_id)}, {"$set": updates})
        updated = self._col.find_one({"_id": ObjectId(message_id)})
        return self._normalize(updated) if updated else None

    def soft_delete(self, message_id: str) -> Optional[dict]:
        updates = {"deletedAt": datetime.utcnow(), "updatedAt": datetime.utcnow()}
        self._col.update_one({"_id": ObjectId(message_id)}, {"$set": updates})
        updated = self._col.find_one({"_id": ObjectId(message_id)})
        return self._normalize(updated) if updated else None

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        doc.pop("id", None)
        return doc
