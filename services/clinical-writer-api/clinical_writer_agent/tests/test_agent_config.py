import json

import pytest

from clinical_writer_agent.agent_config import AgentConfig
from clinical_writer_agent.agent_graph import create_graph


class _StubLLM:
    def __init__(self, name: str):
        self.name = name
        self.invocations: list[str] = []

    def invoke(self, prompt: str):
        self.invocations.append(prompt)

        class Response:
            def __init__(self, content: str):
                self.content = content

        report = {
            "title": "Relatorio Clinico",
            "subtitle": f"Stub {self.name}",
            "created_at": "2026-01-14T18:42:03Z",
            "patient": {},
            "sections": [
                {
                    "title": "Resumo",
                    "blocks": [
                        {
                            "type": "paragraph",
                            "spans": [{"text": f"{self.name}-response", "bold": False, "italic": False}],
                        }
                    ],
                }
            ],
        }
        return Response(json.dumps(report))


class _StubJudge:
    def __init__(self, score: float = 1.0):
        self.score = score

    def invoke(self, prompt: str):

        class Response:
            def __init__(self, content: str):
                self.content = content

        return Response(str(self.score))


def test_create_llm_instance_accepts_overrides(monkeypatch):
    """Overrides should flow into LLM construction without requiring env vars."""
    # Ensure no env/API key leakage
    monkeypatch.delenv("GEMINI_API_KEY", raising=False)
    monkeypatch.setattr(AgentConfig, "GEMINI_API_KEY", None, raising=False)

    stub_calls = {}

    def _stub_constructor(*, model, temperature, api_key):
        stub_calls["model"] = model
        stub_calls["temperature"] = temperature
        stub_calls["api_key"] = api_key
        return "stub-llm"

    monkeypatch.setattr("clinical_writer_agent.agent_config.ChatGoogleGenerativeAI", _stub_constructor)

    llm = AgentConfig.create_llm_instance(api_key="override-key", model="alt-model", temperature=0.5)

    assert llm == "stub-llm"
    assert stub_calls == {
        "model": "alt-model",
        "temperature": 0.5,
        "api_key": "override-key",
    }


def test_create_llm_instance_requires_api_key(monkeypatch):
    """Missing API key should raise at LLM creation time, not import time."""
    monkeypatch.delenv("GEMINI_API_KEY", raising=False)
    monkeypatch.setattr(AgentConfig, "GEMINI_API_KEY", None, raising=False)

    with pytest.raises(ValueError):
        AgentConfig.create_llm_instance()


def test_create_graph_accepts_injected_llms(monkeypatch):
    """Injected LLMs should be used by graph nodes, enabling fast unit tests."""
    conv_llm = _StubLLM("conversation")
    json_llm = _StubLLM("json")

    graph = create_graph(conversation_llm=conv_llm, json_llm=json_llm)
    state = {
        "input_content": 'Doutor: Como vai? {"patient": "Joao"}',
        "observer": None,
        "input_type": "consult",
        "prompt_key": "default",
        "prompt_version": "test",
        "prompt_text": "{content}",
        "model_version": "test",
    }

    result = graph.invoke(state)

    assert conv_llm.invocations, "Conversation LLM should be invoked"
    assert result["medical_record"] == "conversation-response"
