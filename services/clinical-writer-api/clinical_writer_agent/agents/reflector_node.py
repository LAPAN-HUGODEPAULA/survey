"""Reflection node that judges report safety and audience fit."""

from __future__ import annotations

import json
from datetime import datetime

from .agent_state import AgentState
from .layered_node_utils import LLMClient, parse_json_object, resolve_model_version
from ..agent_config import AgentConfig
from ..model_router import ModelRouter

NON_MEDICAL_OUTPUT_PROFILES = {
    "school_report",
    "educational_support_summary",
    "parental_guidance",
    "patient_condition_overview",
}


class ReflectorNode:  # pylint: disable=too-few-public-methods
    """Validate drafts and request rewrites when safety or tone rules fail."""

    def __init__(self, *, critique_llm: LLMClient | None = None):
        self._critique_llm = critique_llm

    def reflect(self, state: AgentState) -> AgentState:
        """Judge the report and decide whether the workflow can finish."""
        new_state = state.copy()
        observer = state.get("observer")
        request_id = state.get("request_id")
        agent_type = "ReflectorNode"

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                agent_type,
                start_time,
                {
                    "output_profile": state.get("output_profile"),
                    "reflection_retries_used": state.get("reflection_retries_used", 0),
                },
                request_id,
            )

        try:
            llm_model = self._critique_llm or ModelRouter(
                primary_model=AgentConfig.CRITIQUE_MODEL,
                fallback_model=AgentConfig.FALLBACK_MODEL,
                api_key=AgentConfig.GEMINI_API_KEY,
                temperature=0.1,
            )
            prompt = self._build_prompt(state)
            response = llm_model.invoke(prompt)
            content = response.content if isinstance(response.content, str) else str(response.content)
            payload = parse_json_object(content)
            self._validate_payload(payload)

            decision = str(payload["decision"]).strip().lower()
            issues = [str(item).strip() for item in payload.get("issues", []) if str(item).strip()]
            feedback = str(payload.get("feedback") or "").strip()

            new_state["critique_model_version"] = resolve_model_version(llm_model)
            new_state["reflection_issues"] = issues
            new_state["reflection_feedback"] = feedback

            if decision == "pass":
                new_state["reflection_status"] = "passed"
                new_state["validation_status"] = "reflection_passed"
                new_state.pop("error_kind", None)
                new_state.pop("error_message", None)
            else:
                retries_used = state.get("reflection_retries_used", 0)
                max_retries = state.get("max_reflection_iterations", 2)
                if retries_used >= max_retries:
                    new_state["reflection_status"] = "failed"
                    new_state["validation_status"] = "reflection_failed"
                    new_state["error_kind"] = "reflection_failed"
                    new_state["error_message"] = (
                        "Reflection failed to reach a safe final report within "
                        f"{max_retries} corrective iterations. Last feedback: {feedback or 'No feedback provided.'}"
                    )
                else:
                    new_state["reflection_status"] = "failed"
                    new_state["validation_status"] = "reflection_failed"
                    new_state["reflection_retries_used"] = retries_used + 1
                    new_state.pop("error_kind", None)
                    new_state.pop("error_message", None)

            if observer:
                observer.on_event(
                    "reflection_completed",
                    datetime.now(),
                    {
                        "decision": decision,
                        "issue_count": len(issues),
                        "retries_used": new_state.get("reflection_retries_used", 0),
                    },
                    request_id,
                )
        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state["error_kind"] = "reflection_execution_failed"
            new_state["error_message"] = f"Reflection failed: {error}"
            if observer:
                observer.on_error(
                    error,
                    {"location": agent_type, "operation": "reflect_report"},
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

    @staticmethod
    def _build_prompt(state: AgentState) -> str:
        report_payload = json.dumps(state.get("report", {}), ensure_ascii=False, indent=2)
        facts_payload = json.dumps(state.get("clinical_facts", {}), ensure_ascii=False, indent=2)
        output_profile = state.get("output_profile", "")
        persona_skill_key = state.get("persona_skill_key", "")
        is_non_medical = output_profile in NON_MEDICAL_OUTPUT_PROFILES or persona_skill_key in NON_MEDICAL_OUTPUT_PROFILES

        safety_rules = [
            "1. Validate whether tone and vocabulary match the intended audience profile.",
            "2. Check whether every recommendation is appropriate for that audience.",
            "3. Ground your judgment in the provided clinical facts and generated report only.",
        ]
        if is_non_medical:
            safety_rules.append(
                "4. Reject any prescription, invasive medical recommendation, or prescriptive medical direction."
            )

        response_schema = {
            "decision": "pass or fail",
            "issues": ["short list of violations"],
            "feedback": "precise rewrite instruction for the writer",
        }
        audience_label = output_profile or persona_skill_key or "unspecified"
        return (
            "You are the clinical report reflector and safety judge.\n"
            "Review the generated report and return exactly one JSON object.\n"
            "Be strict. If a non-medical audience receives invasive medical guidance, decision MUST be fail.\n\n"
            f"AUDIENCE PROFILE:\n{audience_label}\n\n"
            f"NON_MEDICAL_AUDIENCE:\n{str(is_non_medical).lower()}\n\n"
            "REVIEW RULES:\n"
            + "\n".join(f"- {rule}" for rule in safety_rules)
            + "\n\nCLINICAL FACTS:\n"
            + f"{facts_payload}\n\nGENERATED REPORT JSON:\n{report_payload}\n\n"
            + "RESPONSE JSON SCHEMA:\n"
            + f"{json.dumps(response_schema, ensure_ascii=False, indent=2)}\n"
        )

    @staticmethod
    def _validate_payload(payload: dict[str, object]) -> None:
        decision = str(payload.get("decision") or "").strip().lower()
        if decision not in {"pass", "fail"}:
            raise ValueError("Reflector response must define decision as 'pass' or 'fail'.")
        issues = payload.get("issues", [])
        if issues is not None and not isinstance(issues, list):
            raise ValueError("Reflector response field 'issues' must be a list when present.")
        feedback = payload.get("feedback")
        if feedback is not None and not isinstance(feedback, str):
            raise ValueError("Reflector response field 'feedback' must be a string when present.")
