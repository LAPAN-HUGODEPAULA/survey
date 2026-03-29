"""Populate MongoDB with the current survey-backend schema and seed data."""

from __future__ import annotations

import json
import logging
import os
from datetime import UTC, datetime
from pathlib import Path

import bcrypt
from bson import ObjectId
from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.database import Database


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(f"migration_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"),
    ],
)
logger = logging.getLogger("migration_003")

load_dotenv()

SYSTEM_SCREENER_ID = "000000000000000000000001"
SYSTEM_SCREENER_EMAIL = "lapan.hugodepaula@gmail.com"
DEFAULT_SURVEY_PROMPT_KEY = "survey7"
DEFAULT_SURVEY_PROMPT_NAME = "Structured Survey Clinical Report"
DEFAULT_SURVEY_PROMPT_TEXT = """
Você receberá um JSON com um questionário aplicado e deverá produzir um laudo clínico estruturado em português brasileiro.

Regras:
- Use apenas os dados presentes no JSON.
- Não invente diagnósticos ou fatos não informados.
- Considere dados demográficos e histórico clínico quando existirem.
- Interprete as respostas do questionário de forma objetiva e conservadora.
- Produza um texto técnico, adequado para prontuário.
""".strip()

SURVEY_RESPONSES_COLLECTION = "survey_responses"
LEGACY_SURVEY_RESULTS_COLLECTION = "survey_results"
PATIENT_RESPONSES_COLLECTION = "patient_responses"
LEGACY_PATIENT_RESULTS_COLLECTION = "patient_results"
SURVEY_PROMPTS_COLLECTION = "survey_prompts"
QUESTIONNAIRE_PROMPTS_COLLECTION = "QuestionnairePrompts"
PERSONA_SKILLS_COLLECTION = "PersonaSkills"
MASTER_KEY_SECRET_RELATIVE_PATH = Path("config/runtime/generated/private/system-master-key.txt")
ANONYMIZED_PATIENT_RESPONSE_ID = ObjectId("000000000000000000000101")
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


MONGO_URI = _resolve_mongo_uri()
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME", "survey_db")
client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)

try:
    client.admin.command("ping")
    logger.info("Connected to MongoDB.")
except Exception as exc:  # pragma: no cover - operational guard
    logger.error("Could not connect to MongoDB: %s", exc)
    raise

db: Database = client[MONGO_DB_NAME]

script_dir = Path(__file__).resolve().parent
project_root = script_dir.parent.parent.parent


def resolve_assets_dir() -> Path:
    candidates = [
        project_root / "apps" / "survey-frontend" / "assets",
        project_root / "apps" / "survey-patient" / "assets",
    ]
    for candidate in candidates:
        if (candidate / "surveys").is_dir() and (candidate / "survey_responses").is_dir():
            return candidate
    raise FileNotFoundError(
        "Assets directory not found. Expected surveys and survey_responses under "
        "apps/survey-frontend/assets or apps/survey-patient/assets."
    )


assets_dir = resolve_assets_dir()
SURVEYS_DIR = assets_dir / "surveys"
RESPONSES_DIR = assets_dir / "survey_responses"


def _parse_datetime(value: object) -> datetime | None:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value
    text = str(value).strip()
    if not text:
        return None
    normalized = text.replace(" ", "T")
    if normalized.endswith("Z"):
        normalized = normalized[:-1] + "+00:00"
    try:
        return datetime.fromisoformat(normalized)
    except ValueError:
        return None


def _normalize_agent_response(payload: dict | None) -> dict | None:
    if not payload:
        return None
    report = payload.get("report")
    if isinstance(report, str):
        try:
            report = json.loads(report)
        except (TypeError, ValueError):
            report = None
    warnings = payload.get("warnings")
    if not isinstance(warnings, list):
        warnings = []
    return {
        "ok": payload.get("ok"),
        "input_type": payload.get("input_type"),
        "prompt_version": payload.get("prompt_version"),
        "model_version": payload.get("model_version"),
        "report": report,
        "warnings": warnings,
        "classification": payload.get("classification"),
        "medicalRecord": payload.get("medicalRecord") or payload.get("medical_record"),
        "errorMessage": payload.get("errorMessage") or payload.get("error_message"),
    }


