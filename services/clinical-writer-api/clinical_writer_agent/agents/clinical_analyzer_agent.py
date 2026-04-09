"""Clinical analyzer node for layered orchestration."""

from __future__ import annotations

import json
from datetime import datetime

from .agent_state import AgentState
from .layered_node_utils import LLMClient, parse_json_object, resolve_model_version
from ..model_router import ModelRouter


class ClinicalAnalyzerAgent:  # pylint: disable=too-few-public-methods
    """Generate structured clinical facts from raw request content."""

    def __init__(
        self,
        *,
        conversation_llm: LLMClient | None = None,
        json_llm: LLMClient | None = None,
    ):
        self._conversation_llm = conversation_llm
        self._json_llm = json_llm

    def analyze(self, state: AgentState) -> AgentState:
        """Produce `clinical_facts` as a JSON object without end-user prose."""
        new_state = state.copy()
        observer = state.get("observer")
        request_id = state.get("request_id")
        agent_type = "ClinicalAnalyzer"

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                agent_type,
                start_time,
                {"input_type": state.get("input_type")},
                request_id,
            )

        try:
            llm_model = self._select_llm(state)
            prompt = self._build_prompt(
                input_type=state.get("input_type", ""),
                interpretation_prompt=state.get("interpretation_prompt", ""),
                content=state.get("input_content", ""),
            )
            response = llm_model.invoke(prompt)
            content = (
                response.content if isinstance(response.content, str) else str(response.content)
            )
            new_state["clinical_facts"] = parse_json_object(content)
            new_state["model_version"] = resolve_model_version(llm_model)
            new_state["validation_status"] = "analyzed"

            if observer:
                observer.on_event(
                    "clinical_facts_generated",
                    datetime.now(),
                    {
                        "response_length": len(content),
                        "fact_keys": sorted(new_state["clinical_facts"].keys()),
                    },
                    request_id,
                )
        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state["error_kind"] = "clinical_analysis_failed"
            new_state["error_message"] = f"Clinical analysis failed: {error}"
            if observer:
                observer.on_error(
                    error,
                    {"location": agent_type, "operation": "generate_clinical_facts"},
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
        if self._json_llm is not None:
            return self._json_llm
        if self._conversation_llm is not None:
            return self._conversation_llm
        return ModelRouter.from_env()

    @staticmethod
    def _build_prompt(*, input_type: str, interpretation_prompt: str, content: str) -> str:
        response_schema = {
            "summary": "short factual summary",
            "clinical_findings": ["list of grounded findings"],
            "scores": {"optional_score_name": "value"},
            "alerts": ["optional alert"],
        }
        return (
            "You are a clinical analysis engine.\n"
            "Return exactly one JSON object and no markdown or explanatory prose.\n"
            "Do not write narrative sentences for the final end-user report.\n\n"
            f"INPUT_TYPE:\n{input_type}\n\n"
            "CLINICAL INTERPRETATION RULES:\n"
            f"{interpretation_prompt}\n\n"
            "REQUIRED OUTPUT STYLE:\n"
            "- JSON object only\n"
            "- Ground every fact in the source input\n"
            "- Use arrays and nested objects when helpful\n"
            "- If information is missing, omit it or use null\n\n"
            f"EXAMPLE SHAPE:\n{json.dumps(response_schema, ensure_ascii=False, indent=2)}\n\n"
            f"SOURCE INPUT:\n{content}\n"
        )
