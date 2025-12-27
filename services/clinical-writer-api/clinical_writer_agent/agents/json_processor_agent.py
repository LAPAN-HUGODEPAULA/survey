"""Agent that processes JSON payloads into structured medical records."""

# Package imports
from typing import Optional
from datetime import datetime
from langchain_google_genai import ChatGoogleGenerativeAI

# Project imports
from .agent_state import AgentState
from ..agent_config import AgentConfig
from ..prompts import JsonPrompts


class JsonProcessorAgent:  # pylint: disable=too-few-public-methods
    """Agent responsible for processing JSON-based clinical inputs."""

    def __init__(self, llm_model: Optional[ChatGoogleGenerativeAI] = None):
        """Initialize with optional LLM model (dependency injection)."""
        # Defer model creation until needed to avoid network calls during import/testing.
        self.llm_model = llm_model

    def process(self, state: AgentState) -> AgentState:
        """Process JSON input and generate medical record."""

        new_state = state.copy()
        observer = state.get("observer")
        agent_type = "JsonProcessor"

        # Notify observer of processing start
        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                agent_type,
                start_time,
                {"input_length": len(state.get("input_content", ""))},
            )

        try:
            if observer:
                observer.on_event(
                    "prompt_creation_start", datetime.now(), {"agent_type": agent_type}
                )

            if self.llm_model is None:
                self.llm_model = AgentConfig.create_llm_instance()

            prompt = JsonPrompts.build_medical_record_prompt(
                state.get("input_content", "")
            )

            if observer:
                observer.on_event(
                    "prompt_creation_complete",
                    datetime.now(),
                    {"agent_type": agent_type, "prompt_length": len(prompt)},
                )
                observer.on_event(
                    "llm_invocation_start", datetime.now(), {"agent_type": agent_type}
                )

            response = self.llm_model.invoke(prompt)
            content = (
                response.content
                if isinstance(response.content, str)
                else str(response.content)
            )
            # content = prompt
            new_state["medical_record"] = content

            if observer:
                observer.on_event(
                    "llm_invocation_complete",
                    datetime.now(),
                    {"agent_type": agent_type, "response_length": len(content)},
                )

            # Notify observer of successful completion
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            if observer:
                observer.on_processing_complete(
                    agent_type,
                    duration,
                    end_time,
                    {
                        "output_length": len(content),
                        "success": True,
                    },
                )

        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state["error_message"] = (
                AgentConfig.ERROR_MSG_MEDICAL_RECORD_GENERATION.format(error=error)
            )
            new_state["classification"] = AgentConfig.CLASSIFICATION_OTHER

            # Notify observer of error
            if observer:
                observer.on_error(
                    error,
                    {
                        "location": agent_type,
                        "operation": "generate_medical_record",
                    },
                    datetime.now(),
                )

        return new_state