def _normalize_patient(patient: dict | None) -> dict | None:
    if patient is None:
        return None
    if not isinstance(patient, dict):
        return None
    return {
        "name": patient.get("name") or "Anonymous Patient",
        "email": patient.get("email") or "anonymous.patient@example.invalid",
        "birthDate": patient.get("birthDate") or "1900-01-01",
        "gender": patient.get("gender") or "Not informed",
        "ethnicity": patient.get("ethnicity") or "Not informed",
        "educationLevel": patient.get("educationLevel") or "Not informed",
        "profession": patient.get("profession") or "Not informed",
        "medication": patient.get("medication") or [],
        "diagnoses": patient.get("diagnoses") or [],
        "family_history": patient.get("family_history") or "",
        "social_history": patient.get("social_history") or "",
        "medical_history": patient.get("medical_history") or "",
        "medication_history": patient.get("medication_history") or "",
    }


def _default_prompt_reference() -> dict[str, str]:
    return {
        "promptKey": DEFAULT_SURVEY_PROMPT_KEY,
        "name": DEFAULT_SURVEY_PROMPT_NAME,
    }


def _normalize_survey_doc(raw: dict) -> dict:
    survey_id = raw.get("_id") or raw.get("id")
    if not survey_id:
        raise ValueError("Survey document is missing an identifier.")

    prompt = raw.get("prompt")
    if isinstance(prompt, dict) and prompt.get("promptKey") and prompt.get("name"):
        normalized_prompt = {
            "promptKey": str(prompt["promptKey"]).strip(),
            "name": str(prompt["name"]).strip(),
        }
    else:
        associations = raw.get("promptAssociations") or []
        if isinstance(associations, list):
            first_association = next(
                (
                    item
                    for item in associations
                    if isinstance(item, dict) and item.get("promptKey") and item.get("name")
                ),
                None,
            )
        else:
            first_association = None
        normalized_prompt = (
            {
                "promptKey": str(first_association["promptKey"]).strip(),
                "name": str(first_association["name"]).strip(),
            }
            if first_association
            else _default_prompt_reference()
        )

    return {
        "_id": survey_id,
        "surveyDisplayName": raw.get("surveyDisplayName") or raw.get("surveyName") or str(survey_id),
        "surveyName": raw.get("surveyName") or raw.get("surveyDisplayName") or str(survey_id),
        "surveyDescription": raw.get("surveyDescription") or "",
        "creatorId": (
            raw.get("creatorId")
            or raw.get("creatorContact")
            or raw.get("creatorName")
            or SYSTEM_SCREENER_EMAIL
        ),
        "creatorName": raw.get("creatorName"),
        "creatorContact": raw.get("creatorContact"),
        "createdAt": _parse_datetime(raw.get("createdAt")) or datetime.now(UTC),
        "modifiedAt": _parse_datetime(raw.get("modifiedAt")) or datetime.now(UTC),
        "instructions": raw.get("instructions") or {},
        "questions": raw.get("questions") or [],
        "finalNotes": raw.get("finalNotes") or "",
        "prompt": normalized_prompt,
    }


def _normalize_response_doc(raw: dict, *, prompt_key: str) -> dict:
    normalized_id = raw.get("_id")
    output_profile = raw.get("outputProfile") or "patient_condition_overview"
    persona_skill_key = raw.get("personaSkillKey") or output_profile
    return {
        **({"_id": normalized_id} if normalized_id is not None else {}),
        "surveyId": raw.get("surveyId"),
        "creatorId": (
            raw.get("creatorId")
            or raw.get("creatorContact")
            or raw.get("creatorName")
            or SYSTEM_SCREENER_EMAIL
        ),
        "testDate": _parse_datetime(raw.get("testDate")) or datetime.now(UTC),
        "screenerId": raw.get("screenerId") or SYSTEM_SCREENER_ID,
        "accessLinkToken": raw.get("accessLinkToken"),
        "promptKey": raw.get("promptKey") or prompt_key,
        "personaSkillKey": persona_skill_key,
        "outputProfile": output_profile,
        "patient": _normalize_patient(raw.get("patient")),
        "answers": raw.get("answers") or [],
    }


def _response_signature(raw: dict) -> str:
    patient = raw.get("patient") if isinstance(raw.get("patient"), dict) else {}
    test_date = _parse_datetime(raw.get("testDate"))
    return "|".join(
        [
            str(raw.get("surveyId") or ""),
            str(raw.get("creatorId") or raw.get("creatorContact") or raw.get("creatorName") or ""),
            str(raw.get("screenerId") or ""),
            test_date.isoformat() if test_date else "",
            str(patient.get("name") or ""),
            str(patient.get("email") or ""),
            str(patient.get("birthDate") or ""),
        ]
    )


