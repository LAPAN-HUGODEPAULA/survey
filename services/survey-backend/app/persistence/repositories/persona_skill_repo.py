"""Mongo-backed repository for output persona skill definitions."""

from datetime import datetime, timezone

from bson import ObjectId
from pymongo.database import Database


class PersonaSkillRepository:
    """Handles CRUD operations for persona skill documents."""

    COLLECTION_NAME = "PersonaSkills"

    def __init__(self, db: Database):
        self._col = db[self.COLLECTION_NAME]
        self._col.create_index("personaSkillKey", unique=True)
        self._col.create_index("outputProfile", unique=True)

    def create(self, persona_skill_data: dict) -> dict:
        """Insert a persona skill and return the stored document."""
        timestamp = datetime.now(timezone.utc)
        payload = {
            **persona_skill_data,
            "createdAt": persona_skill_data.get("createdAt", timestamp),
            "modifiedAt": timestamp,
        }
        self._col.insert_one(payload)
        created = self._col.find_one({"personaSkillKey": payload["personaSkillKey"]})
        return self._normalize(created)

    def list_all(self) -> list[dict]:
        """Return every stored persona skill ordered for stable UI rendering."""
        return [self._normalize(doc) for doc in self._col.find().sort([("name", 1)])]

    def get_by_key(self, persona_skill_key: str) -> dict | None:
        """Fetch one persona skill by runtime key."""
        found = self._col.find_one({"personaSkillKey": persona_skill_key})
        return self._normalize(found) if found else None

    def get_by_output_profile(self, output_profile: str) -> dict | None:
        """Fetch one persona skill by output profile."""
        found = self._col.find_one({"outputProfile": output_profile})
        return self._normalize(found) if found else None

    def update(self, persona_skill_key: str, persona_skill_data: dict) -> dict | None:
        """Update a stored persona skill and return the latest document."""
        payload = {
            **persona_skill_data,
            "modifiedAt": datetime.now(timezone.utc),
        }
        payload.pop("createdAt", None)
        self._col.update_one({"personaSkillKey": persona_skill_key}, {"$set": payload})
        updated = self._col.find_one({"personaSkillKey": persona_skill_key})
        return self._normalize(updated) if updated else None

    def delete(self, persona_skill_key: str) -> bool:
        """Delete a persona skill by key."""
        result = self._col.delete_one({"personaSkillKey": persona_skill_key})
        return result.deleted_count > 0

    def _normalize(self, doc: dict | None) -> dict:
        """Convert Mongo-specific values into JSON-safe primitives."""
        if not doc:
            return {}
        normalized = dict(doc)
        if "_id" in normalized and isinstance(normalized["_id"], ObjectId):
            normalized["_id"] = str(normalized["_id"])
        allowed_fields = {
            "personaSkillKey",
            "name",
            "outputProfile",
            "instructions",
            "createdAt",
            "modifiedAt",
        }
        return {key: value for key, value in normalized.items() if key in allowed_fields}
