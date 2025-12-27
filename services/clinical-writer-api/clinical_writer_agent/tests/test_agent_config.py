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

        return Response(f"{self.name}-response")


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
    judge_llm = _StubJudge(0.9)

    graph = create_graph(conversation_llm=conv_llm, json_llm=json_llm, judge_llm=judge_llm)
    state = {"input_content": 'Doutor: Como vai? {"patient": "Joao"}', "observer": None}

    result = graph.invoke(state)

    assert result["classification"] in ("conversation", "json")
    if result["classification"] == "conversation":
        assert conv_llm.invocations, "Conversation LLM should be invoked"
        assert result["medical_record"] == "conversation-response"
    else:
        assert json_llm.invocations, "JSON LLM should be invoked"
        assert result["medical_record"] == "json-response"
