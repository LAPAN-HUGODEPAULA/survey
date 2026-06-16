"""Submission orchestrators for patient and survey response flows."""

from __future__ import annotations

from collections.abc import Awaitable, Callable
from typing import Any, Protocol

from fastapi import HTTPException, status
from pydantic import ValidationError

from app.config.logging_config import logger
from app.config.settings import settings
from app.domain.models.agent_response_model import AgentArtifactResponse, AgentResponse
from app.domain.models.survey_response_model import SurveyResponse
from app.domain.models.survey_response_with_agent import SurveyResponseWithAgent
from app.persistence.repositories.agent_access_point_repo import AgentAccessPointRepository
from app.persistence.repositories.patient_response_repo import PatientResponseRepository
from app.persistence.repositories.persona_skill_repo import PersonaSkillRepository
from app.persistence.repositories.screener_access_link_repo import ScreenerAccessLinkRepository
from app.persistence.repositories.screener_repo import ScreenerRepository
from app.persistence.repositories.survey_repo import SurveyRepository
from app.persistence.repositories.survey_response_repo import SurveyResponseRepository
from app.persistence.repositories.system_settings_repo import SystemSettingsRepository
from app.services.access_point_selection import (
    AccessPointSelection,
    resolve_access_point_selection,
)
from app.services.survey_prompt_selection import hydrate_survey_persona_defaults

SURVEY_PATIENT_THANK_YOU_ACCESS_POINT = "survey_patient.thank_you.auto_analysis"
AgentRunner = Callable[..., Awaitable[AgentResponse]]


class MutableResponseRepository(Protocol):
    """Protocol for response repositories that support persistence updates."""

    def create(self, doc: dict[str, Any]) -> dict[str, Any]: ...
    def update_fields(self, response_id: str, fields: dict[str, Any]) -> dict[str, Any] | None: ...


