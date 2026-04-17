"""FastAPI router for agent access-point management."""

from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from pymongo.errors import DuplicateKeyError

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.domain.models.agent_access_point_model import (
    AgentAccessPoint,
    AgentAccessPointUpsert,
)
from app.persistence.deps import (
    get_agent_access_point_repo,
    get_persona_skill_repo,
    get_survey_prompt_repo,
    get_survey_repo,
)
from app.persistence.repositories.agent_access_point_repo import AgentAccessPointRepository
from app.persistence.repositories.persona_skill_repo import PersonaSkillRepository
from app.persistence.repositories.survey_prompt_repo import SurveyPromptRepository
from app.persistence.repositories.survey_repo import SurveyRepository

router = APIRouter(dependencies=[Depends(require_builder_admin)])


def _validate_access_point_bindings(
    access_point: AgentAccessPointUpsert,
    *,
    survey_repo: SurveyRepository,
    prompt_repo: SurveyPromptRepository,
    persona_repo: PersonaSkillRepository,
) -> None:
    if access_point.survey_id and not survey_repo.get_by_id(access_point.survey_id):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Unknown surveyId: {access_point.survey_id}",
        )

    prompt = prompt_repo.get_by_key(access_point.prompt_key)
    if not prompt:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Unknown promptKey: {access_point.prompt_key}",
        )

    persona = persona_repo.get_by_key(access_point.persona_skill_key)
    if not persona:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Unknown personaSkillKey: {access_point.persona_skill_key}",
        )

    if persona.get("outputProfile") != access_point.output_profile:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=(
                "outputProfile does not match personaSkillKey: "
                f"{access_point.persona_skill_key}"
            ),
        )

    persona_by_output = persona_repo.get_by_output_profile(access_point.output_profile)
    if not persona_by_output:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Unknown outputProfile: {access_point.output_profile}",
        )


@router.get("/agent_access_points/", response_model=List[AgentAccessPoint])
async def list_agent_access_points(
    repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
):
    return [AgentAccessPoint(**item) for item in repo.list_all()]


@router.get("/agent_access_points/{access_point_key}", response_model=AgentAccessPoint)
async def get_agent_access_point(
    access_point_key: str,
    repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
):
    access_point = repo.get_by_key(access_point_key)
    if not access_point:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent access point not found",
        )
    return AgentAccessPoint(**access_point)


@router.post(
    "/agent_access_points/",
    response_model=AgentAccessPoint,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_builder_csrf)],
)
async def create_agent_access_point(
    access_point: AgentAccessPointUpsert,
    repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
    prompt_repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
    persona_repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
):
    _validate_access_point_bindings(
        access_point,
        survey_repo=survey_repo,
        prompt_repo=prompt_repo,
        persona_repo=persona_repo,
    )
    try:
        created = repo.create(access_point.model_dump(by_alias=True))
    except DuplicateKeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Agent access point key already exists",
        ) from exc
    return AgentAccessPoint(**created)


@router.put(
    "/agent_access_points/{access_point_key}",
    response_model=AgentAccessPoint,
    dependencies=[Depends(require_builder_csrf)],
)
async def update_agent_access_point(
    access_point_key: str,
    access_point: AgentAccessPointUpsert,
    repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
    survey_repo: SurveyRepository = Depends(get_survey_repo),
    prompt_repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
    persona_repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
):
    if access_point.access_point_key != access_point_key:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="accessPointKey in path and body must match",
        )
    _validate_access_point_bindings(
        access_point,
        survey_repo=survey_repo,
        prompt_repo=prompt_repo,
        persona_repo=persona_repo,
    )
    try:
        updated = repo.update(access_point_key, access_point.model_dump(by_alias=True))
    except DuplicateKeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Agent access point key already exists",
        ) from exc
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent access point not found",
        )
    return AgentAccessPoint(**updated)


@router.delete(
    "/agent_access_points/{access_point_key}",
    status_code=status.HTTP_204_NO_CONTENT,
    dependencies=[Depends(require_builder_csrf)],
)
async def delete_agent_access_point(
    access_point_key: str,
    repo: AgentAccessPointRepository = Depends(get_agent_access_point_repo),
):
    access_point = repo.get_by_key(access_point_key)
    if not access_point:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent access point not found",
        )
    repo.delete(access_point_key)
    return None

