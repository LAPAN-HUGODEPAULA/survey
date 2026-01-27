from pymongo import MongoClient
import bcrypt
from datetime import datetime
import os

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME", "survey_db")

def create_system_screener_data():
    system_screener_password = os.getenv("SYSTEM_SCREENER_PASSWORD", "SystemPassword123!")
    hashed_password = bcrypt.hashpw(system_screener_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    return {
        "cpf": "00000000000",
        "firstName": "LAPAN",
        "surname": "System Screener",
        "email": "lapan.hugodepaula@gmail.com",
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
        "createdAt": datetime.utcnow(),
        "updatedAt": datetime.utcnow(),
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
        "createdAt": datetime.utcnow(),
        "updatedAt": datetime.utcnow(),
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
    if not screeners_collection.find_one({"email": system_screener_data["email"]}):
        screeners_collection.insert_one(system_screener_data)
        print(f"System Screener inserted with email: {system_screener_data['email']}")
    else:
        print(f"System Screener with email {system_screener_data['email']} already exists.")

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
    db["screeners"].delete_one({"email": "lapan.hugodepaula@gmail.com"})
    print("System Screener removed.")

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
