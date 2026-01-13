"""Writer nodes that generate the clinical report from the prompt registry."""

from datetime import datetime
from typing import Optional

from langchain_google_genai import ChatGoogleGenerativeAI

from .agent_state import AgentState
from ..agent_config import AgentConfig
from ..prompts import ConversationPrompts, JsonPrompts


class _BaseWriterNode:  # pylint: disable=too-few-public-methods
    def __init__(
        self,
        *,
        agent_type: str,
        fallback_prompt: str,
        llm_model: Optional[ChatGoogleGenerativeAI] = None,
    ):
        self._agent_type = agent_type
        self._fallback_prompt = fallback_prompt
        self._llm_model = llm_model

    def process(self, state: AgentState) -> AgentState:
        new_state = state.copy()
        observer = state.get("observer")

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                self._agent_type,
                start_time,
                {"input_length": len(state.get("input_content", ""))},
            )

        try:
            if observer:
                observer.on_event(
                    "prompt_creation_start", datetime.now(), {"agent_type": self._agent_type}
                )

            if self._llm_model is None:
                self._llm_model = AgentConfig.create_llm_instance()

            prompt_template = state.get("prompt_text") or self._fallback_prompt
            try:
                prompt = prompt_template.format(content=state.get("input_content", ""))
            except Exception:
                prompt = f"{prompt_template}\n\n{state.get('input_content', '')}"

            if observer:
                observer.on_event(
                    "prompt_creation_complete",
                    datetime.now(),
                    {"agent_type": self._agent_type, "prompt_length": len(prompt)},
                )
                observer.on_event(
                    "llm_invocation_start", datetime.now(), {"agent_type": self._agent_type}
                )

            response = self._llm_model.invoke(prompt)
            content = (
                response.content
                if isinstance(response.content, str)
                else str(response.content)
            )
            new_state["medical_record"] = content
            new_state["model_version"] = AgentConfig.LLM_MODEL_NAME

            if observer:
                observer.on_event(
                    "llm_invocation_complete",
                    datetime.now(),
                    {"agent_type": self._agent_type, "response_length": len(content)},
                )

            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            if observer:
                observer.on_processing_complete(
                    self._agent_type,
                    duration,
                    end_time,
                    {"output_length": len(content), "success": True},
                )
        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state["error_message"] = AgentConfig.ERROR_MSG_MEDICAL_RECORD_GENERATION.format(
                error=error
            )

            if observer:
                observer.on_error(
                    error,
                    {"location": self._agent_type, "operation": "generate_medical_record"},
                    datetime.now(),
                )

        return new_state


class ConsultWriterNode(_BaseWriterNode):
    def __init__(self, llm_model: Optional[ChatGoogleGenerativeAI] = None):
        super().__init__(
            agent_type="ConsultWriter",
            fallback_prompt=ConversationPrompts.MEDICAL_RECORD_PROMPT,
            llm_model=llm_model,
        )


class Survey7WriterNode(_BaseWriterNode):
    def __init__(self, llm_model: Optional[ChatGoogleGenerativeAI] = None):
        super().__init__(
            agent_type="Survey7Writer",
            fallback_prompt=JsonPrompts.MEDICAL_RECORD_PROMPT,
            llm_model=llm_model,
        )


class FullIntakeWriterNode(_BaseWriterNode):
    def __init__(self, llm_model: Optional[ChatGoogleGenerativeAI] = None):
        super().__init__(
            agent_type="FullIntakeWriter",
            fallback_prompt=JsonPrompts.MEDICAL_RECORD_PROMPT,
            llm_model=llm_model,
        )
