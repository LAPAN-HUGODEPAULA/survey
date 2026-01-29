# filepath: tools/migrations/survey-backend/002_consolidated_migration.py
import json
import os
import logging
from pymongo import MongoClient
from dotenv import load_dotenv
from datetime import datetime, UTC
from urllib.parse import urlparse
import bcrypt
from bson import ObjectId

# Configure logging for migration script
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(f'migration_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log')
    ]
)

logger = logging.getLogger("migration")

load_dotenv()

# --- Configuração da Conexão ---
MONGO_URI = os.getenv("MONGO_URI")
if not MONGO_URI:
    # Fallback to old method for local development if MONGO_URI is not set
    print("MONGO_URI not found, falling back to local MongoDB connection.")
    MONGO_USERNAME = os.getenv("MONGO_USERNAME")
    MONGO_PASSWORD = os.getenv("MONGO_PASSWORD")
    if MONGO_USERNAME and MONGO_PASSWORD:
        MONGO_URI = f'mongodb://{MONGO_USERNAME}:{MONGO_PASSWORD}@localhost:27017/'
    else:
        MONGO_URI = 'mongodb://localhost:27017/'
elif not MONGO_URI.startswith(("mongodb://", "mongodb+srv://")):
    MONGO_URI = f"mongodb://{MONGO_URI}"
else:
    parsed = urlparse(MONGO_URI)
    if parsed.hostname == "mongodb":
        host = "localhost"
        if parsed.port:
            host = f"{host}:{parsed.port}"
        auth = f"{parsed.username}:{parsed.password}@" if parsed.username else ""
        MONGO_URI = f"{parsed.scheme}://{auth}{host}{parsed.path or '/'}"

print("Connecting to MongoDB...")
client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)

# Send a ping to confirm a successful connection
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)

MONGO_DB_NAME = os.getenv("MONGO_DB_NAME", "survey_db")
db = client[MONGO_DB_NAME]
SYSTEM_SCREENER_ID = "000000000000000000000001"
SYSTEM_SCREENER_EMAIL = "lapan.hugodepaula@gmail.com"

# --- Caminhos para os dados ---
# Get the absolute path of the script's directory
script_dir = os.path.dirname(os.path.abspath(__file__))
# Go up three levels to the project root from tools/migrations/survey-backend/
project_root = os.path.dirname(os.path.dirname(os.path.dirname(script_dir)))

def resolve_assets_dir() -> str:
    candidates = [
        os.path.join(project_root, 'apps', 'survey-frontend', 'assets'),
        os.path.join(project_root, 'apps', 'survey-patient', 'assets'),
    ]
    for candidate in candidates:
        surveys_dir = os.path.join(candidate, 'surveys')
        responses_dir = os.path.join(candidate, 'survey_responses')
        if os.path.isdir(surveys_dir) and os.path.isdir(responses_dir):
            return candidate
    raise FileNotFoundError(
        "Assets directory not found. Expected surveys and survey_responses under "
        "apps/survey-frontend/assets or apps/survey-patient/assets."
    )

assets_dir = resolve_assets_dir()
SURVEYS_DIR = os.path.join(assets_dir, 'surveys')
RESPONSES_DIR = os.path.join(assets_dir, 'survey_responses')

