"""Seed the default agent access points used by the three runtime apps."""

from __future__ import annotations

from datetime import datetime, timezone

from pymongo import MongoClient

from _env import load_migration_env, resolve_mongo_db_name, resolve_mongo_uri
from access_point_seed import (
    build_access_point_documents,
    should_refresh_seeded_access_point,
)


AGENT_ACCESS_POINTS_COLLECTION = "AgentAccessPoints"


def _upsert_access_point_catalog(db) -> tuple[int, int, int]:
    access_points = db[AGENT_ACCESS_POINTS_COLLECTION]
    access_points.create_index("accessPointKey", unique=True)
    access_points.create_index(
        [("sourceApp", 1), ("flowKey", 1), ("surveyId", 1)],
        name="runtime_lookup_idx",
    )

    inserted = 0
    refreshed = 0
    skipped = 0
    timestamp = datetime.now(timezone.utc)

    for payload in build_access_point_documents(
        "009_seed_default_agent_access_points",
        timestamp=timestamp,
    ):
        access_point_key = payload["accessPointKey"]
        existing = access_points.find_one({"accessPointKey": access_point_key})
        if not should_refresh_seeded_access_point(existing, access_point_key):
            skipped += 1
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

    return inserted, refreshed, skipped


def main() -> None:
    load_migration_env()
    client = MongoClient(resolve_mongo_uri(), serverSelectionTimeoutMS=5000)
    db = client[resolve_mongo_db_name()]

    try:
        counts = _upsert_access_point_catalog(db)
        print(
            "Default agent access-point seed complete: "
            f"inserted={counts[0]}, refreshed={counts[1]}, skipped={counts[2]}"
        )
    finally:
        client.close()


if __name__ == "__main__":
    main()
