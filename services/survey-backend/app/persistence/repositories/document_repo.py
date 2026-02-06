from datetime import datetime
from typing import Optional

from bson import ObjectId
from pymongo.database import Database


class DocumentRepository:
    def __init__(self, db: Database):
        self._col = db["clinical_documents"]

    def create(self, doc: dict) -> dict:
        result = self._col.insert_one(doc)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def get_by_id(self, document_id: str) -> Optional[dict]:
        found = self._col.find_one({"_id": ObjectId(document_id)})
        return self._normalize(found) if found else None

    def update(self, document_id: str, updates: dict) -> Optional[dict]:
        updates.pop("_id", None)
        updates["updatedAt"] = datetime.utcnow()
        self._col.update_one({"_id": ObjectId(document_id)}, {"$set": updates})
        updated = self._col.find_one({"_id": ObjectId(document_id)})
        return self._normalize(updated) if updated else None

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        doc.pop("id", None)
        return doc
