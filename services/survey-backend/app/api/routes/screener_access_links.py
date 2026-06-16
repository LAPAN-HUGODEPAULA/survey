from datetime import datetime
import secrets

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, ConfigDict, Field

from app.api.dependencies.screener_auth import require_screener
from app.domain.models.screener_access_link_model import ScreenerAccessLinkModel
from app.domain.models.screener_model import ScreenerModel
from app.persistence.deps import (
    get_screener_access_link_repo,
    get_screener_repo,
    get_survey_repo,
)
from app.persistence.repositories.screener_access_link_repo import (
    ScreenerAccessLinkRepository,
)
from app.persistence.repositories.screener_repo import ScreenerRepository
from app.persistence.repositories.survey_repo import SurveyRepository

router = APIRouter()


class CreateScreenerAccessLinkRequest(BaseModel):
    survey_id: str = Field(..., alias="surveyId")

    model_config = ConfigDict(populate_by_name=True)


class ScreenerAccessLinkResponse(BaseModel):
    token: str
    screener_id: str = Field(..., alias="screenerId")
    screener_name: str = Field(..., alias="screenerName")
    survey_id: str = Field(..., alias="surveyId")
    survey_display_name: str = Field(..., alias="surveyDisplayName")
    created_at: datetime = Field(..., alias="createdAt")

    model_config = ConfigDict(populate_by_name=True)


def _to_response(link: ScreenerAccessLinkModel) -> ScreenerAccessLinkResponse:
    return ScreenerAccessLinkResponse(
        token=link.id,
        screenerId=link.screener_id,
        screenerName=link.screener_name,
        surveyId=link.survey_id,
        surveyDisplayName=link.survey_display_name,
        createdAt=link.created_at,
    )


@router.post(
    "/screener_access_links/",
    response_model=ScreenerAccessLinkResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_screener_access_link(
    request: CreateScreenerAccessLinkRequest,
    screener: ScreenerModel = Depends(require_screener),
    link_repo: ScreenerAccessLinkRepository = Depends(get_screener_access_link_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
):

    survey = survey_repo.get_by_id(request.survey_id)
    if not survey:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Survey not found")

    screener_name = f"{screener.firstName} {screener.surname}".strip()
    survey_display_name = survey.get("surveyDisplayName") or survey.get("surveyName") or request.survey_id
    link = ScreenerAccessLinkModel(
        _id=secrets.token_urlsafe(24),
        screenerId=screener.id,
        screenerName=screener_name,
        surveyId=request.survey_id,
        surveyDisplayName=survey_display_name,
    )
    created = link_repo.create(link)
    return _to_response(created)


@router.get(
    "/screener_access_links/{token}",
    response_model=ScreenerAccessLinkResponse,
)
async def resolve_screener_access_link(
    token: str,
    link_repo: ScreenerAccessLinkRepository = Depends(get_screener_access_link_repo),
    screener_repo: ScreenerRepository = Depends(get_screener_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
):
    link = link_repo.find_by_token(token)
    if not link:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code": "LINK_NOT_FOUND",
                "userMessage": "Este link de avaliação não é mais válido ou nunca existiu.",
                "retryable": False,
                "operation": "resolve_access_link"
            }
        )

    screener = screener_repo.find_by_id(link.screener_id)
    survey = survey_repo.get_by_id(link.survey_id)
    if not screener or not survey:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code": "LINK_RESOURCE_MISSING",
                "userMessage": "A avaliação preparada não está mais disponível pois o profissional ou o questionário foram removidos.",
                "retryable": False,
                "operation": "resolve_access_link"
            }
        )

    survey_display_name = survey.get("surveyDisplayName") or survey.get("surveyName") or link.survey_id
    screener_name = f"{screener.firstName} {screener.surname}".strip()
    refreshed = ScreenerAccessLinkModel(
        _id=link.id,
        screenerId=link.screener_id,
        screenerName=screener_name,
        surveyId=link.survey_id,
        surveyDisplayName=survey_display_name,
        createdAt=link.created_at,
    )
    return _to_response(refreshed)
