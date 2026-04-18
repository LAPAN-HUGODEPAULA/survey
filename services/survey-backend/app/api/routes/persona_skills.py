"""FastAPI router for persona skill management."""

from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from pymongo.errors import DuplicateKeyError

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.config.logging_config import logger
from app.domain.models.persona_skill_model import PersonaSkill, PersonaSkillUpsert
from app.persistence.deps import get_persona_skill_repo
from app.persistence.repositories.persona_skill_repo import PersonaSkillRepository

router = APIRouter(dependencies=[Depends(require_builder_admin)])


@router.get("/persona_skills/", response_model=List[PersonaSkill])
async def list_persona_skills(
    repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
):
    """Return the persona skill catalog."""
    return [PersonaSkill(**item) for item in repo.list_all()]


@router.get("/persona_skills/{persona_skill_key}", response_model=PersonaSkill)
async def get_persona_skill(
    persona_skill_key: str,
    repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
):
    """Return one persona skill by runtime key."""
    persona_skill = repo.get_by_key(persona_skill_key)
    if not persona_skill:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Persona skill not found")
    return PersonaSkill(**persona_skill)


@router.post(
    "/persona_skills/",
    response_model=PersonaSkill,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_builder_csrf)],
)
async def create_persona_skill(
    persona_skill: PersonaSkillUpsert,
    repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
):
    """Create a persona skill."""
    try:
        created = repo.create(persona_skill.model_dump(by_alias=True))
        return PersonaSkill(**created)
    except DuplicateKeyError as exc:
        logger.warning("Duplicate persona skill key: %s", persona_skill.persona_skill_key)
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Persona skill key already exists") from exc


@router.put(
    "/persona_skills/{persona_skill_key}",
    response_model=PersonaSkill,
    dependencies=[Depends(require_builder_csrf)],
)
async def update_persona_skill(
    persona_skill_key: str,
    persona_skill: PersonaSkillUpsert,
    repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
):
    """Update a persona skill."""
    if persona_skill.persona_skill_key != persona_skill_key:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="personaSkillKey in path and body must match",
        )
    try:
        updated = repo.update(persona_skill_key, persona_skill.model_dump(by_alias=True))
    except DuplicateKeyError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Persona skill key already exists") from exc
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Persona skill not found")
    return PersonaSkill(**updated)


@router.delete(
    "/persona_skills/{persona_skill_key}",
    status_code=status.HTTP_204_NO_CONTENT,
    dependencies=[Depends(require_builder_csrf)],
)
async def delete_persona_skill(
    persona_skill_key: str,
    repo: PersonaSkillRepository = Depends(get_persona_skill_repo),
):
    """Delete a persona skill by runtime key."""
    persona_skill = repo.get_by_key(persona_skill_key)
    if not persona_skill:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Persona skill not found")
    if repo.is_in_use(persona_skill_key, persona_skill.get("outputProfile")):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Persona skill is still required by runtime configuration",
        )
    repo.delete(persona_skill_key)
    return None
