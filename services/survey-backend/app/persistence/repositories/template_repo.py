from datetime import datetime
from typing import Optional

from bson import ObjectId
from pymongo.database import Database


class TemplateRepository:
    def __init__(self, db: Database):
        self._col = db["clinical_templates"]

    def create(self, template: dict) -> dict:
        result = self._col.insert_one(template)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def get_by_id(self, template_id: str) -> Optional[dict]:
        found = self._col.find_one({"_id": ObjectId(template_id)})
        return self._normalize(found) if found else None

    def list(self, query: dict | None = None, sort: list[tuple] | None = None) -> list[dict]:
        query = query or {}
        cursor = self._col.find(query)
        if sort:
            cursor = cursor.sort(sort)
        return [self._normalize(item) for item in cursor]

    def update(self, template_id: str, updates: dict) -> Optional[dict]:
        updates.pop("_id", None)
        updates["updatedAt"] = datetime.utcnow()
        self._col.update_one({"_id": ObjectId(template_id)}, {"$set": updates})
        updated = self._col.find_one({"_id": ObjectId(template_id)})
        return self._normalize(updated) if updated else None

    def update_many(self, query: dict, updates: dict) -> None:
        updates["updatedAt"] = datetime.utcnow()
        self._col.update_many(query, {"$set": updates})

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        doc.pop("id", None)
        return doc
