# filepath: migrate_to_mongo.py
import json
import os
import logging
from pymongo import MongoClient
from dotenv import load_dotenv
from datetime import datetime

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
    MONGO_URI = f'mongodb://{MONGO_USERNAME}:{MONGO_PASSWORD}@localhost:27017/'

print("Connecting to MongoDB...")
client = MongoClient(MONGO_URI)

# Send a ping to confirm a successful connection
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)

db = client['survey_db']

# --- Caminhos para os dados ---
# Get the absolute path of the script's directory
script_dir = os.path.dirname(os.path.abspath(__file__))
# Go up two levels to the project root from db/migrate/
project_root = os.path.dirname(os.path.dirname(script_dir))

SURVEYS_DIR = os.path.join(project_root, 'survey_app', 'assets', 'surveys')
RESPONSES_DIR = os.path.join(project_root, 'survey_app', 'assets', 'survey_responses')

def migrate_surveys():
    """Lê os arquivos de questionários e os insere na coleção 'surveys'."""
    print("Migrando questionários...")
    surveys_collection = db['surveys']
    surveys_collection.delete_many({}) # Limpa a coleção antes de inserir

    for filename in os.listdir(SURVEYS_DIR):
        if filename.endswith('.json'):
            filepath = os.path.join(SURVEYS_DIR, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                survey_data = json.load(f)
                survey_data['createdAt'] = datetime.fromisoformat(survey_data.get('createdAt')).date().isoformat()
                survey_data['modifiedAt'] = datetime.fromisoformat(survey_data.get('modifiedAt')).date().isoformat()
                # Inserir no banco de dados
                surveys_collection.insert_one(survey_data)
                print(f"  - Questionário '{survey_data['_id']}' inserido.")
    print("Migração de questionários concluída.\n")


def migrate_responses():
    """Lê os arquivos de respostas e insere as respostas.""" 
    print("Migrando respostas...")
    responses_collection = db['survey_responses']
    responses_collection.delete_many({})
    try:
        # Drop the old unique index
        responses_collection.drop_index("patient.name_1_patient.birthDate_1_testDate_1")
        print("Índice único existente foi removido.")
    except Exception as e:
        # Index might not exist, which is fine
        print(f"Não foi possível remover o índice (pode não existir): {e}")
    
    # Create the new non-unique index
    responses_collection.create_index([("patient.name", 1), ("patient.birthDate", 1), ("testDate", 1)])
    print("Novo índice não-único foi criado.")

    for filename in os.listdir(RESPONSES_DIR):
        if filename.endswith('.json'):
            filepath = os.path.join(RESPONSES_DIR, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                result_data = json.load(f)

                # Extrair informações do participante do resultado
                participant_name = result_data.get('patient', {}).get('name', 'Participante Anônimo')
                participant_birth_date = result_data.get('patient', {}).get('birthDate') # Pode ser None se não existir

                if not participant_birth_date or not participant_name:
                    print(f"  - AVISO: Data de nascimento ou nome não encontrados para o participante no arquivo '{filename}'. Pulando.")
                    continue

                # Montar o documento de resposta
                response_doc = {
                    'surveyId': result_data.get('surveyId'),
                    'creatorName': result_data.get('creatorName'),
                    'creatorContact': result_data.get('creatorContact'),
                    'testDate': datetime.fromisoformat(result_data.get('testDate').replace(" ", "T")),
                    'screenerName': result_data.get('screenerName', ''),
                    'screenerEmail': result_data.get('screenerEmail', ''),
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

                responses_collection.insert_one(response_doc)
                print(f"  - Respostas de questionário '{response_doc['surveyId']}' inseridas.")
    print("Migração de resultados concluída.\n")


if __name__ == '__main__':
    migrate_surveys()
    migrate_responses()
    print("Todos os dados foram migrados para o MongoDB com sucesso!")
