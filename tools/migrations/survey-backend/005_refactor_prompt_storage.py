"""Backfill QuestionnairePrompts and PersonaSkills from the legacy prompt storage model."""

from __future__ import annotations

from datetime import UTC, datetime

from pymongo import MongoClient

from _env import load_migration_env, resolve_mongo_db_name, resolve_mongo_uri


DEFAULT_SURVEY_PROMPT_KEY = "survey7"
DEFAULT_SURVEY_PROMPT_NAME = "Structured Survey Clinical Report"
DEFAULT_SURVEY_PROMPT_TEXT = (
    "Você receberá um JSON com um questionário aplicado e deverá produzir um laudo "
    "clínico estruturado em português brasileiro. "
    "Use apenas os dados presentes no JSON, não invente fatos e mantenha linguagem técnica."
)
QUESTIONNAIRE_PROMPTS_COLLECTION = "QuestionnairePrompts"
PERSONA_SKILLS_COLLECTION = "PersonaSkills"
LEGACY_SURVEY_PROMPTS_COLLECTION = "survey_prompts"
DEFAULT_PERSONA_SKILLS = [
    {
        "personaSkillKey": "patient_condition_overview",
        "name": "Patient Condition Overview",
        "outputProfile": "patient_condition_overview",
        "instructions": (
            "Write a concise patient-facing clinical summary in Brazilian Portuguese. "
            "Keep the tone calm, conservative, and free of school-specific language."
        ),
    },
    {
        "personaSkillKey": "clinical_diagnostic_report",
        "name": "Clinical Diagnostic Report",
        "outputProfile": "clinical_diagnostic_report",
        "instructions": (
            "Write in formal clinical language appropriate for the medical record. "
            "Emphasize evidence, uncertainty, and objective interpretation."
        ),
    },
    {
        "personaSkillKey": "clinical_referral_letter",
        "name": "Clinical Referral Letter",
        "outputProfile": "clinical_referral_letter",
        "instructions": (
            "Write as a formal referral letter in Brazilian Portuguese. "
            "Highlight the referral rationale, key findings, and next-step recommendations."
        ),
    },
    {
        "personaSkillKey": "parental_guidance",
        "name": "Parental Guidance",
        "outputProfile": "parental_guidance",
        "instructions": (
            "Write for caregivers in clear and supportive language. "
            "Preserve clinical accuracy while avoiding unnecessarily technical terms."
        ),
    },
    {
        "personaSkillKey": "school_report",
        "name": "School Report Persona",
        "outputProfile": "school_report",
        "instructions": (
            "Write for a school team in formal collaborative language. "
            "Focus on functional impact, classroom support needs, and respectful tone."
        ),
    },
]


def _normalize_questionnaire_prompt(document: dict) -> dict:
    timestamp = document.get("modifiedAt") or document.get("createdAt") or datetime.now(UTC)
    return {
        "promptKey": document.get("promptKey") or DEFAULT_SURVEY_PROMPT_KEY,
        "name": document.get("name") or DEFAULT_SURVEY_PROMPT_NAME,
        "promptText": document.get("promptText") or DEFAULT_SURVEY_PROMPT_TEXT,
        "createdAt": document.get("createdAt") or timestamp,
        "modifiedAt": timestamp,
        "legacySource": LEGACY_SURVEY_PROMPTS_COLLECTION,
    }


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

        legacy_prompts = list(db[LEGACY_SURVEY_PROMPTS_COLLECTION].find())
        if not legacy_prompts:
            legacy_prompts = [
                {
                    "promptKey": DEFAULT_SURVEY_PROMPT_KEY,
                    "name": DEFAULT_SURVEY_PROMPT_NAME,
                    "promptText": DEFAULT_SURVEY_PROMPT_TEXT,
                    "createdAt": datetime.now(UTC),
                    "modifiedAt": datetime.now(UTC),
                }
            ]

        for prompt in legacy_prompts:
            normalized = _normalize_questionnaire_prompt(prompt)
            questionnaire_prompts.replace_one(
                {"promptKey": normalized["promptKey"]},
                normalized,
                upsert=True,
            )

        for persona in DEFAULT_PERSONA_SKILLS:
            persona_skills.replace_one(
                {"personaSkillKey": persona["personaSkillKey"]},
                {
                    **persona,
                    "createdAt": datetime.now(UTC),
                    "modifiedAt": datetime.now(UTC),
                },
                upsert=True,
            )
    finally:
        client.close()


if __name__ == "__main__":
    main()
