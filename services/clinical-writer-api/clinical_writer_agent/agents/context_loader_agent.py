"""Context loader for prompt hydration in the layered orchestration flow."""

from __future__ import annotations

from datetime import datetime

from .agent_state import AgentState
from ..prompt_registry import PromptNotFoundError, PromptRegistry


class ContextLoaderAgent:  # pylint: disable=too-few-public-methods
    """Hydrate prompt context for downstream analyzer and writer nodes."""

    def __init__(self, prompt_registry: PromptRegistry | None = None):
        self._prompt_registry = prompt_registry

    def load(self, state: AgentState) -> AgentState:
        """Resolve questionnaire and persona prompts into the shared state."""
        new_state = state.copy()
        observer = state.get("observer")
        request_id = state.get("request_id")
        agent_type = "ContextLoader"
        registry = state.get("prompt_registry") or self._prompt_registry

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                agent_type,
                start_time,
                {
                    "input_type": state.get("input_type"),
                    "prompt_key": state.get("prompt_key"),
                    "persona_skill_key": state.get("persona_skill_key"),
                    "output_profile": state.get("output_profile"),
                },
                request_id,
            )

        try:
            if registry is None:
                raise RuntimeError("Prompt registry is not configured.")

            resolved = registry.resolve_process_prompt(
                input_type=state.get("input_type", ""),
                prompt_key=state.get("prompt_key", "default"),
                persona_skill_key=state.get("persona_skill_key"),
                output_profile=state.get("output_profile"),
            )
            new_state["prompt_version"] = resolved.prompt_version
            new_state["questionnaire_prompt_version"] = (
                resolved.questionnaire_prompt_version or ""
            )
            new_state["persona_skill_version"] = resolved.persona_skill_version or ""
            new_state["persona_skill_key"] = (
                resolved.persona_skill_key or state.get("persona_skill_key") or ""
            )
            new_state["output_profile"] = (
                resolved.output_profile or state.get("output_profile") or ""
            )
            new_state["prompt_text"] = resolved.prompt_text
            new_state["interpretation_prompt"] = (
                resolved.interpretation_prompt or resolved.prompt_text
            )
            new_state["persona_prompt"] = resolved.persona_prompt or resolved.prompt_text
            new_state["validation_status"] = "context_loaded"

            if observer:
                observer.on_event(
                    "context_loaded",
                    datetime.now(),
                    {
                        "prompt_version": resolved.prompt_version,
                        "questionnaire_prompt_version": resolved.questionnaire_prompt_version,
                        "persona_skill_version": resolved.persona_skill_version,
                    },
                    request_id,
                )
        except PromptNotFoundError as error:
            new_state["validation_status"] = "prompt_not_found"
            new_state["error_kind"] = "prompt_not_found"
            new_state["error_message"] = str(error)
            if observer:
                observer.on_error(
                    error,
                    {"location": agent_type, "operation": "resolve_prompt"},
                    datetime.now(),
                    request_id,
                )
        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state["validation_status"] = "context_error"
            new_state["error_kind"] = "context_load_failed"
            new_state["error_message"] = f"Context loading failed: {error}"
            if observer:
                observer.on_error(
                    error,
                    {"location": agent_type, "operation": "resolve_prompt"},
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
