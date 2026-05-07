"""FastAPI router for global AI settings."""

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.persistence.deps import get_system_settings_repo
from app.persistence.repositories.system_settings_repo import SystemSettingsRepository

router = APIRouter()

_GLOBAL_AI_SETTINGS_KEY = "global_ai_config"


class GlobalAIConfig(BaseModel):
    """Canonical aiConfig shape shared by access points and global settings."""

    primary_provider: str = Field(..., alias="primaryProvider")
    primary_model: str = Field(..., alias="primaryModel")
    fallback_provider: str | None = Field(default=None, alias="fallbackProvider")
    fallback_model: str | None = Field(default=None, alias="fallbackModel")
    temperature: float = Field(default=0.0, ge=0.0, le=1.0)
    reasoning_effort: str = Field(default="low", alias="reasoningEffort")
    enable_caching: bool = Field(default=True, alias="enableCaching")

    model_config = {"populate_by_name": True}


class GlobalAISettingsResponse(BaseModel):
    """Response payload for global AI settings."""

    ai_config: GlobalAIConfig | None = Field(default=None, alias="aiConfig")

    model_config = {"populate_by_name": True}


class GlobalAISettingsUpdate(BaseModel):
    """Update payload for global AI settings."""

    ai_config: GlobalAIConfig = Field(alias="aiConfig")

    model_config = {"populate_by_name": True}


def _load_global_ai_config(settings_repo: SystemSettingsRepository) -> GlobalAIConfig | None:
    current = settings_repo.get_json(_GLOBAL_AI_SETTINGS_KEY)
    if not current:
        return None
    return GlobalAIConfig(**current)


@router.get("/settings/ai", response_model=GlobalAISettingsResponse)
async def get_global_ai_settings(
    settings_repo: SystemSettingsRepository = Depends(get_system_settings_repo),
):
    """Return global AI settings."""
    return GlobalAISettingsResponse(aiConfig=_load_global_ai_config(settings_repo))


@router.put(
    "/settings/ai",
    response_model=GlobalAISettingsResponse,
    dependencies=[Depends(require_builder_admin), Depends(require_builder_csrf)],
)
async def update_global_ai_settings(
    payload: GlobalAISettingsUpdate,
    settings_repo: SystemSettingsRepository = Depends(get_system_settings_repo),
):
    """Update global AI settings."""
    ai_config = payload.ai_config.model_dump(by_alias=True)
    if ai_config.get("fallbackProvider") and not ai_config.get("fallbackModel"):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="fallbackModel is required when fallbackProvider is defined",
        )
    settings_repo.set_json(_GLOBAL_AI_SETTINGS_KEY, ai_config)
    return GlobalAISettingsResponse(aiConfig=GlobalAIConfig(**ai_config))
