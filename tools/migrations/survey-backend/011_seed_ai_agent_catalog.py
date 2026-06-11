"""Seed AI agents and migrate access points to ordered agent routes."""

from __future__ import annotations

from datetime import datetime, timezone

from pymongo import MongoClient

from _env import load_migration_env, resolve_mongo_db_name, resolve_mongo_uri
from ai_agent_seed import build_ai_agent_documents


AI_AGENTS_COLLECTION = "AIAgents"
AGENT_ACCESS_POINTS_COLLECTION = "AgentAccessPoints"


def _upsert_ai_agents(db) -> tuple[int, int]:
    agents = db[AI_AGENTS_COLLECTION]
    agents.create_index("agentKey", unique=True)
    agents.create_index(
        [("enabled", 1), ("providerType", 1)],
        name="enabled_provider_idx",
    )
    inserted = 0
    updated = 0
    timestamp = datetime.now(timezone.utc)
    for payload in build_ai_agent_documents(
        "011_seed_ai_agent_catalog",
        timestamp=timestamp,
    ):
        agent_key = payload["agentKey"]
        existing = agents.find_one({"agentKey": agent_key})
        created_at = existing.get("createdAt") if existing else payload["createdAt"]
        merged = {
            **payload,
            "createdAt": created_at,
            "modifiedAt": timestamp,
        }
        agents.replace_one({"agentKey": agent_key}, merged, upsert=True)
        if existing:
            updated += 1
        else:
            inserted += 1
    return inserted, updated


def _migrate_access_points(db) -> int:
    access_points = db[AGENT_ACCESS_POINTS_COLLECTION]
    timestamp = datetime.now(timezone.utc)
    new_ai_config = {
        "agentRefs": [
            {
                "agentKey": "local_qwen",
                "model": "qwen2.5-coder:7b",
                "temperature": 0.3,
                "enabled": True,
            },
            {
                "agentKey": "gemini",
                "temperature": 0.3,
                "enabled": True,
            },
        ],
        "temperature": 0.3,
        "reasoningEffort": "low",
        "enableCaching": True,
    }
    result = access_points.update_many(
        {},
        {"$set": {"aiConfig": new_ai_config, "modifiedAt": timestamp}},
    )
    return result.modified_count


def main() -> None:
    load_migration_env()
    client = MongoClient(resolve_mongo_uri(), serverSelectionTimeoutMS=5000)
    db = client[resolve_mongo_db_name()]

    try:
        inserted, updated = _upsert_ai_agents(db)
        access_points_updated = _migrate_access_points(db)
        print(
            "AI agent catalog seed complete: "
            f"agents_inserted={inserted}, agents_updated={updated}, "
            f"access_points_updated={access_points_updated}"
        )
    finally:
        client.close()


if __name__ == "__main__":
    main()
