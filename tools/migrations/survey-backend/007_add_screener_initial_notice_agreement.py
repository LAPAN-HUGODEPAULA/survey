"""Backfill the screener initial-notice agreement field for existing records."""

from __future__ import annotations

import os
from datetime import datetime

from pymongo import MongoClient


def _resolve_mongo_uri() -> str:
    mongo_uri = os.getenv("MONGO_URI")
    if mongo_uri:
        return mongo_uri
    username = os.getenv("MONGO_USERNAME")
    password = os.getenv("MONGO_PASSWORD")
    if username and password:
        return f"mongodb://{username}:{password}@localhost:27017/"
    return "mongodb://localhost:27017/"


def _resolve_db_name() -> str:
    return os.getenv("MONGO_DB_NAME", "survey_db")


def main() -> None:
    client = MongoClient(_resolve_mongo_uri(), serverSelectionTimeoutMS=5000)
    db = client[_resolve_db_name()]
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