class _BaseSubmissionOrchestrator:
    """Shared orchestration logic across patient and survey submissions."""

    def __init__(
        self,
        *,
        response_repo: MutableResponseRepository,
        survey_repo: SurveyRepository,
        persona_repo: PersonaSkillRepository,
        access_point_repo: AgentAccessPointRepository,
        system_settings_repo: SystemSettingsRepository,
        agent_runner: AgentRunner,
        source_app: str,
    ) -> None:
        self._response_repo = response_repo
        self._survey_repo = survey_repo
        self._persona_repo = persona_repo
        self._access_point_repo = access_point_repo
        self._system_settings_repo = system_settings_repo
        self._agent_runner = agent_runner
        self._source_app = source_app

    def _prepare_selection(self, survey_response: SurveyResponse) -> AccessPointSelection:
        resolved_survey = self._survey_repo.get_by_id(survey_response.survey_id)
        resolved_survey = hydrate_survey_persona_defaults(
            resolved_survey,
            requested_persona_skill_key=survey_response.persona_skill_key,
            requested_output_profile=survey_response.output_profile,
            get_persona_by_key=self._persona_repo.get_by_key,
            get_persona_by_output_profile=self._persona_repo.get_by_output_profile,
        )
        global_ai_config = self._system_settings_repo.get_json("global_ai_config")
        selection = resolve_access_point_selection(
            survey=resolved_survey,
            requested_access_point_key=survey_response.access_point_key,
            requested_prompt_key=survey_response.prompt_key,
            requested_persona_skill_key=survey_response.persona_skill_key,
            requested_output_profile=survey_response.output_profile,
            requested_ai_config=None,
            global_ai_config=global_ai_config,
            input_type="survey7",
            get_access_point_by_key=self._access_point_repo.get_by_key,
        )
        survey_response.access_point_key = selection.access_point_key
        survey_response.prompt_key = selection.prompt_key
        survey_response.persona_skill_key = selection.persona_skill_key
        survey_response.output_profile = selection.output_profile
        return selection

    def _persist_response(self, survey_response: SurveyResponse, *, log_label: str) -> tuple[str, dict[str, Any]]:
        survey_response_dict = survey_response.model_dump(by_alias=True)
        if survey_response_dict.get("_id") is None:
            survey_response_dict.pop("_id", None)

        created = self._response_repo.create(survey_response_dict)
        if not created:
            logger.error(
                "Failed to create %s for survey %s - No insertion ID returned",
                log_label,
                survey_response.survey_id,
            )
            raise HTTPException(status_code=500, detail="Survey response could not be created")

        inserted_id = str(created.get("_id"))
        survey_response.id = inserted_id
        return inserted_id, survey_response.model_dump(by_alias=True)

    async def _enrich_response(
        self,
        *,
        response_id: str,
        survey_response: SurveyResponse,
        response_payload: dict[str, Any],
        selection: AccessPointSelection,
        flow_key: str,
        timeout_seconds: float | None = None,
    ) -> tuple[AgentResponse | None, list[AgentArtifactResponse]]:
        agent_response: AgentResponse | None = None
        agent_responses: list[AgentArtifactResponse] = []
        global_ai_config = self._system_settings_repo.get_json("global_ai_config")

        try:
            runtime_points = _resolve_runtime_access_points(
                selection,
                access_point_repo=self._access_point_repo,
                survey_id=survey_response.survey_id,
                source_app=self._source_app,
                flow_key=flow_key,
                global_ai_config=global_ai_config,
            )
            for runtime_point in runtime_points:
                agent_result = await self._agent_runner(
                    response_payload,
                    input_type="survey7",
                    prompt_key=runtime_point.prompt_key,
                    persona_skill_key=runtime_point.persona_skill_key,
                    output_profile=runtime_point.output_profile,
                    ai_config=runtime_point.ai_config,
                    source_app=self._source_app,
                    patient_ref=survey_response.patient.email if survey_response.patient else None,
                    read_timeout_seconds=timeout_seconds,
                )
                artifact = AgentArtifactResponse(
                    accessPointKey=runtime_point.access_point_key,
                    **agent_result.model_dump(by_alias=True),
                )
                agent_responses.append(artifact)
            agent_response = agent_responses[0] if agent_responses else None
            logger.info("Received agent response for survey response %s.", response_id)
        except ValueError as exc:
            logger.warning("Invalid prompt selection for survey response %s: %s", response_id, exc)
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        except ValidationError as exc:
            logger.error("Invalid data returned by agent for survey response %s: %s", response_id, exc)
            agent_response = AgentResponse(error_message="Invalid agent response format")
        except Exception as exc:
            logger.error("Failed to enrich survey response %s with agent output: %s", response_id, exc)

        if agent_responses:
            self._response_repo.update_fields(
                response_id,
                {
                    "agentResponse": agent_response.model_dump(by_alias=True)
                    if agent_response is not None
                    else None,
                    "agentResponses": [
                        item.model_dump(by_alias=True) for item in agent_responses
                    ],
                },
            )
        return agent_response, agent_responses


class PatientSubmissionOrchestrator(_BaseSubmissionOrchestrator):
    """Coordinate public patient response submissions."""

    def __init__(
        self,
        *,
        response_repo: PatientResponseRepository,
        survey_repo: SurveyRepository,
        persona_repo: PersonaSkillRepository,
        access_point_repo: AgentAccessPointRepository,
        system_settings_repo: SystemSettingsRepository,
        agent_runner: AgentRunner,
    ) -> None:
        super().__init__(
            response_repo=response_repo,
            survey_repo=survey_repo,
            persona_repo=persona_repo,
            access_point_repo=access_point_repo,
            system_settings_repo=system_settings_repo,
            agent_runner=agent_runner,
            source_app="survey-patient",
        )

    async def submit(self, survey_response: SurveyResponse) -> SurveyResponseWithAgent:
        """Persist a patient response and optionally enrich it inline."""
        selection = self._prepare_selection(survey_response)
        response_id, response_payload = self._persist_response(
            survey_response,
            log_label="patient response",
        )
        if selection.access_point_key == SURVEY_PATIENT_THANK_YOU_ACCESS_POINT:
            logger.info(
                "Deferring patient response agent processing for async flow response_id=%s access_point=%s",
                response_id,
                selection.access_point_key,
            )
            return SurveyResponseWithAgent(
                **response_payload,
                agent_response=None,
                agent_responses=[],
            )

        agent_response, agent_responses = await self._enrich_response(
            response_id=response_id,
            survey_response=survey_response,
            response_payload=response_payload,
            selection=selection,
            flow_key="thank_you.auto_analysis",
            timeout_seconds=float(settings.clinical_writer_inline_timeout_seconds),
        )
        return SurveyResponseWithAgent(
            **response_payload,
            agent_response=agent_response,
            agent_responses=agent_responses,
        )


