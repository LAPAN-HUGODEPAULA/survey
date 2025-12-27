from pydantic import BaseModel
import os

class Settings(BaseModel):
    # Mongo
    mongo_uri: str = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    mongo_db_name: str = os.getenv("MONGO_DB_NAME", "survey_db")

    # Clinical Writer (kept for later; do not refactor in this task)
    clinical_writer_url: str = os.getenv("CLINICAL_WRITER_URL", "http://clinical_writer_agent:8000/process")
    clinical_writer_token: str | None = os.getenv("CLINICAL_WRITER_API_TOKEN")

    # Email (kept for later)
    smtp_host: str | None = os.getenv("SMTP_HOST")
    smtp_port: int = int(os.getenv("SMTP_PORT", "587"))
    smtp_user: str | None = os.getenv("SMTP_USER")
    smtp_password: str | None = os.getenv("SMTP_PASSWORD")

settings = Settings()
