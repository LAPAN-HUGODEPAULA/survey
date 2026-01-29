from datetime import datetime, UTC
import os

import bcrypt
from bson import ObjectId
from pymongo import MongoClient
from dotenv import load_dotenv
from urllib.parse import urlparse

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
if not MONGO_URI:
    root_user = os.getenv("MONGO_INITDB_ROOT_USERNAME")
    root_pass = os.getenv("MONGO_INITDB_ROOT_PASSWORD")
    if root_user and root_pass:
        MONGO_URI = (
            f"mongodb://{root_user}:{root_pass}@localhost:27017/?authSource=admin"
        )
    else:
        MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")

MONGO_DB_NAME = os.getenv("MONGO_DB_NAME", "survey_db")

if MONGO_URI and MONGO_URI.startswith(("mongodb://", "mongodb+srv://")):
    parsed = urlparse(MONGO_URI)
    if parsed.hostname == "mongodb":
        host = "localhost"
        if parsed.port:
            host = f"{host}:{parsed.port}"
        auth = f"{parsed.username}:{parsed.password}@" if parsed.username else ""
        MONGO_URI = f"{parsed.scheme}://{auth}{host}{parsed.path or '/'}"
SYSTEM_SCREENER_ID = "000000000000000000000001"
SYSTEM_SCREENER_EMAIL = "lapan.hugodepaula@gmail.com"

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

def upgrade():
    client = MongoClient(MONGO_URI)
    db = client[MONGO_DB_NAME]
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

    client.close()

def downgrade():
    client = MongoClient(MONGO_URI)
    db = client[MONGO_DB_NAME]
    
    # Remove System Screener
    db["screeners"].delete_one({"_id": ObjectId(SYSTEM_SCREENER_ID)})
    db["screeners"].delete_one({"email": SYSTEM_SCREENER_EMAIL})
    print(f"System Screener removed (id: {SYSTEM_SCREENER_ID}).")

    # Remove Sample Screener
    db["screeners"].delete_one({"email": "maria.vale@holhos.com"})
    print("Sample Screener removed.")

    # Drop the collection (optional, depending on desired downgrade behavior)
    # db.drop_collection("screeners")
    # print("Screeners collection dropped.")

    client.close()

if __name__ == "__main__":
    # This block is for local testing of the migration
    # In a real migration system, you'd have a runner that calls upgrade/downgrade
    print("Running upgrade...")
    upgrade()
    print("Upgrade finished.")
    # print("\nRunning downgrade...")
    # downgrade()
    # print("Downgrade finished.")