def _read_asset_surveys() -> list[dict]:
    surveys: list[dict] = []
    for filepath in sorted(SURVEYS_DIR.glob("*.json")):
        surveys.append(json.loads(filepath.read_text(encoding="utf-8")))
    return surveys


def _read_asset_responses() -> list[dict]:
    responses: list[dict] = []
    for filepath in sorted(RESPONSES_DIR.glob("*.json")):
        responses.append(json.loads(filepath.read_text(encoding="utf-8")))
    return responses


def _build_anonymized_patient_response() -> dict:
    sample_source = json.loads((RESPONSES_DIR / "lapan_q7_sabrina_oliveira.json").read_text(encoding="utf-8"))
    return {
        "_id": ANONYMIZED_PATIENT_RESPONSE_ID,
        "surveyId": sample_source.get("surveyId", "lapan_q7"),
        "creatorId": sample_source.get("creatorId") or SYSTEM_SCREENER_EMAIL,
        "testDate": datetime.now(UTC),
        "screenerId": SYSTEM_SCREENER_ID,
        "promptKey": DEFAULT_SURVEY_PROMPT_KEY,
        "patient": {
            "name": "Patient A-01",
            "email": "patient.a01@example.invalid",
            "birthDate": "1990-01-01",
            "gender": "Not informed",
            "ethnicity": "Not informed",
            "educationLevel": "Not informed",
            "profession": "Not informed",
            "medication": [],
            "diagnoses": [],
            "family_history": "Anonymized seed record for local development.",
            "social_history": "Anonymized seed record for local development.",
            "medical_history": "Anonymized seed record for local development.",
            "medication_history": "Anonymized seed record for local development.",
        },
        "answers": sample_source.get("answers") or [],
    }


