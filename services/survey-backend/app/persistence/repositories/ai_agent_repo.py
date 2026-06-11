"""Mongo-backed repository for AI agent catalog definitions."""

from datetime import datetime, timezone

from bson import ObjectId
from pymongo.database import Database
from pymongo.errors import DuplicateKeyError


class AIAgentRepository:
    """Handles CRUD and runtime lookups for AI agent catalog documents."""

    COLLECTION_NAME = "AIAgents"

    def __init__(self, db: Database):
        self._col = db[self.COLLECTION_NAME]
        self._col.create_index("agentKey", unique=True)
        self._col.create_index(
            [("enabled", 1), ("providerType", 1)],
            name="enabled_provider_idx",
        )

    def create(self, agent_data: dict) -> dict:
        timestamp = datetime.now(timezone.utc)
        payload = {
            **agent_data,
            "createdAt": agent_data.get("createdAt", timestamp),
            "modifiedAt": timestamp,
        }
        try:
            self._col.insert_one(payload)
        except DuplicateKeyError as exc:
            raise ValueError("duplicate_agent_key") from exc
        created = self._col.find_one({"agentKey": payload["agentKey"]})
        return self._normalize(created)

    def list_all(self) -> list[dict]:
        return [
            self._normalize(doc)
            for doc in self._col.find().sort([("name", 1), ("agentKey", 1)])
        ]

    def get_by_key(self, agent_key: str) -> dict | None:
        found = self._col.find_one({"agentKey": agent_key})
        return self._normalize(found) if found else None

    def update(self, agent_key: str, agent_data: dict) -> dict | None:
        payload = {
            **agent_data,
            "modifiedAt": datetime.now(timezone.utc),
        }
        payload.pop("createdAt", None)
        try:
            self._col.update_one({"agentKey": agent_key}, {"$set": payload})
        except DuplicateKeyError as exc:
            raise ValueError("duplicate_agent_key") from exc
        updated = self._col.find_one({"agentKey": agent_key})
        return self._normalize(updated) if updated else None

    def delete(self, agent_key: str) -> bool:
        result = self._col.delete_one({"agentKey": agent_key})
        return result.deleted_count > 0

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        normalized = dict(doc)
        if "_id" in normalized and isinstance(normalized["_id"], ObjectId):
            normalized["_id"] = str(normalized["_id"])
        allowed_fields = {
            "agentKey",
            "name",
            "providerType",
            "baseUrl",
            "apiKeyEnvVar",
            "defaultModel",
            "enabled",
            "supportsOpenAIChatCompletions",
            "supportsResponseFormat",
            "supportsRag",
            "notes",
            "createdAt",
            "modifiedAt",
        }
        return {key: value for key, value in normalized.items() if key in allowed_fields}
