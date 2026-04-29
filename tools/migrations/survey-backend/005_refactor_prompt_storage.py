"""Backfill QuestionnairePrompts and PersonaSkills from the legacy prompt storage model."""

from __future__ import annotations

from datetime import datetime, timezone

from pymongo import MongoClient

from _env import load_migration_env, resolve_mongo_db_name, resolve_mongo_uri
from prompt_catalog_seed import (
    build_persona_skill_documents,
    build_questionnaire_prompt_documents,
)

QUESTIONNAIRE_PROMPTS_COLLECTION = "QuestionnairePrompts"
PERSONA_SKILLS_COLLECTION = "PersonaSkills"
LEGACY_SURVEY_PROMPTS_COLLECTION = "survey_prompts"


def main() -> None:
    load_migration_env()
    client = MongoClient(resolve_mongo_uri(), serverSelectionTimeoutMS=5000)
    db = client[resolve_mongo_db_name()]
    try:
        questionnaire_prompts = db[QUESTIONNAIRE_PROMPTS_COLLECTION]
        persona_skills = db[PERSONA_SKILLS_COLLECTION]
        questionnaire_prompts.create_index("promptKey", unique=True)
        persona_skills.create_index("personaSkillKey", unique=True)
        persona_skills.create_index("outputProfile", unique=True)
        timestamp = datetime.now(timezone.utc)

        for normalized in build_questionnaire_prompt_documents(
            "005_refactor_prompt_storage",
            timestamp=timestamp,
        ):
            questionnaire_prompts.replace_one(
                {"promptKey": normalized["promptKey"]},
                normalized,
                upsert=True,
            )
            db[LEGACY_SURVEY_PROMPTS_COLLECTION].replace_one(
                {"promptKey": normalized["promptKey"]},
                normalized,
                upsert=True,
            )

        for persona in build_persona_skill_documents(
            "005_refactor_prompt_storage",
            timestamp=timestamp,
        ):
            persona_skills.replace_one(
                {"personaSkillKey": persona["personaSkillKey"]},
                persona,
                upsert=True,
            )
    finally:
        client.close()


if __name__ == "__main__":
    main()
