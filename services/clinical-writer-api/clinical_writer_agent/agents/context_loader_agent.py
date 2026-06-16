"""Context loader for prompt hydration in the layered orchestration flow."""

from __future__ import annotations

from datetime import datetime

from .agent_state import AgentState
from .schemas import ContextLoaderInput, ContextLoaderOutput
from ..prompt_registry import PromptNotFoundError, PromptRegistry


class ContextLoaderAgent:  # pylint: disable=too-few-public-methods
    """Hydrate prompt context for downstream analyzer and writer nodes."""

    def __init__(self, prompt_registry: PromptRegistry | None = None):
        self._prompt_registry = prompt_registry

    def load(self, state: AgentState) -> AgentState:
        """Resolve questionnaire and persona prompts into the shared state."""
        new_state = state.copy()
        payload = ContextLoaderInput.model_validate(state)
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
                    "input_type": payload.input_type,
                    "prompt_key": payload.prompt_key,
                    "persona_skill_key": payload.persona_skill_key,
                    "output_profile": payload.output_profile,
                },
                request_id,
            )

        try:
            if registry is None:
                raise RuntimeError("Prompt registry is not configured.")

            resolved = registry.resolve_process_prompt(
                input_type=payload.input_type,
                prompt_key=payload.prompt_key,
                persona_skill_key=payload.persona_skill_key,
                output_profile=payload.output_profile,
                system_prompt_override=payload.system_prompt_override,
                format_prompt_override=payload.format_prompt_override,
            )
            output = ContextLoaderOutput(
                prompt_version=resolved.prompt_version,
                questionnaire_prompt_version=resolved.questionnaire_prompt_version or "",
                persona_skill_version=resolved.persona_skill_version or "",
                persona_skill_key=resolved.persona_skill_key or payload.persona_skill_key or "",
                output_profile=resolved.output_profile or payload.output_profile or "",
                prompt_text=resolved.prompt_text,
                interpretation_prompt=resolved.interpretation_prompt or resolved.prompt_text,
                persona_prompt=resolved.persona_prompt or resolved.prompt_text,
                validation_status="context_loaded",
            )
            new_state.update(output.model_dump(exclude_none=True))

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
            new_state.update(
                ContextLoaderOutput(
                    prompt_version=new_state.get("prompt_version", "unknown"),
                    prompt_text=new_state.get("prompt_text", ""),
                    interpretation_prompt=new_state.get("interpretation_prompt", ""),
                    persona_prompt=new_state.get("persona_prompt", ""),
                    validation_status="prompt_not_found",
                    error_kind="prompt_not_found",
                    error_message=str(error),
                ).model_dump(exclude_none=True)
            )
            if observer:
                observer.on_error(
                    error,
                    {"location": agent_type, "operation": "resolve_prompt"},
                    datetime.now(),
                    request_id,
                )
        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state.update(
                ContextLoaderOutput(
                    prompt_version=new_state.get("prompt_version", "unknown"),
                    prompt_text=new_state.get("prompt_text", ""),
                    interpretation_prompt=new_state.get("interpretation_prompt", ""),
                    persona_prompt=new_state.get("persona_prompt", ""),
                    validation_status="context_error",
                    error_kind="context_load_failed",
                    error_message=f"Context loading failed: {error}",
                ).model_dump(exclude_none=True)
            )
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
