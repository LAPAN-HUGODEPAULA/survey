"""Reflection node that validates grounding, tone, and safety for report drafts."""

from __future__ import annotations

import json
import logging
from datetime import datetime

from .agent_state import AgentState
from .layered_node_utils import (
    LLMClient,
    parse_json_object,
    report_to_markdown,
    resolve_model_router,
)
from .schemas import ReflectionAssessment, ReflectorInput, ReflectorOutput

logger = logging.getLogger("clinical_writer.stages")
MAX_REFLECTION_RETRIES = 2
FINAL_WARNING = (
    "Aviso de segurança: a validação automática identificou possíveis inconsistências "
    "clínicas no laudo. Revise o conteúdo manualmente antes do uso assistencial."
)


class ReflectorAgent:  # pylint: disable=too-few-public-methods
    """Review the generated report and decide whether it needs a rewrite."""

    def __init__(
        self,
        *,
        critique_llm: LLMClient | None = None,
        max_retries: int = MAX_REFLECTION_RETRIES,
    ):
        self._critique_llm = critique_llm
        self._max_retries = max_retries

    def reflect(self, state: AgentState) -> AgentState:
        """Validate the writer output and route to retry, accept, or accept with warning."""
        new_state = state.copy()
        observer = state.get("observer")
        request_id = state.get("request_id")
        agent_type = "Reflector"
        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                agent_type,
                start_time,
                {
                    "input_type": state.get("input_type"),
                    "reflection_retries_used": state.get("reflection_retries_used", 0),
                },
                request_id,
            )

        try:
            payload = ReflectorInput.model_validate(state)
            assessment = self._assess(payload, state)
            output = self._decide(payload, assessment)
            new_state.update(output.model_dump(exclude_none=True))

            if observer:
                observer.on_event(
                    "reflection_completed",
                    datetime.now(),
                    {
                        "grounded": assessment.grounded,
                        "tone_ok": assessment.tone_ok,
                        "safety_ok": assessment.safety_ok,
                        "reflection_outcome": output.reflection_outcome,
                        "reflection_retries_used": output.reflection_retries_used,
                    },
                    request_id,
                )
        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state.update(
                ReflectorOutput(
                    reflection_outcome="error",
                    error_kind="reflection_failed",
                    error_message=f"Reflection failed: {error}",
                    reflection_retries_used=state.get("reflection_retries_used", 0),
                    warnings=list(state.get("warnings") or []),
                ).model_dump(exclude_none=True)
            )
            logger.error(
                "stage=reflector_error request_id=%s error_kind=%s error=%s",
                request_id,
                new_state.get("error_kind"),
                error,
            )
            if observer:
                observer.on_error(
                    error,
                    {"location": agent_type, "operation": "validate_report"},
                    datetime.now(),
                    request_id,
                )

        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        if observer:
            observer.on_processing_complete(
                agent_type,
                duration,
                end_time,
                {"success": "error_message" not in new_state},
                request_id,
            )
        return new_state

    def _assess(
        self,
        payload: ReflectorInput,
        state: AgentState,
    ) -> ReflectionAssessment:
        llm = self._select_llm(state)
        prompt = self._build_prompt(payload)
        response = llm.invoke(prompt)
        content = response.content if isinstance(response.content, str) else str(response.content)
        parsed = parse_json_object(content)
        return ReflectionAssessment.model_validate(parsed)

    def _select_llm(self, state: AgentState):
        if self._critique_llm is not None:
            return self._critique_llm
        return resolve_model_router(state)

    def _decide(
        self,
        payload: ReflectorInput,
        assessment: ReflectionAssessment,
    ) -> ReflectorOutput:
        warnings = list(payload.warnings)
        is_valid = assessment.grounded and assessment.tone_ok and assessment.safety_ok
        if is_valid:
            return ReflectorOutput(
                reflection_outcome="accepted",
                reflection_feedback=None,
                reflection_retries_used=payload.reflection_retries_used,
                warnings=warnings,
            )

        if payload.reflection_retries_used < self._max_retries:
            feedback = self._build_feedback(assessment)
            return ReflectorOutput(
                reflection_outcome="retry",
                reflection_feedback=feedback,
                reflection_retries_used=payload.reflection_retries_used + 1,
                warnings=warnings,
            )

        if FINAL_WARNING not in warnings:
            warnings.append(FINAL_WARNING)
        return ReflectorOutput(
            reflection_outcome="accepted_with_warning",
            reflection_feedback=self._build_feedback(assessment),
            reflection_retries_used=payload.reflection_retries_used,
            warnings=warnings,
        )

    @staticmethod
    def _build_feedback(assessment: ReflectionAssessment) -> str:
        issues = assessment.issues or [
            "Reescreva o laudo mantendo apenas fatos clínicos presentes na análise estruturada."
        ]
        prefix = (
            "Revise o laudo para corrigir grounding, tom e segurança clínica. "
            "Mantenha somente informações presentes nos fatos clínicos.\n"
        )
        return prefix + "\n".join(f"- {item}" for item in issues)

    @staticmethod
    def _build_prompt(payload: ReflectorInput) -> str:
        schema = json.dumps(
            ReflectionAssessment.model_json_schema(),
            ensure_ascii=False,
            indent=2,
        )
        facts = json.dumps(payload.clinical_facts, ensure_ascii=False, indent=2)
        report_markdown = report_to_markdown(payload.report)
        return (
            "You are a clinical reflection validator.\n"
            "Return exactly one JSON object matching the provided schema.\n"
            "Check grounding, tone, and safety of the report.\n"
            "Grounding means every clinical claim must be supported by the structured facts.\n"
            "Tone means the report follows the requested persona without exaggeration.\n"
            "Safety means the report avoids unsupported diagnosis, certainty inflation, or harmful advice.\n\n"
            "EXPECTED JSON SCHEMA:\n"
            f"{schema}\n\n"
            "PERSONA STYLE AND RESTRICTIONS:\n"
            f"{payload.persona_prompt}\n\n"
            "CLINICAL FACTS:\n"
            f"{facts}\n\n"
            "REPORT DRAFT:\n"
            f"{report_markdown}\n"
        )
