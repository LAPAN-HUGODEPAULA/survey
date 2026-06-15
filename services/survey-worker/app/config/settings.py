"""Environment-driven settings for the survey worker."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime configuration for polling MongoDB and calling Clinical Writer."""

    model_config = SettingsConfigDict(case_sensitive=False, extra="ignore")

    mongo_uri: str = "mongodb://localhost:27017"
    mongo_db_name: str = "survey_db"
    poll_interval_seconds: int = 10
    batch_size: int = 10
    processing_stale_after_seconds: int = 60
    worker_max_retries: int = 1

    clinical_writer_url: str = "http://clinical_writer_agent:8000/process"
    clinical_writer_token: str | None = None
    http_timeout_seconds: int = 15
    log_payload_enabled: bool = False
    log_response_enabled: bool = False


settings = Settings()
