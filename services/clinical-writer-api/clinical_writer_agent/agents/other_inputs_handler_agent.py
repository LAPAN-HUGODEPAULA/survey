"""Agent that returns safe responses for unclassified or flagged inputs."""

# Project imports
from .agent_state import AgentState
from ..agent_config import AgentConfig


class OtherInputHandlerAgent:
    """Handler for inputs that don't match expected formats or contain errors."""

    def handle(self, state: AgentState) -> AgentState:
        """Handle unclassified or flagged inputs"""
        from datetime import datetime
        
        new_state = state.copy()
        observer = state.get("observer")
        agent_type = "OtherInputHandler"
        
        # Notify observer of processing start
        start_time = datetime.now()
        if observer:
            observer.on_processing_start(agent_type, start_time, {
                'classification': state.get('classification'),
                'has_error': bool(state.get('error_message'))
            })
        
        new_state["medical_record"] = state.get(
            "error_message", 
            AgentConfig.ERROR_MSG_NO_ERROR_AVAILABLE
        )
        
        # Notify observer of completion
        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        if observer:
            observer.on_processing_complete(agent_type, duration, end_time, {
                'handled_error': True
            })
        
        return new_state
