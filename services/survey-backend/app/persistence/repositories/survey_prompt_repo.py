"""Mongo-backed repository for questionnaire-level prompt definitions."""

from datetime import datetime, timezone
from typing import Any

from bson import ObjectId
from pymongo.database import Database
from pymongo.errors import DuplicateKeyError


class SurveyPromptRepository:
    """Handles CRUD operations for questionnaire prompt definitions."""

    PRIMARY_COLLECTION_NAME = "QuestionnairePrompts"
    LEGACY_COLLECTION_NAME = "survey_prompts"

    def __init__(self, db: Database):
        self._col = db[self.PRIMARY_COLLECTION_NAME]
        self._legacy_col = db[self.LEGACY_COLLECTION_NAME]
        self._surveys = db["surveys"]
        self._access_points = db["AgentAccessPoints"]
        self._col.create_index("promptKey", unique=True)
        self._legacy_col.create_index("promptKey", unique=True)

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
        seen_keys: set[str] = set()
        prompts: list[dict] = []
        for collection in (self._col, self._legacy_col):
            for doc in collection.find().sort([("name", 1)]):
                normalized = self._normalize(doc)
                prompt_key = normalized.get("promptKey")
                if not prompt_key or prompt_key in seen_keys:
                    continue
                seen_keys.add(prompt_key)
                prompts.append(normalized)
        prompts.sort(key=lambda item: str(item.get("name", "")).lower())
        return prompts

    def get_by_key(self, prompt_key: str) -> dict | None:
        """Fetch one prompt by runtime key."""
        found = self._col.find_one({"promptKey": prompt_key}) or self._legacy_col.find_one(
            {"promptKey": prompt_key}
        )
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
        return (
            self._surveys.count_documents(
                {
                    "$or": [
                        {"prompt.promptKey": prompt_key},
                        {"promptAssociations.promptKey": prompt_key},
                    ]
                },
                limit=1,
            )
            > 0
            or self._access_points.count_documents({"promptKey": prompt_key}, limit=1) > 0
        )

    @staticmethod
    def is_duplicate_key_error(exc: Exception) -> bool:
        """Expose duplicate-key detection for route handlers."""
        return isinstance(exc, DuplicateKeyError)

    def _normalize(self, doc: dict | None) -> dict:
        """Convert Mongo-specific values into JSON-safe primitives."""
        if not doc:
            return {}
        normalized = dict(doc)
        if "_id" in normalized and isinstance(normalized["_id"], ObjectId):
            normalized["_id"] = str(normalized["_id"])
        allowed_fields = {
            "promptKey",
            "name",
            "promptText",
            "createdAt",
            "modifiedAt",
        }
        return {key: value for key, value in normalized.items() if key in allowed_fields}
