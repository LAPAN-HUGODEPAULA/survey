"""Seed starter questionnaire prompts and persona skills without clobbering custom edits."""

from __future__ import annotations

from datetime import datetime, timezone

from pymongo import MongoClient

from _env import load_migration_env, resolve_mongo_db_name, resolve_mongo_uri
from prompt_catalog_seed import (
    build_persona_skill_documents,
    build_questionnaire_prompt_documents,
    should_refresh_seeded_persona,
    should_refresh_seeded_prompt,
)


QUESTIONNAIRE_PROMPTS_COLLECTION = "QuestionnairePrompts"
LEGACY_SURVEY_PROMPTS_COLLECTION = "survey_prompts"
PERSONA_SKILLS_COLLECTION = "PersonaSkills"


def _upsert_prompt_catalog(db) -> tuple[int, int, int]:
    prompts = db[QUESTIONNAIRE_PROMPTS_COLLECTION]
    legacy_prompts = db[LEGACY_SURVEY_PROMPTS_COLLECTION]
    prompts.create_index("promptKey", unique=True)
    legacy_prompts.create_index("promptKey", unique=True)

    inserted = 0
    refreshed = 0
    skipped = 0
    timestamp = datetime.now(timezone.utc)

    for payload in build_questionnaire_prompt_documents(
        "008_seed_starter_prompt_catalog",
        timestamp=timestamp,
    ):
        prompt_key = payload["promptKey"]
        existing_primary = prompts.find_one({"promptKey": prompt_key})
        if not should_refresh_seeded_prompt(existing_primary, prompt_key):
            skipped += 1
            continue

        created_at = (
            existing_primary.get("createdAt")
            if existing_primary and existing_primary.get("createdAt")
            else payload["createdAt"]
        )
        merged_payload = {
            **payload,
            "createdAt": created_at,
            "modifiedAt": timestamp,
        }
        prompts.replace_one({"promptKey": prompt_key}, merged_payload, upsert=True)
        legacy_prompts.replace_one({"promptKey": prompt_key}, merged_payload, upsert=True)
        if existing_primary is None:
            inserted += 1
        else:
            refreshed += 1

    return inserted, refreshed, skipped


def _upsert_persona_catalog(db) -> tuple[int, int, int]:
    personas = db[PERSONA_SKILLS_COLLECTION]
    personas.create_index("personaSkillKey", unique=True)
    personas.create_index("outputProfile", unique=True)

    inserted = 0
    refreshed = 0
    skipped = 0
    timestamp = datetime.now(timezone.utc)

    for payload in build_persona_skill_documents(
        "008_seed_starter_prompt_catalog",
        timestamp=timestamp,
    ):
        persona_key = payload["personaSkillKey"]
        existing = personas.find_one({"personaSkillKey": persona_key})
        if not should_refresh_seeded_persona(existing, persona_key):
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
        personas.replace_one({"personaSkillKey": persona_key}, merged_payload, upsert=True)
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
        prompt_counts = _upsert_prompt_catalog(db)
        persona_counts = _upsert_persona_catalog(db)
        print(
            "Starter prompt catalog seed complete: "
            f"questionnaire prompts inserted={prompt_counts[0]}, "
            f"refreshed={prompt_counts[1]}, skipped={prompt_counts[2]}; "
            f"persona skills inserted={persona_counts[0]}, "
            f"refreshed={persona_counts[1]}, skipped={persona_counts[2]}"
        )
    finally:
        client.close()


if __name__ == "__main__":
    main()
