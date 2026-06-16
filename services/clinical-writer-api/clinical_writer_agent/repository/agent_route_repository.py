"""Repository for resolving routed LLM agent configuration from MongoDB."""

from __future__ import annotations

import os
from typing import Any, Protocol

from pymongo import MongoClient


class AgentRouteRepository(Protocol):
    """Resolve agent-route configuration by key."""

    def get_agent(self, agent_key: str) -> dict[str, Any] | None:
        """Return a route document for the requested agent key."""


class NullAgentRouteRepository:
    """Repository used when no Mongo-backed route source is configured."""

    def get_agent(self, agent_key: str) -> dict[str, Any] | None:
        del agent_key
        return None


class MongoAgentRouteRepository:
    """Mongo-backed repository for AIAgent route lookups."""

    def __init__(
        self,
        *,
        mongo_uri: str | None = None,
        db_name: str | None = None,
        collection_name: str = "AIAgents",
        server_selection_timeout_ms: int = 500,
        collection: Any | None = None,
    ) -> None:
        self._cache: dict[str, dict[str, Any] | None] = {}
        self._client = None
        if collection is not None:
            self._collection = collection
            return
        if not mongo_uri or not db_name:
            raise ValueError("MongoAgentRouteRepository requires mongo_uri and db_name.")
        self._client = MongoClient(
            mongo_uri,
            serverSelectionTimeoutMS=server_selection_timeout_ms,
        )
        self._collection = self._client[db_name][collection_name]

    def get_agent(self, agent_key: str) -> dict[str, Any] | None:
        if agent_key in self._cache:
            return self._cache[agent_key]
        document = self._collection.find_one({"agentKey": agent_key}, {"_id": 0})
        self._cache[agent_key] = document
        return document


def create_agent_route_repository_from_env() -> AgentRouteRepository:
    """Build a route repository from runtime Mongo settings or a null fallback."""
    mongo_uri = os.getenv("MONGO_URI")
    db_name = os.getenv("MONGO_DB_NAME", "survey_db")
    if not mongo_uri:
        return NullAgentRouteRepository()
    try:
        return MongoAgentRouteRepository(mongo_uri=mongo_uri, db_name=db_name)
    except Exception:
        return NullAgentRouteRepository()
