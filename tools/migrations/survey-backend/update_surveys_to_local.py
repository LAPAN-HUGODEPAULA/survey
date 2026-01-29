import json
import os
from datetime import datetime
from urllib.parse import urlparse

from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
if not MONGO_URI:
    print("MONGO_URI not found, falling back to local MongoDB connection.")
    mongo_username = os.getenv("MONGO_USERNAME")
    mongo_password = os.getenv("MONGO_PASSWORD")
    if mongo_username and mongo_password:
        MONGO_URI = f"mongodb://{mongo_username}:{mongo_password}@localhost:27017/"
    else:
        MONGO_URI = "mongodb://localhost:27017/"
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

client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)

db = client[os.getenv("MONGO_DB_NAME", "survey_db")]
SYSTEM_SCREENER_ID = "000000000000000000000001"

script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(os.path.dirname(os.path.dirname(script_dir)))


def resolve_assets_dir() -> str:
    candidates = [
        os.path.join(project_root, "apps", "survey-frontend", "assets"),
        os.path.join(project_root, "apps", "survey-patient", "assets"),
    ]
    for candidate in candidates:
        surveys_dir = os.path.join(candidate, "surveys")
        if os.path.isdir(surveys_dir):
            return candidate
    raise FileNotFoundError(
        "Assets directory not found. Expected surveys under apps/survey-frontend/assets or apps/survey-patient/assets."
    )


def _parse_datetime(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        normalized = value.replace(" ", "T")
        return datetime.fromisoformat(normalized)
    except ValueError:
        return None


def update_surveys_only() -> None:
    assets_dir = resolve_assets_dir()
    surveys_dir = os.path.join(assets_dir, "surveys")
    surveys_collection = db["surveys"]

    print(f"Updating surveys from: {surveys_dir}")

    for filename in os.listdir(surveys_dir):
        if not filename.endswith(".json"):
            continue
        filepath = os.path.join(surveys_dir, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            survey_data = json.load(f)

        survey_id = survey_data.get("_id") or survey_data.get("id")
        if not survey_id:
            print(f"  - Skipping '{filename}': missing _id")
            continue

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

        surveys_collection.replace_one({"_id": survey_id}, survey_data, upsert=True)
        print(f"  - Upserted survey '{survey_id}'")

    print("Survey update completed.")


if __name__ == "__main__":
    try:
        client.admin.command("ping")
        print("Pinged your deployment. You successfully connected to MongoDB!")
    except Exception as e:
        print(e)

    update_surveys_only()
