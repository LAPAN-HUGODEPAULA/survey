from pydantic import BaseModel
import os

class Settings(BaseModel):
    # Mongo
    mongo_uri: str = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    mongo_db_name: str = os.getenv("MONGO_DB_NAME", "survey_db")

    # Clinical Writer (kept for later; do not refactor in this task)
    clinical_writer_url: str = os.getenv("CLINICAL_WRITER_URL", "http://clinical_writer_agent:8000/process")
    clinical_writer_token: str | None = os.getenv("CLINICAL_WRITER_API_TOKEN")
    clinical_writer_transcription_url: str | None = os.getenv("CLINICAL_WRITER_TRANSCRIPTION_URL")

    # Email (kept for later)
    smtp_host: str | None = os.getenv("SMTP_HOST") or os.getenv("MAIL_SERVER")
    smtp_port: int = int(os.getenv("SMTP_PORT") or os.getenv("MAIL_PORT", "587"))
    smtp_user: str | None = os.getenv("SMTP_USER") or os.getenv("MAIL_USERNAME")
    smtp_password: str | None = os.getenv("SMTP_PASSWORD") or os.getenv("MAIL_PASSWORD")

    # JWT Settings (Added)
    SECRET_KEY: str = os.getenv("SECRET_KEY", "super-secret-key") # TODO: Change in production
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))

    # Environment
    environment: str = os.getenv("ENVIRONMENT", "development")
    template_admin_emails: list[str] = [
        email.strip()
        for email in os.getenv("TEMPLATE_ADMIN_EMAILS", "").split(",")
        if email.strip()
    ]
    privacy_admin_token: str = os.getenv("PRIVACY_ADMIN_TOKEN", "dev-privacy-token")
    encryption_key_id: str | None = os.getenv("ENCRYPTION_KEY_ID")
    encryption_provider: str | None = os.getenv("ENCRYPTION_PROVIDER")

    @property
    def is_production(self) -> bool:
        return self.environment.lower() in {"prod", "production"}

settings = Settings()
