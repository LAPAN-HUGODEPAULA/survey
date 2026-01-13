"""Writer nodes that generate JSON-only clinical reports."""

import json
from datetime import datetime
from typing import Optional, Protocol, Any

from .agent_state import AgentState
from ..agent_config import AgentConfig
from ..model_router import ModelRouter
from ..prompts import ConversationPrompts, JsonPrompts
from ..report_models import ReportDocument


class LLMClient(Protocol):
    def invoke(self, prompt: str) -> Any:
        ...


class _BaseWriterNode:  # pylint: disable=too-few-public-methods
    def __init__(
        self,
        *,
        agent_type: str,
        fallback_prompt: str,
        llm_model: Optional[LLMClient] = None,
    ):
        self._agent_type = agent_type
        self._fallback_prompt = fallback_prompt
        self._llm_model = llm_model

    def process(self, state: AgentState) -> AgentState:
        new_state = state.copy()
        observer = state.get("observer")
        request_id = state.get("request_id")
        metadata = {"request_id": request_id} if request_id else {}

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                self._agent_type,
                start_time,
                {"input_length": len(state.get("input_content", "")), **metadata},
            )

        try:
            if observer:
                observer.on_event(
                    "prompt_creation_start",
                    datetime.now(),
                    {"agent_type": self._agent_type, **metadata},
                )

            if self._llm_model is None:
                self._llm_model = ModelRouter.from_env()

            prompt_template = state.get("prompt_text") or self._fallback_prompt
            prompt = self._build_prompt(prompt_template, state.get("input_content", ""))

            if observer:
                observer.on_event(
                    "prompt_creation_complete",
                    datetime.now(),
                    {
                        "agent_type": self._agent_type,
                        "prompt_length": len(prompt),
                        **metadata,
                    },
                )
                observer.on_event(
                    "llm_invocation_start",
                    datetime.now(),
                    {"agent_type": self._agent_type, **metadata},
                )

            response = self._llm_model.invoke(prompt)
            content = (
                response.content
                if isinstance(response.content, str)
                else str(response.content)
            )

            report_payload = self._parse_json(content)
            report_payload["created_at"] = (
                report_payload.get("created_at") or datetime.now().isoformat()
            )
            new_state["report"] = report_payload
            new_state["model_version"] = self._resolve_model_version()

            if observer:
                observer.on_event(
                    "llm_invocation_complete",
                    datetime.now(),
                    {
                        "agent_type": self._agent_type,
                        "response_length": len(content),
                        **metadata,
                    },
                )

            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            if observer:
                observer.on_processing_complete(
                    self._agent_type,
                    duration,
                    end_time,
                    {"output_length": len(content), "success": True, **metadata},
                )
        except Exception as error:  # pylint: disable=broad-exception-caught
            new_state["error_message"] = f"Writer output invalid: {error}"

            if observer:
                observer.on_error(
                    error,
                    {
                        "location": self._agent_type,
                        "operation": "generate_report_json",
                        **metadata,
                    },
                    datetime.now(),
                )

        return new_state

    def _build_prompt(self, prompt_template: str, content: str) -> str:
        schema = json.dumps(ReportDocument.model_json_schema(), ensure_ascii=False, indent=2)
        system_frame = (
            "Voce eh um assistente clinico que responde apenas com JSON valido. "
            "A resposta deve seguir exatamente o schema ReportDocument abaixo. "
            "Nao inclua explicacoes, markdown, ou texto fora do JSON."
        )
        try:
            rendered_prompt = prompt_template.format(content=content)
        except Exception:
            rendered_prompt = f"{prompt_template}\n\n{content}"

        return (
            f"{system_frame}\n\n"
            f"SCHEMA:\n{schema}\n\n"
            f"INSTRUCOES:\n{rendered_prompt}\n\n"
            f"CONTEUDO:\n{content}\n\n"
            "RETORNE APENAS O JSON."
        )

    @staticmethod
    def _parse_json(raw: str) -> dict:
        try:
            return json.loads(raw)
        except json.JSONDecodeError as exc:
            raise ValueError(f"Resposta nao eh JSON valido: {exc}") from exc

    def _resolve_model_version(self) -> str:
        if self._llm_model is None:
            return AgentConfig.PRIMARY_MODEL
        if hasattr(self._llm_model, "model_version") and getattr(
            self._llm_model, "model_version"
        ):
            return getattr(self._llm_model, "model_version")
        if hasattr(self._llm_model, "model"):
            return getattr(self._llm_model, "model")
        if hasattr(self._llm_model, "name"):
            return getattr(self._llm_model, "name")
        return AgentConfig.PRIMARY_MODEL


class ConsultWriterNode(_BaseWriterNode):
    def __init__(self, llm_model: Optional[LLMClient] = None):
        super().__init__(
            agent_type="ConsultWriter",
            fallback_prompt=ConversationPrompts.MEDICAL_RECORD_PROMPT,
            llm_model=llm_model,
        )


class Survey7WriterNode(_BaseWriterNode):
    def __init__(self, llm_model: Optional[LLMClient] = None):
        super().__init__(
            agent_type="Survey7Writer",
            fallback_prompt=JsonPrompts.MEDICAL_RECORD_PROMPT,
            llm_model=llm_model,
        )


class FullIntakeWriterNode(_BaseWriterNode):
    def __init__(self, llm_model: Optional[LLMClient] = None):
        super().__init__(
            agent_type="FullIntakeWriter",
            fallback_prompt=JsonPrompts.MEDICAL_RECORD_PROMPT,
            llm_model=llm_model,
        )
