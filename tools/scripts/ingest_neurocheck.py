#!/usr/bin/env python3
"""Standalone script to ingest the NeuroCheck questionnaire into MongoDB."""

import json
import logging
from datetime import datetime, UTC
from pathlib import Path
import sys

# Add migrations directory to path to reuse _env
sys.path.append(str(Path(__file__).resolve().parent.parent / "migrations" / "survey-backend"))

try:
    from _env import load_migration_env, resolve_mongo_db_name, resolve_mongo_uri
    from pymongo import MongoClient
except ImportError:
    print("Error: Could not import dependencies. Ensure pymongo is installed and the migration environment is accessible.")
    sys.exit(1)

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("ingest_neurocheck")

DEFAULT_NEUROCHECK_INSTRUCTION_ANSWERS = [
    "Com base no quanto a situação acontece no seu dia a dia.",
    "Com base no quanto a situação é emocionalmente desagradável.",
    "Com base no seu nível de desconforto físico.",
]


def _normalize_neurocheck_instructions(survey_data: dict) -> None:
    instructions = survey_data.get("instructions")
    if not isinstance(instructions, dict):
        survey_data["instructions"] = {
            "preamble": "",
            "questionText": "",
            "answers": list(DEFAULT_NEUROCHECK_INSTRUCTION_ANSWERS),
        }
        return

    answers = instructions.get("answers")
    if not isinstance(answers, list) or not answers:
        instructions["answers"] = list(DEFAULT_NEUROCHECK_INSTRUCTION_ANSWERS)

def main():
    load_migration_env()
    mongo_uri = resolve_mongo_uri()
    db_name = resolve_mongo_db_name()
    
    client = MongoClient(mongo_uri)
    db = client[db_name]
    
    # Path to the new questionnaire
    json_path = Path(__file__).resolve().parent.parent.parent / "apps" / "survey-patient" / "assets" / "surveys" / "neurocheck.json"
    
    if not json_path.exists():
        logger.error(f"File not found: {json_path}")
        sys.exit(1)
        
    with open(json_path, "r", encoding="utf-8") as f:
        survey_data = json.load(f)

    _normalize_neurocheck_instructions(survey_data)
        
    # 1. Ingest Questionnaire
    logger.info(f"Ingesting questionnaire: {survey_data['_id']}")
    # Normalize dates
    survey_data["createdAt"] = datetime.now(UTC)
    survey_data["modifiedAt"] = datetime.now(UTC)
    
    db.surveys.replace_one({"_id": survey_data["_id"]}, survey_data, upsert=True)
    logger.info("Questionnaire upserted successfully.")
    
    # 2. Ingest Prompt
    prompt_key = survey_data.get("prompt", {}).get("promptKey", "neurocheck")
    prompt_payload = {
        "promptKey": prompt_key,
        "name": "NeuroCheck Clinical Report",
        "promptText": (
            "Você receberá um JSON com o questionário NeuroCheck (Indicador de Saúde Mental e Sensorial) "
            "e deverá produzir um laudo clínico estruturado em português brasileiro. "
            "Analise os 4 eixos (Fotosensibilidade, Visuomotor, Filtros, Biológico) e identifique sinais "
            "de sobrecarga biológica (total > 24). Mantenha um tom técnico, objetivo e clínico."
        ),
        "createdAt": datetime.now(UTC),
        "modifiedAt": datetime.now(UTC),
        "legacySource": "ingest_neurocheck_script"
    }
    
    db.survey_prompts.replace_one({"promptKey": prompt_key}, prompt_payload, upsert=True)
    db.QuestionnairePrompts.replace_one({"promptKey": prompt_key}, prompt_payload, upsert=True)
    logger.info(f"Clinical prompt '{prompt_key}' upserted successfully.")
    
    logger.info("Ingestion completed.")
    client.close()

if __name__ == "__main__":
    main()
