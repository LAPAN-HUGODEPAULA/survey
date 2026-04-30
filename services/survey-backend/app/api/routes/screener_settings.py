"""FastAPI router for screener-wide settings."""

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.persistence.deps import get_survey_repo, get_system_settings_repo
from app.persistence.repositories.survey_repo import SurveyRepository
from app.persistence.repositories.system_settings_repo import SystemSettingsRepository

router = APIRouter()

_DEFAULT_QUESTIONNAIRE_KEY = "screener_default_questionnaire_id"
_CHYPS_DEFAULT_NAME = "chyps-v br q20"


class ScreenerSettingsResponse(BaseModel):
    """Response payload for screener global settings."""

    default_questionnaire_id: str | None = Field(
        default=None,
        alias="defaultQuestionnaireId",
    )
    default_questionnaire_name: str | None = Field(
        default=None,
        alias="defaultQuestionnaireName",
    )


class ScreenerSettingsUpdate(BaseModel):
    """Update payload for screener global settings."""

    default_questionnaire_id: str = Field(alias="defaultQuestionnaireId")


def _survey_display_name(survey: dict) -> str:
    survey_display_name = str(survey.get("surveyDisplayName") or "").strip()
    if survey_display_name:
        return survey_display_name
    return str(survey.get("surveyName") or "").strip()


def _find_chyps_default_survey(survey_repo: SurveyRepository) -> dict | None:
    surveys = survey_repo.list_all()
    for survey in surveys:
        display_name = " ".join(_survey_display_name(survey).lower().split())
        if display_name == _CHYPS_DEFAULT_NAME:
            return survey
    return None


def _resolve_settings_payload(
    *,
    survey_repo: SurveyRepository,
    settings_repo: SystemSettingsRepository,
) -> ScreenerSettingsResponse:
    questionnaire_id = settings_repo.get_value(_DEFAULT_QUESTIONNAIRE_KEY)
    survey = survey_repo.get_by_id(questionnaire_id) if questionnaire_id else None

    if not survey:
        fallback = _find_chyps_default_survey(survey_repo)
        if fallback:
            fallback_id = str(fallback.get("_id") or "").strip()
            if fallback_id:
                settings_repo.set_value(_DEFAULT_QUESTIONNAIRE_KEY, fallback_id)
                questionnaire_id = fallback_id
                survey = fallback

    if not survey:
        return ScreenerSettingsResponse(
            defaultQuestionnaireId=None,
            defaultQuestionnaireName=None,
        )

    return ScreenerSettingsResponse(
        defaultQuestionnaireId=str(survey.get("_id") or "").strip() or None,
        defaultQuestionnaireName=_survey_display_name(survey) or None,
    )


@router.get("/settings/screener", response_model=ScreenerSettingsResponse)
async def get_screener_settings(
    settings_repo: SystemSettingsRepository = Depends(get_system_settings_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
):
    """Return screener global settings."""
    return _resolve_settings_payload(
        survey_repo=survey_repo,
        settings_repo=settings_repo,
    )


@router.put(
    "/settings/screener",
    response_model=ScreenerSettingsResponse,
    dependencies=[Depends(require_builder_admin), Depends(require_builder_csrf)],
)
async def update_screener_settings(
    payload: ScreenerSettingsUpdate,
    settings_repo: SystemSettingsRepository = Depends(get_system_settings_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
):
    """Update screener global settings."""
    survey = survey_repo.get_by_id(payload.default_questionnaire_id)
    if not survey:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=(
                "Unknown defaultQuestionnaireId: "
                f"{payload.default_questionnaire_id}"
            ),
        )

    resolved_id = str(survey.get("_id") or "").strip()
    if not resolved_id:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=(
                "Unknown defaultQuestionnaireId: "
                f"{payload.default_questionnaire_id}"
            ),
        )

    settings_repo.set_value(_DEFAULT_QUESTIONNAIRE_KEY, resolved_id)
    return _resolve_settings_payload(
        survey_repo=survey_repo,
        settings_repo=settings_repo,
    )
