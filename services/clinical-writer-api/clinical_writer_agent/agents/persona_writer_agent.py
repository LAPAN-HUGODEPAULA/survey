"""Persona writer node for layered orchestration."""

from __future__ import annotations

import json
import logging
from datetime import datetime

from .agent_state import AgentState
from .schemas import PersonaWriterInput, PersonaWriterOutput
from .layered_node_utils import (
    LLMClient,
    parse_json_object,
    report_to_markdown,
    resolve_model_routing_metadata,
    resolve_model_router,
    resolve_model_version,
)
from ..report_models import ReportDocument


class PersonaWriterAgent:  # pylint: disable=too-few-public-methods
    """Render the final report from clinical facts and persona guidance."""

    def __init__(
        self,
        *,
        conversation_llm: LLMClient | None = None,
        json_llm: LLMClient | None = None,
    ):
        self._conversation_llm = conversation_llm
        self._json_llm = json_llm

    def write(self, state: AgentState) -> AgentState:
        """Generate the final `ReportDocument` JSON and store a narrative draft."""
        new_state = state.copy()
        payload = PersonaWriterInput.model_validate(state)
        observer = state.get("observer")
        request_id = state.get("request_id")
        agent_type = "PersonaWriter"
        logger = logging.getLogger("clinical_writer.stages")

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                agent_type,
                start_time,
                {
                    "input_type": payload.input_type,
                    "fact_count": len(payload.clinical_facts),
                },
                request_id,
            )

        try:
            logger.info(
                "stage=persona_writer_start request_id=%s input_type=%s",
                request_id,
                payload.input_type,
            )
            llm_model = self._select_llm(state)
            prompt = self._build_prompt(
                persona_prompt=payload.persona_prompt,
                clinical_facts=payload.clinical_facts,
                format_override=payload.format_prompt_override,
                reflection_feedback=payload.reflection_feedback,
                reflection_retries_used=payload.reflection_retries_used,
            )
            response = llm_model.invoke(prompt)
            content = (
                response.content if isinstance(response.content, str) else str(response.content)
            )
            report_payload = parse_json_object(content)
            ReportDocument.model_validate(report_payload)

            draft_narrative = report_to_markdown(report_payload)
            output = PersonaWriterOutput(
                report=report_payload,
                draft_narrative=draft_narrative,
                medical_record=draft_narrative,
                model_version=resolve_model_version(llm_model),
                validation_status="written",
            )
            new_state.update(output.model_dump(exclude_none=True))
            new_state.pop("error_kind", None)
            new_state.pop("error_message", None)
            routing_metadata = resolve_model_routing_metadata(llm_model, state)

            if observer:
                observer.on_event(
                    "report_generated",
                    datetime.now(),
                    {
                        "response_length": len(content),
                        **routing_metadata,
                    },
                    request_id,
                )
            logger.info(
                "stage=persona_writer_complete request_id=%s model_version=%s",
                request_id,
                output.model_version,
            )
        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state.update(
                PersonaWriterOutput(
                    report=new_state.get("report", {}),
                    draft_narrative=new_state.get("draft_narrative", ""),
                    medical_record=new_state.get("medical_record", ""),
                    model_version=new_state.get("model_version", ""),
                    validation_status=new_state.get("validation_status", "analyzed"),
                    error_kind="persona_write_failed",
                    error_message=f"Persona writing failed: {error}",
                ).model_dump(exclude_none=True)
            )
            logger.error(
                "stage=persona_writer_error request_id=%s error_kind=%s error=%s",
                request_id,
                new_state.get("error_kind"),
                error,
            )
            if observer:
                observer.on_error(
                    error,
                    {"location": agent_type, "operation": "generate_report"},
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

    def _select_llm(self, state: AgentState):
        input_type = state.get("input_type")
        if input_type == "consult" and self._conversation_llm is not None:
            return self._conversation_llm
        if input_type in {"survey7", "full_intake"} and self._json_llm is not None:
            return self._json_llm
        if self._conversation_llm is not None:
            return self._conversation_llm
        if self._json_llm is not None:
            return self._json_llm
        
        return resolve_model_router(state)

    @staticmethod
    def _build_prompt(
        *,
        persona_prompt: str,
        clinical_facts: dict,
        format_override: str | None = None,
        reflection_feedback: str | None = None,
        reflection_retries_used: int = 0,
    ) -> str:
        schema = json.dumps(ReportDocument.model_json_schema(), ensure_ascii=False, indent=2)
        facts = json.dumps(clinical_facts, ensure_ascii=False, indent=2)
        format_instructions = format_override or (
            "REPORTDOCUMENT JSON SCHEMA:\n"
            f"{schema}\n"
        )
        revision_feedback = ""
        if reflection_feedback and reflection_retries_used > 0:
            revision_feedback = (
                "REFLECTION FEEDBACK:\n"
                f"{reflection_feedback}\n\n"
            )
        return (
            "You are a clinical persona writer.\n"
            "Use only the provided clinical facts and persona instructions.\n"
            "Return exactly one JSON object matching the ReportDocument schema.\n"
            "Do not add markdown fences or commentary.\n\n"
            "PERSONA STYLE AND RESTRICTIONS:\n"
            f"{persona_prompt}\n\n"
            f"{format_instructions}\n"
            f"{revision_feedback}"
            "CLINICAL FACTS:\n"
            f"{facts}\n"
        )
