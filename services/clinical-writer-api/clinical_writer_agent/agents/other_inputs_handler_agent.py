"""Agent that returns safe responses for unclassified or errored inputs."""

from datetime import datetime

from .agent_state import AgentState
from ..agent_config import AgentConfig


class OtherInputHandlerAgent:  # pylint: disable=too-few-public-methods
    """Handler for inputs that cannot continue through the main pipeline."""

    def handle(self, state: AgentState) -> AgentState:
        """Preserve the error context and produce a safe fallback payload."""
        new_state = state.copy()
        observer = state.get("observer")
        request_id = state.get("request_id")
        agent_type = "OtherInputHandler"

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                agent_type,
                start_time,
                {
                    "validation_status": state.get("validation_status"),
                    "has_error": bool(state.get("error_message")),
                },
                request_id,
            )

        new_state["medical_record"] = state.get(
            "error_message",
            AgentConfig.ERROR_MSG_NO_ERROR_AVAILABLE,
        )

        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        if observer:
            observer.on_processing_complete(
                agent_type,
                duration,
                end_time,
                {"handled_error": True},
                request_id,
            )

        return new_state
