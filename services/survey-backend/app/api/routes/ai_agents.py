"""FastAPI router for AI agent catalog management."""

from typing import List

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.domain.models.ai_agent_model import AIAgent, AIAgentUpsert
from app.persistence.deps import get_ai_agent_repo
from app.persistence.repositories.ai_agent_repo import AIAgentRepository

router = APIRouter(dependencies=[Depends(require_builder_admin)])


@router.get("/ai_agents/", response_model=List[AIAgent])
async def list_ai_agents(
    repo: AIAgentRepository = Depends(get_ai_agent_repo),
):
    """List AI agent catalog records."""
    return [AIAgent(**item) for item in repo.list_all()]


@router.get("/ai_agents/{agent_key}", response_model=AIAgent)
async def get_ai_agent(
    agent_key: str,
    repo: AIAgentRepository = Depends(get_ai_agent_repo),
):
    """Return one AI agent catalog record."""
    agent = repo.get_by_key(agent_key)
    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="AI agent not found",
        )
    return AIAgent(**agent)


@router.post(
    "/ai_agents/",
    response_model=AIAgent,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_builder_csrf)],
)
async def create_ai_agent(
    agent: AIAgentUpsert,
    repo: AIAgentRepository = Depends(get_ai_agent_repo),
):
    """Create an AI agent catalog record."""
    try:
        created = repo.create(agent.model_dump(by_alias=True))
    except ValueError as exc:
        if str(exc) != "duplicate_agent_key":
            raise
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="AI agent key already exists",
        ) from exc
    return AIAgent(**created)


@router.put(
    "/ai_agents/{agent_key}",
    response_model=AIAgent,
    dependencies=[Depends(require_builder_csrf)],
)
async def update_ai_agent(
    agent_key: str,
    agent: AIAgentUpsert,
    repo: AIAgentRepository = Depends(get_ai_agent_repo),
):
    """Update an AI agent catalog record."""
    if agent.agent_key != agent_key:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="agentKey in path and body must match",
        )
    try:
        updated = repo.update(agent_key, agent.model_dump(by_alias=True))
    except ValueError as exc:
        if str(exc) != "duplicate_agent_key":
            raise
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="AI agent key already exists",
        ) from exc
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="AI agent not found",
        )
    return AIAgent(**updated)


@router.delete(
    "/ai_agents/{agent_key}",
    status_code=status.HTTP_204_NO_CONTENT,
    dependencies=[Depends(require_builder_csrf)],
)
async def delete_ai_agent(
    agent_key: str,
    repo: AIAgentRepository = Depends(get_ai_agent_repo),
):
    """Delete an AI agent catalog record."""
    agent = repo.get_by_key(agent_key)
    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="AI agent not found",
        )
    repo.delete(agent_key)
    return None
