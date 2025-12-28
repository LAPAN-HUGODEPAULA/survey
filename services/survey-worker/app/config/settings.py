"""Environment-driven settings for the survey worker."""

import os
from pydantic import BaseModel


class Settings(BaseModel):
    mongo_uri: str = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    mongo_db_name: str = os.getenv("MONGO_DB_NAME", "survey_db")
    poll_interval_seconds: int = int(os.getenv("POLL_INTERVAL_SECONDS", "10"))
    batch_size: int = int(os.getenv("BATCH_SIZE", "10"))

    clinical_writer_url: str = os.getenv("CLINICAL_WRITER_URL", "http://clinical_writer_agent:8000/process")
    clinical_writer_token: str | None = os.getenv("CLINICAL_WRITER_API_TOKEN")
    http_timeout_seconds: int = int(os.getenv("HTTP_TIMEOUT_SECONDS", "15"))


settings = Settings()

