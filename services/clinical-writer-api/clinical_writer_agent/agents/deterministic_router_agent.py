"""Deterministic router that selects the writer node based on input_type."""

from datetime import datetime

from .agent_state import AgentState


class DeterministicRouterAgent:  # pylint: disable=too-few-public-methods
    """Route deterministically using the input_type provided by the request."""

    def __init__(self, allowed_types: set[str]):
        self._allowed_types = allowed_types

    def route(self, state: AgentState) -> AgentState:
        new_state = state.copy()
        observer = state.get("observer")
        input_type = state.get("input_type")
        agent_type = "DeterministicRouter"

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                agent_type,
                start_time,
                {"input_type": input_type},
            )

        if input_type not in self._allowed_types:
            new_state["validation_status"] = "flagged"
            new_state["error_message"] = f"Unsupported input_type: {input_type}"
            new_state["input_type"] = "invalid"

        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        if observer:
            observer.on_processing_complete(
                agent_type,
                duration,
                end_time,
                {"input_type": input_type},
            )

        return new_state