def _parse_datetime(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        normalized = value.replace(" ", "T")
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


def migrate_surveys():
    """Lê os arquivos de questionários e os insere na coleção 'surveys'."""
    print("Migrating surveys...")
    surveys_collection = db['surveys']
    surveys_collection.delete_many({}) # Limpa a coleção antes de inserir

    for filename in os.listdir(SURVEYS_DIR):
        if filename.endswith('.json'):
            filepath = os.path.join(SURVEYS_DIR, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                survey_data = json.load(f)
                survey_id = survey_data.get("_id") or survey_data.get("id")
                if survey_id:
                    survey_data["_id"] = survey_id
                survey_data.pop("id", None)
                creator_id = (
                    survey_data.get("creatorId")
                    or survey_data.get("creatorContact")
                    or survey_data.get("creatorName")
                    or SYSTEM_SCREENER_ID
                )
                survey_data["creatorId"] = creator_id
                created_at = _parse_datetime(survey_data.get("createdAt"))
                modified_at = _parse_datetime(survey_data.get("modifiedAt"))
                if created_at:
                    survey_data["createdAt"] = created_at
                if modified_at:
                    survey_data["modifiedAt"] = modified_at
                # Inserir no banco de dados
                surveys_collection.insert_one(survey_data)
                print(f"  - Survey '{survey_data['_id']}' inserted.")
    print("Survey migration finished.\n")


def migrate_responses():
    """Lê os arquivos de respostas e insere as respostas."""
    print("Migrating responses...")
    responses_collection = db['survey_responses']
    responses_collection.delete_many({})
    try:
        # Drop the old unique index
        responses_collection.drop_index("patient.name_1_patient.birthDate_1_testDate_1")
        print("Existing unique index removed.")
    except Exception as e:
        # Index might not exist, which is fine
        print(f"Could not remove index (it may not exist): {e}")

    # Create the new non-unique index
    responses_collection.create_index([("patient.name", 1), ("patient.birthDate", 1), ("testDate", 1)])
    print("New non-unique index created.")

    for filename in os.listdir(RESPONSES_DIR):
        if filename.endswith('.json'):
            filepath = os.path.join(RESPONSES_DIR, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                result_data = json.load(f)

                # Extrair informações do participante do resultado
                participant_name = result_data.get('patient', {}).get('name', 'Anonymous Participant')
                participant_birth_date = result_data.get('patient', {}).get('birthDate') # Pode ser None se não existir

                if not participant_birth_date or not participant_name:
                    print(f"  - WARNING: Birth date or name not found for participant in file '{filename}'. Skipping.")
                    continue

                # Montar o documento de resposta
                agent_response = _normalize_agent_response(
                    result_data.get("agentResponse") or result_data.get("agent_response")
                )
                response_doc = {
                    'surveyId': result_data.get('surveyId'),
                    'creatorId': result_data.get('creatorId')
                    or result_data.get('creatorContact')
                    or result_data.get('creatorName')
                    or '',
                    'testDate': _parse_datetime(result_data.get('testDate')),
                    'screenerId': result_data.get('screenerId') or SYSTEM_SCREENER_ID,
                    'patient': {
                        'name': participant_name,
                        'email': result_data.get('patient', {}).get('email'),
                        'birthDate': participant_birth_date,
                        'gender': result_data.get('patient', {}).get('gender'),
                        'ethnicity': result_data.get('patient', {}).get('ethnicity'),
                        'educationLevel': result_data.get('patient', {}).get('educationLevel', ''),
                        'profession': result_data.get('patient', {}).get('profession', ''),
                        'medication': result_data.get('patient', {}).get('medication'),
                        'diagnoses': result_data.get('patient', {}).get('diagnoses'),
                        'family_history': result_data.get('patient', {}).get('family_history', ''),
                        'social_history': result_data.get('patient', {}).get('social_history', ''),
                        'medical_history': result_data.get('patient', {}).get('medical_history', ''),
                        'medication_history': result_data.get('patient', {}).get('medication_history', ''),
                    },
                    'answers': result_data.get('answers'),
                }
                if agent_response:
                    response_doc["agentResponse"] = agent_response

                responses_collection.insert_one(response_doc)
                print(f"  - Survey responses '{response_doc['surveyId']}' inserted.")
    print("Response migration finished.\n")

def create_system_screener_data():
    system_screener_password = os.getenv("SYSTEM_SCREENER_PASSWORD", "SystemPassword123!")
    hashed_password = bcrypt.hashpw(system_screener_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

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
        "createdAt": datetime.now(UTC),
        "updatedAt": datetime.now(UTC),
    }

def create_sample_screener_data():
    sample_screener_password = os.getenv("SAMPLE_SCREENER_PASSWORD", "SamplePassword123!")
    hashed_password = bcrypt.hashpw(sample_screener_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

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
        "createdAt": datetime.now(UTC),
        "updatedAt": datetime.now(UTC),
    }

def migrate_screeners():
    """Creates the screeners collection, indexes, and inserts system and sample screeners."""
    print("Migrating screeners...")
    screeners_collection = db["screeners"]

    # Create unique indexes
    screeners_collection.create_index("cpf", unique=True)
    screeners_collection.create_index("email", unique=True)

    # Insert System Screener
    system_screener_data = create_system_screener_data()
    system_exists = screeners_collection.find_one({"_id": system_screener_data["_id"]}) or screeners_collection.find_one(
        {"email": system_screener_data["email"]}
    )
    if not system_exists:
        screeners_collection.insert_one(system_screener_data)
        print(f"System Screener inserted with id: {SYSTEM_SCREENER_ID}")
    else:
        print(f"System Screener already exists (id: {SYSTEM_SCREENER_ID}).")

    # Insert Sample Screener
    sample_screener_data = create_sample_screener_data()
    if not screeners_collection.find_one({"email": sample_screener_data["email"]}):
        screeners_collection.insert_one(sample_screener_data)
        print(f"Sample Screener inserted with email: {sample_screener_data['email']}")
    else:
        print(f"Sample Screener with email {sample_screener_data['email']} already exists.")
    print("Screener migration finished.\n")

def migrate_run_logs():
    """Create run log collection and indexes for clinical writer usage."""
    logs_collection = db["clinical_writer_run_logs"]
    logs_collection.create_index([("timestamp", 1)])
    logs_collection.create_index([("request_id", 1)])
    print("clinical_writer_run_logs collection ready with indexes.")

def main():
    """Main function to run all migrations."""
    try:
        migrate_surveys()
        migrate_responses()
        migrate_screeners()
        migrate_run_logs()
        print("All data has been migrated to MongoDB successfully!")
    except Exception as e:
        logger.error(f"An error occurred during migration: {e}", exc_info=True)
        print(f"An error occurred. Check the migration log for details.")
    finally:
        client.close()
        print("MongoDB connection closed.")


if __name__ == '__main__':
    main()
