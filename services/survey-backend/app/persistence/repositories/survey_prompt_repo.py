"""Mongo-backed repository for reusable survey prompts."""

from datetime import datetime, timezone
from typing import Any

from bson import ObjectId
from pymongo.database import Database
from pymongo.errors import DuplicateKeyError


class SurveyPromptRepository:
    """Handles CRUD operations for reusable survey prompts."""

    def __init__(self, db: Database):
        self._col = db["survey_prompts"]
        self._surveys = db["surveys"]
        self._col.create_index("promptKey", unique=True)

    def create(self, prompt_data: dict) -> dict:
        """Insert a prompt and return the stored document."""
        timestamp = datetime.now(timezone.utc)
        payload = {
            **prompt_data,
            "createdAt": prompt_data.get("createdAt", timestamp),
            "modifiedAt": timestamp,
        }
        self._col.insert_one(payload)
        created = self._col.find_one({"promptKey": payload["promptKey"]})
        return self._normalize(created)

    def list_all(self) -> list[dict]:
        """Return every stored prompt ordered for stable UI rendering."""
        return [self._normalize(doc) for doc in self._col.find().sort([("outcomeType", 1), ("name", 1)])]

    def get_by_key(self, prompt_key: str) -> dict | None:
        """Fetch one prompt by runtime key."""
        found = self._col.find_one({"promptKey": prompt_key})
        return self._normalize(found) if found else None

    def update(self, prompt_key: str, prompt_data: dict) -> dict | None:
        """Update a stored prompt and return the latest document."""
        payload = {
            **prompt_data,
            "modifiedAt": datetime.now(timezone.utc),
        }
        payload.pop("createdAt", None)
        self._col.update_one({"promptKey": prompt_key}, {"$set": payload})
        updated = self._col.find_one({"promptKey": prompt_key})
        return self._normalize(updated) if updated else None

    def delete(self, prompt_key: str) -> bool:
        """Delete a prompt by key."""
        result = self._col.delete_one({"promptKey": prompt_key})
        return result.deleted_count > 0

    def is_in_use(self, prompt_key: str) -> bool:
        """Check whether any survey still references the prompt."""
        return self._surveys.count_documents({"promptAssociations.promptKey": prompt_key}, limit=1) > 0

    @staticmethod
    def is_duplicate_key_error(exc: Exception) -> bool:
        """Expose duplicate-key detection for route handlers."""
        return isinstance(exc, DuplicateKeyError)

    def _normalize(self, doc: dict | None) -> dict:
        """Convert Mongo-specific values into JSON-safe primitives."""
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        return doc
