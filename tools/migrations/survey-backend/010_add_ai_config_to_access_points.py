"""Add AI configuration to all agent access points."""

from __future__ import annotations

from datetime import datetime, timezone

from pymongo import MongoClient

from _env import load_migration_env, resolve_mongo_db_name, resolve_mongo_uri
from access_point_seed import (
    DEFAULT_AI_CONFIG,
    build_access_point_documents,
    should_refresh_seeded_access_point,
)


AGENT_ACCESS_POINTS_COLLECTION = "AgentAccessPoints"


def _migrate_access_point_ai_config(db) -> tuple[int, int]:
    access_points = db[AGENT_ACCESS_POINTS_COLLECTION]
    
    # 1. Update seeded access points using the updated seeds in access_point_seed.py
    timestamp = datetime.now(timezone.utc)
    refreshed = 0
    inserted = 0
    
    for payload in build_access_point_documents(
        "010_add_ai_config_to_access_points",
        timestamp=timestamp,
    ):
        access_point_key = payload["accessPointKey"]
        existing = access_points.find_one({"accessPointKey": access_point_key})
        
        # We always want to update seeded ones to include aiConfig if they were managed by us
        if not should_refresh_seeded_access_point(existing, access_point_key):
            continue

        created_at = (
            existing.get("createdAt") if existing and existing.get("createdAt") else payload["createdAt"]
        )
        merged_payload = {
            **payload,
            "createdAt": created_at,
            "modifiedAt": timestamp,
        }
        access_points.replace_one(
            {"accessPointKey": access_point_key},
            merged_payload,
            upsert=True,
        )
        if existing is None:
            inserted += 1
        else:
            refreshed += 1

    # 2. Add default aiConfig to any custom access points that don't have it
    result = access_points.update_many(
        {"aiConfig": {"$exists": False}},
        {"$set": {"aiConfig": DEFAULT_AI_CONFIG, "modifiedAt": timestamp}}
    )
    custom_updated = result.modified_count

    return inserted + refreshed, custom_updated


def main() -> None:
    load_migration_env()
    client = MongoClient(resolve_mongo_uri(), serverSelectionTimeoutMS=5000)
    db = client[resolve_mongo_db_name()]

    try:
        total_seeded, total_custom = _migrate_access_point_ai_config(db)
        print(
            "AI config migration complete: "
            f"seeded_updated={total_seeded}, custom_updated={total_custom}"
        )
    finally:
        client.close()


if __name__ == "__main__":
    main()
