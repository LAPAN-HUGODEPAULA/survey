"""Populate the optional question label metadata from existing prompts."""

from __future__ import annotations

import os
import re
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


def _derive_label(question_text: str | None) -> str | None:
    if not question_text:
        return None
    cleaned = question_text.strip()
    if not cleaned:
        return None
    cleaned = re.sub(r"\s+", " ", cleaned)
    cleaned = cleaned.strip(".?!")
    if not cleaned:
        return None
    words = cleaned.split(" ")
    candidate = " ".join(words[:5])
    return candidate[:42].strip()


def main() -> None:
    client = MongoClient(_resolve_mongo_uri(), serverSelectionTimeoutMS=5000)
    db = client[_resolve_db_name()]
    surveys = db["surveys"]
    updated_surveys = 0
    total_labels = 0
    try:
        for survey in surveys.find():
            questions = survey.get("questions")
            if not isinstance(questions, list):
                continue
            modified = False
            for question in questions:
                if not isinstance(question, dict):
                    continue
                if question.get("label"):
                    continue
                label = _derive_label(question.get("questionText"))
                if label:
                    question["label"] = label
                    modified = True
                    total_labels += 1
            if modified:
                surveys.update_one(
                    {"_id": survey.get("_id")},
                    {"$set": {"questions": questions}},
                )
                updated_surveys += 1
    finally:
        client.close()
    timestamp = datetime.utcnow().isoformat()
    print(f"[{timestamp}] Updated {updated_surveys} surveys with {total_labels} new labels.")


if __name__ == "__main__":
    main()
