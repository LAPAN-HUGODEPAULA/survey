"""Environment-backed application settings."""

from pydantic import AliasChoices, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


def _parse_csv_env(value: str | None) -> list[str]:
    """Parse a comma-separated environment variable into a normalized list."""
    if not value:
        return []
    return [item.strip() for item in value.split(",") if item.strip()]


class Settings(BaseSettings):
    """Centralizes runtime configuration loaded from environment variables."""

    model_config = SettingsConfigDict(case_sensitive=False, extra="ignore")

    # MongoDB connection settings.
    mongo_uri: str = "mongodb://localhost:27017"
    mongo_db_name: str = "survey_db"

    # Clinical Writer integration settings.
    clinical_writer_url: str = "http://clinical_writer_agent:8000/process"
    clinical_writer_token: str | None = Field(
        default=None,
        validation_alias=AliasChoices("CLINICAL_WRITER_API_TOKEN", "AI_API_KEY"),
    )
    clinical_writer_transcription_url: str | None = None
    clinical_writer_http_timeout_seconds: int = 300
    clinical_writer_inline_timeout_seconds: int = 180

    # Email delivery settings.
    smtp_host: str | None = Field(
        default=None,
        validation_alias=AliasChoices("SMTP_HOST", "MAIL_SERVER"),
    )
    smtp_port: int = Field(
        default=587,
        validation_alias=AliasChoices("SMTP_PORT", "MAIL_PORT"),
    )
    smtp_user: str | None = Field(
        default=None,
        validation_alias=AliasChoices("SMTP_USER", "MAIL_USERNAME"),
    )
    smtp_password: str | None = Field(
        default=None,
        validation_alias=AliasChoices("SMTP_PASSWORD", "MAIL_PASSWORD"),
    )

    # JWT signing settings.
    SECRET_KEY: str = "super-secret-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    builder_session_expire_minutes: int = 480
    builder_session_cookie_name: str = "survey_builder_session"
    builder_csrf_cookie_name: str = "survey_builder_csrf"
    builder_csrf_header_name: str = "X-Builder-CSRF"
    builder_cookie_domain: str | None = None

    # Environment and administrative controls.
    environment: str = "development"
    cors_allowed_origins_raw: str | None = Field(
        default=None,
        validation_alias="CORS_ALLOWED_ORIGINS",
    )
    privacy_admin_token: str = "dev-privacy-token"
    encryption_key_id: str | None = None
    encryption_provider: str | None = None

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