class SurveySubmissionOrchestrator(_BaseSubmissionOrchestrator):
    """Coordinate professional survey response submissions."""

    def __init__(
        self,
        *,
        response_repo: SurveyResponseRepository,
        survey_repo: SurveyRepository,
        persona_repo: PersonaSkillRepository,
        access_point_repo: AgentAccessPointRepository,
        system_settings_repo: SystemSettingsRepository,
        access_link_repo: ScreenerAccessLinkRepository,
        screener_repo: ScreenerRepository,
        agent_runner: AgentRunner,
    ) -> None:
        super().__init__(
            response_repo=response_repo,
            survey_repo=survey_repo,
            persona_repo=persona_repo,
            access_point_repo=access_point_repo,
            system_settings_repo=system_settings_repo,
            agent_runner=agent_runner,
            source_app="survey-frontend",
        )
        self._access_link_repo = access_link_repo
        self._screener_repo = screener_repo

    async def submit(self, survey_response: SurveyResponse) -> SurveyResponseWithAgent:
        """Persist a screener-facing survey response and enrich it inline."""
        self._apply_access_link(survey_response)
        selection = self._prepare_selection(survey_response)
        response_id, response_payload = self._persist_response(
            survey_response,
            log_label="survey response",
        )
        agent_response, agent_responses = await self._enrich_response(
            response_id=response_id,
            survey_response=survey_response,
            response_payload=response_payload,
            selection=selection,
            flow_key="thank_you.auto_analysis",
        )
        return SurveyResponseWithAgent(
            **response_payload,
            agent_response=agent_response,
            agent_responses=agent_responses,
        )

    def _apply_access_link(self, survey_response: SurveyResponse) -> None:
        if not survey_response.access_link_token:
            return

        link = self._access_link_repo.find_by_token(survey_response.access_link_token)
        if not link:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Prepared assessment is no longer available",
            )
        if (
            not self._screener_repo.find_by_id(link.screener_id)
            or not self._survey_repo.get_by_id(link.survey_id)
        ):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Prepared assessment is no longer available",
            )

        survey_response.screener_id = link.screener_id
        survey_response.survey_id = link.survey_id


def _resolve_runtime_access_points(
    primary_selection: AccessPointSelection,
    *,
    access_point_repo: AgentAccessPointRepository,
    survey_id: str,
    source_app: str,
    flow_key: str,
    global_ai_config: dict[str, Any] | None,
) -> list[AccessPointSelection]:
    runtime_points = [primary_selection]
    configured = access_point_repo.list_for_runtime(
        source_app=source_app,
        flow_key=flow_key,
        survey_id=survey_id,
    )
    seen_keys = {primary_selection.access_point_key, None}
    for item in configured:
        access_point_key = item.get("accessPointKey")
        if access_point_key in seen_keys:
            continue
        seen_keys.add(access_point_key)
        runtime_points.append(
            AccessPointSelection(
                access_point_key=access_point_key,
                prompt_key=item["promptKey"],
                persona_skill_key=item.get("personaSkillKey"),
                output_profile=item.get("outputProfile"),
                ai_config=item.get("aiConfig") or global_ai_config,
            )
        )
    return runtime_points
