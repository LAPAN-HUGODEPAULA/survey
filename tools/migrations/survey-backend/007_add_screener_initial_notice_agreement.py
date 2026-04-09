"""Backfill the screener initial-notice agreement field for existing records."""

from __future__ import annotations

from datetime import datetime

from pymongo import MongoClient
from _env import load_migration_env, resolve_mongo_db_name, resolve_mongo_uri


def main() -> None:
    load_migration_env()
    client = MongoClient(resolve_mongo_uri(), serverSelectionTimeoutMS=5000)
    db = client[resolve_mongo_db_name()]
    screeners = db["screeners"]
    updated = 0
    try:
        result = screeners.update_many(
            {"initialNoticeAcceptedAt": {"$exists": False}},
            {"$set": {"initialNoticeAcceptedAt": None}},
        )
        updated = result.modified_count
    finally:
        client.close()

    timestamp = datetime.utcnow().isoformat()
    print(
        f"[{timestamp}] Updated {updated} screener documents with "
        "initialNoticeAcceptedAt=None."
    )


if __name__ == "__main__":
    main()
