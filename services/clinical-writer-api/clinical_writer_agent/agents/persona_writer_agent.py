"""Persona writer node for layered orchestration."""

from __future__ import annotations

import json
from datetime import datetime

from .agent_state import AgentState
from .layered_node_utils import (
    LLMClient,
    parse_json_object,
    report_to_markdown,
    resolve_model_version,
)
from ..model_router import ModelRouter
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
        observer = state.get("observer")
        request_id = state.get("request_id")
        agent_type = "PersonaWriter"

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                agent_type,
                start_time,
                {
                    "input_type": state.get("input_type"),
                    "fact_count": len(state.get("clinical_facts", {})),
                },
                request_id,
            )

        try:
            llm_model = self._select_llm(state)
            prompt = self._build_prompt(
                persona_prompt=state.get("persona_prompt", ""),
                clinical_facts=state.get("clinical_facts", {}),
            )
            response = llm_model.invoke(prompt)
            content = (
                response.content if isinstance(response.content, str) else str(response.content)
            )
            report_payload = parse_json_object(content)
            ReportDocument.model_validate(report_payload)

            new_state["report"] = report_payload
            new_state["draft_narrative"] = report_to_markdown(report_payload)
            new_state["medical_record"] = new_state["draft_narrative"]
            new_state["model_version"] = resolve_model_version(llm_model)
            new_state["validation_status"] = "written"
            new_state.pop("error_kind", None)
            new_state.pop("error_message", None)

            if observer:
                observer.on_event(
                    "report_generated",
                    datetime.now(),
                    {"response_length": len(content)},
                    request_id,
                )
        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state["error_kind"] = "persona_write_failed"
            new_state["error_message"] = f"Persona writing failed: {error}"
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
        return ModelRouter.from_env()

    @staticmethod
    def _build_prompt(
        *,
        persona_prompt: str,
        clinical_facts: dict,
    ) -> str:
        schema = json.dumps(ReportDocument.model_json_schema(), ensure_ascii=False, indent=2)
        facts = json.dumps(clinical_facts, ensure_ascii=False, indent=2)
        return (
            "You are a clinical persona writer.\n"
            "Use only the provided clinical facts and persona instructions.\n"
            "Return exactly one JSON object matching the ReportDocument schema.\n"
            "Do not add markdown fences or commentary.\n\n"
            "PERSONA STYLE AND RESTRICTIONS:\n"
            f"{persona_prompt}\n\n"
            "CLINICAL FACTS:\n"
            f"{facts}\n\n"
            "REPORTDOCUMENT JSON SCHEMA:\n"
            f"{schema}\n"
        )