def create_system_screener_data() -> dict:
    system_screener_password = os.getenv("SYSTEM_SCREENER_PASSWORD", "SystemPassword123!")
    hashed_password = bcrypt.hashpw(system_screener_password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    now = datetime.now(UTC)
    return {
        "_id": ObjectId(SYSTEM_SCREENER_ID),
        "cpf": "00000000000",
        "firstName": "LAPAN",
        "surname": "System Screener",
        "email": SYSTEM_SCREENER_EMAIL,
        "password": hashed_password,
        "phone": "31984831284",
        "address": {
            "postalCode": "34000000",
            "street": "Rua da Paisagem",
            "number": "220",
            "complement": "",
            "neighborhood": "Vale do Sereno",
            "city": "Nova Lima",
            "state": "MG",
        },
        "professionalCouncil": {
            "type": "none",
            "registrationNumber": "",
        },
        "jobTitle": "",
        "degree": "",
        "darvCourseYear": None,
        "createdAt": now,
        "updatedAt": now,
    }


def create_sample_screener_data() -> dict:
    sample_screener_password = os.getenv("SAMPLE_SCREENER_PASSWORD", "SamplePassword123!")
    hashed_password = bcrypt.hashpw(sample_screener_password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    now = datetime.now(UTC)
    return {
        "cpf": "11111111111",
        "firstName": "Maria",
        "surname": "Henriques Moreira Vale",
        "email": "maria.vale@holhos.com",
        "password": hashed_password,
        "phone": "31988447613",
        "address": {
            "postalCode": "27090639",
            "street": "Praça da Liberdade",
            "number": "932",
            "complement": "",
            "neighborhood": "Copacabana",
            "city": "Uberlândia",
            "state": "MG",
        },
        "professionalCouncil": {
            "type": "CRP",
            "registrationNumber": "12543",
        },
        "jobTitle": "Psychologist",
        "degree": "Psychology",
        "darvCourseYear": 2019,
        "createdAt": now,
        "updatedAt": now,
    }


def write_master_key_secret() -> None:
    system_screener_password = os.getenv("SYSTEM_SCREENER_PASSWORD", "SystemPassword123!")
    secret_path = project_root / MASTER_KEY_SECRET_RELATIVE_PATH
    secret_path.parent.mkdir(parents=True, exist_ok=True)
    content = "\n".join(
        [
            "System Screener Master Key",
            "==========================",
            "",
            f"Email: {SYSTEM_SCREENER_EMAIL}",
            f"Master key: {system_screener_password}",
            "",
            "Recovery options:",
            "1. Preferred: call POST /api/v1/screeners/recover-password with the system screener email.",
            "2. Local reset: rerun this migration with SYSTEM_SCREENER_PASSWORD set to the new desired value.",
            "3. Direct database reset: replace the stored bcrypt hash for the system screener document.",
            "",
            "This file is intentionally stored under config/runtime/generated/private so it stays outside git.",
        ]
    )
    secret_path.write_text(content, encoding="utf-8")
    logger.info("Master key note written to %s", secret_path)


def migrate_survey_prompts() -> None:
    logger.info("Migrating survey prompts...")
    prompts_collection = db[SURVEY_PROMPTS_COLLECTION]
    questionnaire_prompts_collection = db[QUESTIONNAIRE_PROMPTS_COLLECTION]
    prompts_collection.create_index("promptKey", unique=True)
    questionnaire_prompts_collection.create_index("promptKey", unique=True)
    payload = {
        "promptKey": DEFAULT_SURVEY_PROMPT_KEY,
        "name": DEFAULT_SURVEY_PROMPT_NAME,
        "promptText": DEFAULT_SURVEY_PROMPT_TEXT,
        "createdAt": datetime.now(UTC),
        "modifiedAt": datetime.now(UTC),
        "legacySource": "003_populate_new_schema",
    }
    prompts_collection.replace_one({"promptKey": DEFAULT_SURVEY_PROMPT_KEY}, payload, upsert=True)
    questionnaire_prompts_collection.replace_one(
        {"promptKey": DEFAULT_SURVEY_PROMPT_KEY},
        payload,
        upsert=True,
    )
    logger.info("Survey prompt catalog ready.")


def migrate_persona_skills() -> None:
    logger.info("Migrating persona skills...")
    persona_skills_collection = db[PERSONA_SKILLS_COLLECTION]
    persona_skills_collection.create_index("personaSkillKey", unique=True)
    persona_skills_collection.create_index("outputProfile", unique=True)
    for item in DEFAULT_PERSONA_SKILLS:
        persona_skills_collection.replace_one(
            {"personaSkillKey": item["personaSkillKey"]},
            {
                **item,
                "createdAt": datetime.now(UTC),
                "modifiedAt": datetime.now(UTC),
            },
            upsert=True,
        )
    logger.info("Persona skill catalog ready.")


def migrate_surveys() -> None:
    logger.info("Migrating surveys...")
    surveys_collection = db["surveys"]
    for raw_survey in _read_asset_surveys():
        normalized = _normalize_survey_doc(raw_survey)
        surveys_collection.replace_one({"_id": normalized["_id"]}, normalized, upsert=True)
        logger.info("Survey upserted: %s", normalized["_id"])

    for existing in surveys_collection.find():
        normalized = _normalize_survey_doc(existing)
        surveys_collection.replace_one({"_id": normalized["_id"]}, normalized, upsert=True)
    logger.info("Survey migration finished.")


def migrate_survey_responses() -> None:
    logger.info("Migrating survey responses...")
    source_docs: list[dict] = []

    if SURVEY_RESPONSES_COLLECTION in db.list_collection_names():
        source_docs.extend(list(db[SURVEY_RESPONSES_COLLECTION].find()))
    if LEGACY_SURVEY_RESULTS_COLLECTION in db.list_collection_names():
        source_docs.extend(list(db[LEGACY_SURVEY_RESULTS_COLLECTION].find()))
    if not source_docs:
        source_docs.extend(_read_asset_responses())

    survey_prompt_map = {
        item["_id"]: item.get("prompt", {}).get("promptKey", DEFAULT_SURVEY_PROMPT_KEY)
        for item in db["surveys"].find({}, {"prompt": 1})
    }

    deduplicated: list[dict] = []
    seen_signatures: set[str] = set()
    for raw_doc in source_docs:
        signature = _response_signature(raw_doc)
        if signature in seen_signatures:
            continue
        seen_signatures.add(signature)
        prompt_key = survey_prompt_map.get(raw_doc.get("surveyId"), DEFAULT_SURVEY_PROMPT_KEY)
        deduplicated.append(_normalize_response_doc(raw_doc, prompt_key=prompt_key))

    survey_responses = db[SURVEY_RESPONSES_COLLECTION]
    survey_responses.drop()
    if deduplicated:
        survey_responses.insert_many(deduplicated, ordered=True)
    survey_responses.create_index([("patient.name", 1), ("patient.birthDate", 1), ("testDate", 1)])
    survey_responses.create_index([("surveyId", 1), ("testDate", -1)])

    if LEGACY_SURVEY_RESULTS_COLLECTION in db.list_collection_names():
        db.drop_collection(LEGACY_SURVEY_RESULTS_COLLECTION)
        logger.info("Dropped legacy collection: %s", LEGACY_SURVEY_RESULTS_COLLECTION)

    logger.info("Survey response migration finished with %d documents.", len(deduplicated))


def migrate_patient_responses() -> None:
    logger.info("Migrating patient responses...")
    source_docs: list[dict] = []
    if PATIENT_RESPONSES_COLLECTION in db.list_collection_names():
        source_docs.extend(list(db[PATIENT_RESPONSES_COLLECTION].find()))
    if LEGACY_PATIENT_RESULTS_COLLECTION in db.list_collection_names():
        source_docs.extend(list(db[LEGACY_PATIENT_RESULTS_COLLECTION].find()))
    source_docs.append(_build_anonymized_patient_response())

    survey_prompt_map = {
        item["_id"]: item.get("prompt", {}).get("promptKey", DEFAULT_SURVEY_PROMPT_KEY)
        for item in db["surveys"].find({}, {"prompt": 1})
    }

    deduplicated: list[dict] = []
    seen_ids: set[object] = set()
    for raw_doc in source_docs:
        normalized_id = raw_doc.get("_id")
        if normalized_id in seen_ids:
            continue
        seen_ids.add(normalized_id)
        prompt_key = survey_prompt_map.get(raw_doc.get("surveyId"), DEFAULT_SURVEY_PROMPT_KEY)
        deduplicated.append(_normalize_response_doc(raw_doc, prompt_key=prompt_key))

    patient_responses = db[PATIENT_RESPONSES_COLLECTION]
    patient_responses.drop()
    if deduplicated:
        patient_responses.insert_many(deduplicated, ordered=True)
    patient_responses.create_index([("surveyId", 1), ("testDate", -1)])
    patient_responses.create_index([("patient.email", 1), ("testDate", -1)])
    if LEGACY_PATIENT_RESULTS_COLLECTION in db.list_collection_names():
        db.drop_collection(LEGACY_PATIENT_RESULTS_COLLECTION)
        logger.info("Dropped legacy collection: %s", LEGACY_PATIENT_RESULTS_COLLECTION)
    logger.info("Patient response migration finished with %d documents.", len(deduplicated))


def upsert_screeners() -> None:
    logger.info("Migrating screeners...")
    screeners_collection = db["screeners"]
    screeners_collection.create_index("cpf", unique=True)
    screeners_collection.create_index("email", unique=True)

    for payload in [create_system_screener_data(), create_sample_screener_data()]:
        existing = screeners_collection.find_one({"email": payload["email"]})
        if existing:
            payload["_id"] = existing["_id"]
            payload["createdAt"] = existing.get("createdAt", payload["createdAt"])
            payload["updatedAt"] = datetime.now(UTC)
            screeners_collection.replace_one({"_id": existing["_id"]}, payload)
            logger.info("Screener updated: %s", payload["email"])
            continue

        screeners_collection.insert_one(payload)
        logger.info("Screener inserted: %s", payload["email"])


def migrate_run_logs() -> None:
    logs_collection = db["clinical_writer_run_logs"]
    logs_collection.create_index([("timestamp", 1)])
    logs_collection.create_index([("request_id", 1)])
    logger.info("clinical_writer_run_logs collection ready.")


def log_final_state() -> None:
    for name in [
        "surveys",
        SURVEY_PROMPTS_COLLECTION,
        QUESTIONNAIRE_PROMPTS_COLLECTION,
        PERSONA_SKILLS_COLLECTION,
        SURVEY_RESPONSES_COLLECTION,
        PATIENT_RESPONSES_COLLECTION,
        "screeners",
        "clinical_writer_run_logs",
    ]:
        logger.info("%s count: %d", name, db[name].count_documents({}))


def main() -> None:
    try:
        write_master_key_secret()
        migrate_survey_prompts()
        migrate_persona_skills()
        migrate_surveys()
        migrate_survey_responses()
        migrate_patient_responses()
        upsert_screeners()
        migrate_run_logs()
        log_final_state()
        logger.info("Migration completed successfully.")
    except Exception as exc:  # pragma: no cover - operational guard
        logger.error("An error occurred during migration: %s", exc, exc_info=True)
        raise
    finally:
        client.close()
        logger.info("MongoDB connection closed.")


if __name__ == "__main__":
    main()
