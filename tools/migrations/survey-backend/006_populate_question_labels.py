"""Populate the optional question label metadata from existing prompts."""

from __future__ import annotations

import re
from datetime import datetime

from pymongo import MongoClient
from _env import load_migration_env, resolve_mongo_db_name, resolve_mongo_uri


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
    load_migration_env()
    client = MongoClient(resolve_mongo_uri(), serverSelectionTimeoutMS=5000)
    db = client[resolve_mongo_db_name()]
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
