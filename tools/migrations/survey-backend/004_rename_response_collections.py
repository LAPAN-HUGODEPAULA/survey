"""Rename response collections to match the public API naming."""

from __future__ import annotations

import logging
import os
from datetime import datetime

from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.database import Database


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(f"migration_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"),
    ],
)
logger = logging.getLogger("migration_004")

load_dotenv()

SURVEY_RESPONSES_COLLECTION = "survey_responses"
LEGACY_SURVEY_RESULTS_COLLECTION = "survey_results"
PATIENT_RESPONSES_COLLECTION = "patient_responses"
LEGACY_PATIENT_RESULTS_COLLECTION = "patient_results"


def _resolve_mongo_uri() -> str:
    mongo_uri = os.getenv("MONGO_URI")
    if not mongo_uri:
        username = os.getenv("MONGO_USERNAME")
        password = os.getenv("MONGO_PASSWORD")
        if username and password:
            return f"mongodb://{username}:{password}@localhost:27017/"
        return "mongodb://localhost:27017/"

    if not mongo_uri.startswith(("mongodb://", "mongodb+srv://")):
        return f"mongodb://{mongo_uri}"

    return mongo_uri


def _copy_documents(source: Collection, target: Collection) -> int:
    copied = 0
    for document in source.find():
        target.replace_one({"_id": document["_id"]}, document, upsert=True)
        copied += 1
    return copied


def _ensure_survey_response_indexes(collection: Collection) -> None:
    collection.create_index([("patient.name", 1), ("patient.birthDate", 1), ("testDate", 1)])
    collection.create_index([("surveyId", 1), ("testDate", -1)])


def _ensure_patient_response_indexes(collection: Collection) -> None:
    collection.create_index([("surveyId", 1), ("testDate", -1)])
    collection.create_index([("patient.email", 1), ("testDate", -1)])


def _migrate_collection(
    db: Database,
    *,
    source_name: str,
    target_name: str,
    ensure_indexes,
) -> None:
    target = db[target_name]
    if source_name in db.list_collection_names():
        source = db[source_name]
        copied = _copy_documents(source, target)
        db.drop_collection(source_name)
        logger.info("Migrated %d document(s) from %s to %s.", copied, source_name, target_name)
    else:
        logger.info("Collection %s not found; nothing to migrate.", source_name)

    ensure_indexes(target)
    logger.info("%s count: %d", target_name, target.count_documents({}))


def main() -> None:
    mongo_uri = _resolve_mongo_uri()
    mongo_db_name = os.getenv("MONGO_DB_NAME", "survey_db")
    client = MongoClient(mongo_uri, serverSelectionTimeoutMS=5000)
    try:
        client.admin.command("ping")
        db = client[mongo_db_name]
        _migrate_collection(
            db,
            source_name=LEGACY_SURVEY_RESULTS_COLLECTION,
            target_name=SURVEY_RESPONSES_COLLECTION,
            ensure_indexes=_ensure_survey_response_indexes,
        )
        _migrate_collection(
            db,
            source_name=LEGACY_PATIENT_RESULTS_COLLECTION,
            target_name=PATIENT_RESPONSES_COLLECTION,
            ensure_indexes=_ensure_patient_response_indexes,
        )
        logger.info("Response collection rename completed successfully.")
    finally:
        client.close()


if __name__ == "__main__":
    main()
