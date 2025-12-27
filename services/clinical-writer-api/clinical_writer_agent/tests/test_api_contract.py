import pytest

from clinical_writer_agent.agent_config import AgentConfig
from clinical_writer_agent.agent_graph import create_graph, create_default_observer
from clinical_writer_agent.main import Input, process_content

pytestmark = pytest.mark.anyio("asyncio")


class _StubLLM:
    def __init__(self, name: str):
        self.name = name
        self.calls = 0

    def invoke(self, prompt: str):
        self.calls += 1

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


def _build_graph(observer):
    conv_llm = _StubLLM("conversation")
    json_llm = _StubLLM("json")
    judge_llm = _StubJudge(0.9)
    graph = create_graph(observer=observer, conversation_llm=conv_llm, json_llm=json_llm, judge_llm=judge_llm)
    return graph, conv_llm, json_llm


async def test_schema_validation_rejects_blank_input():
    with pytest.raises(ValueError):
        Input(content="")


async def test_flagging_of_sanitization_edges():
    observer = create_default_observer()
    graph, *_ = _build_graph(observer)
    inputs_and_expected = [
        ("Hello there! 👋", AgentConfig.CLASSIFICATION_FLAGGED),
        ("This is <b>html</b>", AgentConfig.CLASSIFICATION_OTHER),
        ("Buy now and get a discount!", AgentConfig.CLASSIFICATION_FLAGGED),
    ]
    for text, expected in inputs_and_expected:
        result = await process_content(Input(content=text), graph, observer)
        assert result["classification"] == expected
        if expected == AgentConfig.CLASSIFICATION_FLAGGED:
            assert "flagged" in result["medical_record"]
        else:
            assert "could not be classified" in result["medical_record"]


async def test_json_and_conversation_paths_use_injected_llms():
    observer = create_default_observer()
    graph, conv_llm, json_llm = _build_graph(observer)

    conv_result = await process_content(Input(content="Doutor: tudo bem? Paciente: sim."), graph, observer)
    json_result = await process_content(Input(content='{"patient": {"name": "Ana"}}'), graph, observer)

    assert conv_llm.calls == 1
    assert json_llm.calls == 1
    assert conv_result["classification"] == AgentConfig.CLASSIFICATION_CONVERSATION
    assert json_result["classification"] == AgentConfig.CLASSIFICATION_JSON
