"""Environment-backed application settings."""

from pydantic import BaseModel
import os


def _parse_csv_env(value: str | None) -> list[str]:
    """Parse a comma-separated environment variable into a normalized list."""
    if not value:
        return []
    return [item.strip() for item in value.split(",") if item.strip()]


class Settings(BaseModel):
    """Centralizes runtime configuration loaded from environment variables."""

    # MongoDB connection settings.
    mongo_uri: str = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    mongo_db_name: str = os.getenv("MONGO_DB_NAME", "survey_db")

    # Clinical Writer integration settings.
    clinical_writer_url: str = os.getenv("CLINICAL_WRITER_URL", "http://clinical_writer_agent:8000/process")
    clinical_writer_token: str | None = os.getenv("CLINICAL_WRITER_API_TOKEN")
    clinical_writer_transcription_url: str | None = os.getenv("CLINICAL_WRITER_TRANSCRIPTION_URL")
    clinical_writer_http_timeout_seconds: int = int(
        os.getenv("CLINICAL_WRITER_HTTP_TIMEOUT_SECONDS", "120")
    )

    # Email delivery settings.
    smtp_host: str | None = os.getenv("SMTP_HOST") or os.getenv("MAIL_SERVER")
    smtp_port: int = int(os.getenv("SMTP_PORT") or os.getenv("MAIL_PORT", "587"))
    smtp_user: str | None = os.getenv("SMTP_USER") or os.getenv("MAIL_USERNAME")
    smtp_password: str | None = os.getenv("SMTP_PASSWORD") or os.getenv("MAIL_PASSWORD")

    # JWT signing settings.
    SECRET_KEY: str = os.getenv("SECRET_KEY", "super-secret-key")  # Replace in production.
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    builder_session_expire_minutes: int = int(
        os.getenv("BUILDER_SESSION_EXPIRE_MINUTES", "480")
    )
    builder_session_cookie_name: str = os.getenv(
        "BUILDER_SESSION_COOKIE_NAME",
        "survey_builder_session",
    )
    builder_csrf_cookie_name: str = os.getenv(
        "BUILDER_CSRF_COOKIE_NAME",
        "survey_builder_csrf",
    )
    builder_csrf_header_name: str = os.getenv(
        "BUILDER_CSRF_HEADER_NAME",
        "X-Builder-CSRF",
    )
    builder_cookie_domain: str | None = os.getenv("BUILDER_COOKIE_DOMAIN")

    # Environment and administrative controls.
    environment: str = os.getenv("ENVIRONMENT", "development")
    cors_allowed_origins_raw: str | None = os.getenv("CORS_ALLOWED_ORIGINS")
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
        """Return whether the current environment should enforce production safeguards."""
        return self.environment.lower() in {"prod", "production"}

    @property
    def cors_allowed_origins(self) -> list[str]:
        """Return the allowed browser origins for cross-origin requests."""
        configured = _parse_csv_env(self.cors_allowed_origins_raw)
        if configured:
            return configured
        return [
            "http://localhost",
            "http://127.0.0.1",
            "http://localhost:3000",
            "http://127.0.0.1:3000",
            "http://localhost:5173",
            "http://127.0.0.1:5173",
            "http://localhost:8080",
            "http://127.0.0.1:8080",
        ]

    @property
    def uses_insecure_secret_key(self) -> bool:
        """Return whether the JWT secret still uses the development fallback."""
        return self.SECRET_KEY == "super-secret-key"

    @property
    def uses_insecure_privacy_token(self) -> bool:
        """Return whether the privacy admin token still uses the development fallback."""
        return self.privacy_admin_token == "dev-privacy-token"

    def validate_runtime_security(self) -> None:
        """Fail fast when production runs with insecure defaults."""
        if not self.is_production:
            return
        if self.uses_insecure_secret_key:
            raise RuntimeError("SECRET_KEY must be configured in production.")
        if self.uses_insecure_privacy_token:
            raise RuntimeError("PRIVACY_ADMIN_TOKEN must be configured in production.")
        if not self.cors_allowed_origins:
            raise RuntimeError("CORS_ALLOWED_ORIGINS must be configured in production.")


settings = Settings()
