"""FastAPI router for reusable survey prompt management."""

from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from pymongo.errors import DuplicateKeyError

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.config.logging_config import logger
from app.domain.models.survey_prompt_model import SurveyPrompt, SurveyPromptUpsert
from app.persistence.deps import get_survey_prompt_repo
from app.persistence.repositories.survey_prompt_repo import SurveyPromptRepository


router = APIRouter(dependencies=[Depends(require_builder_admin)])


@router.get("/survey_prompts/", response_model=List[SurveyPrompt])
async def list_survey_prompts(
    repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
):
    """Return the reusable survey prompt catalog."""
    return [SurveyPrompt(**item) for item in repo.list_all()]


@router.get("/survey_prompts/{prompt_key}", response_model=SurveyPrompt)
async def get_survey_prompt(
    prompt_key: str,
    repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
):
    """Return one reusable prompt by runtime key."""
    prompt = repo.get_by_key(prompt_key)
    if not prompt:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Survey prompt not found")
    return SurveyPrompt(**prompt)


@router.post(
    "/survey_prompts/",
    response_model=SurveyPrompt,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_builder_csrf)],
)
async def create_survey_prompt(
    prompt: SurveyPromptUpsert,
    repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
):
    """Create a reusable survey prompt."""
    try:
        created = repo.create(prompt.model_dump(by_alias=True))
        return SurveyPrompt(**created)
    except DuplicateKeyError as exc:
        logger.warning("Duplicate survey prompt key: %s", prompt.prompt_key)
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Survey prompt key already exists") from exc


@router.put(
    "/survey_prompts/{prompt_key}",
    response_model=SurveyPrompt,
    dependencies=[Depends(require_builder_csrf)],
)
async def update_survey_prompt(
    prompt_key: str,
    prompt: SurveyPromptUpsert,
    repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
):
    """Update a reusable survey prompt."""
    if prompt.prompt_key != prompt_key:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="promptKey in path and body must match",
        )
    try:
        updated = repo.update(prompt_key, prompt.model_dump(by_alias=True))
    except DuplicateKeyError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Survey prompt key already exists") from exc
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Survey prompt not found")
    return SurveyPrompt(**updated)


@router.delete(
    "/survey_prompts/{prompt_key}",
    status_code=status.HTTP_204_NO_CONTENT,
    dependencies=[Depends(require_builder_csrf)],
)
async def delete_survey_prompt(
    prompt_key: str,
    repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
):
    """Delete a reusable survey prompt when it is not associated with any survey."""
    prompt = repo.get_by_key(prompt_key)
    if not prompt:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Survey prompt not found")
    if repo.is_in_use(prompt_key):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Survey prompt is still associated with a questionnaire",
        )
    repo.delete(prompt_key)
    return None
