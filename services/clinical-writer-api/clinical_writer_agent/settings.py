"""Environment-backed settings for the Clinical Writer API."""

from pydantic import AliasChoices, Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


def _secret_is_configured(value: SecretStr | None) -> bool:
    """Return whether a secret setting contains a non-empty value."""
    return bool(value and value.get_secret_value())


class Settings(BaseSettings):
    """Runtime configuration loaded from environment variables."""

    model_config = SettingsConfigDict(case_sensitive=False, extra="ignore")

    environment: str = "development"
    model_version: str = "unknown"
    api_token: SecretStr | None = Field(
        default=None,
        validation_alias=AliasChoices("API_TOKEN", "AI_API_KEY"),
    )
    allow_unauthenticated_access: bool = False

    mongo_uri: str | None = None
    mongo_db_name: str = "survey_db"

    gemini_api_key: SecretStr | None = None
    glm_api_key: SecretStr | None = None
    glm_base_url: str = "https://api.z.ai/api/paas/v4/"
    gemini_model: str | None = None
    glm_model: str | None = None
    primary_model: str | None = None
    fallback_model: str | None = None
    critique_model: str | None = None

    google_application_credentials: str | None = None
    google_drive_folder_id: str | None = None

    @property
    def is_production(self) -> bool:
        """Return whether production safeguards should apply."""
        return self.environment.lower() in {"prod", "production"}

    @property
    def api_token_value(self) -> str | None:
        """Return the configured API token without exposing it in repr output."""
        if not self.api_token:
            return None
        return self.api_token.get_secret_value()

    @property
    def gemini_api_key_value(self) -> str | None:
        """Return the Gemini key for SDK construction."""
        if not self.gemini_api_key:
            return None
        return self.gemini_api_key.get_secret_value()

    @property
    def glm_api_key_value(self) -> str | None:
        """Return the GLM key for SDK construction."""
        if not self.glm_api_key:
            return None
        return self.glm_api_key.get_secret_value()

    def missing_required_settings(self) -> list[str]:
        """Return missing required runtime settings by environment variable name."""
        missing: list[str] = []
        has_gemini_key = _secret_is_configured(self.gemini_api_key)
        has_glm_key = _secret_is_configured(self.glm_api_key)

        if self.is_production and not self.allow_unauthenticated_access:
            if not _secret_is_configured(self.api_token):
                missing.append("API_TOKEN")

        if self.primary_model or self.glm_model:
            if not has_glm_key:
                missing.append("GLM_API_KEY")
        if self.fallback_model or self.gemini_model:
            if not has_gemini_key:
                missing.append("GEMINI_API_KEY")
        if not (self.primary_model or self.glm_model or self.gemini_model):
            missing.append("PRIMARY_MODEL")

        return missing

    def validate_runtime_security(self) -> None:
        """Fail fast when required runtime settings are missing."""
        missing = self.missing_required_settings()
        if missing:
            names = ", ".join(sorted(set(missing)))
            raise RuntimeError(f"Missing required Clinical Writer settings: {names}")


settings = Settings()
