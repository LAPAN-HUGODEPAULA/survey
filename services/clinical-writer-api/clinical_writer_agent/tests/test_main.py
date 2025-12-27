import pytest

from clinical_writer_agent.agent_graph import create_graph, create_default_observer, get_metrics_monitor
from clinical_writer_agent.agent_config import AgentConfig
from clinical_writer_agent.agents.agent_state import AgentState
from clinical_writer_agent.main import Input, get_metrics, process_content, verify_token

pytestmark = pytest.mark.anyio("asyncio")

class _StubLLM:
    def __init__(self, name: str, fail_times: int = 0):
        self.name = name
        self.fail_times = fail_times
        self.calls = 0

    def invoke(self, prompt: str):
        self.calls += 1
        if self.calls <= self.fail_times:
            raise RuntimeError("temporary failure")

        class Response:
            def __init__(self, content: str):
                self.content = content

        return Response(f"{self.name}-response")


class _StubJudge:
    def __init__(self, score: float = 1.0):
        self.score = score
        self.calls = 0

    def invoke(self, prompt: str):
        self.calls += 1

        class Response:
            def __init__(self, content: str):
                self.content = content

        return Response(str(self.score))


def _make_graph(observer):
    conv_llm = _StubLLM("conversation")
    json_llm = _StubLLM("json")
    judge_llm = _StubJudge(0.9)
    graph = create_graph(observer=observer, conversation_llm=conv_llm, json_llm=json_llm, judge_llm=judge_llm)
    return graph, conv_llm, json_llm, judge_llm


def test_verify_token_allows_when_unset(monkeypatch):
    monkeypatch.delenv("API_TOKEN", raising=False)
    assert verify_token() is True


def test_verify_token_rejects_missing(monkeypatch):
    monkeypatch.setenv("API_TOKEN", "secret-token")
    with pytest.raises(Exception):
        verify_token(api_key=None)


def test_verify_token_accepts_valid(monkeypatch):
    monkeypatch.setenv("API_TOKEN", "secret-token")
    assert verify_token(api_key="Bearer secret-token") is True


@pytest.mark.parametrize(
    "input_content, expected_classification, expected_record_part",
    [
        ("Oi, doutor! Tudo bem? Paciente de 17 anos.", AgentConfig.CLASSIFICATION_CONVERSATION, "conversation-response"),
        ('{"patient": {"name": "João", "age": 17}, "surveyId": "lapan_q7"}', AgentConfig.CLASSIFICATION_JSON, "json-response"),
        ("This is some random text.", AgentConfig.CLASSIFICATION_OTHER, "could not be classified"),
        ("Hello there! 👋", AgentConfig.CLASSIFICATION_FLAGGED, "flagged as inappropriate"),
        ("This is <b>bold</b> text.", AgentConfig.CLASSIFICATION_OTHER, "could not be classified"),
    ],
)
async def test_process_content_contract(input_content, expected_classification, expected_record_part):
    observer = create_default_observer()
    graph, *_ = _make_graph(observer)
    payload = Input(content=input_content)
    result = await process_content(payload, graph, observer)
    assert result["classification"] == expected_classification
    assert expected_record_part in result["medical_record"]
    assert isinstance(result["medical_record"], str)
    assert len(result["medical_record"]) > 0


async def test_empty_content_rejected():
    with pytest.raises(ValueError):
        Input(content="   ")


async def test_metrics_reflects_live_observer():
    observer = create_default_observer()
    metrics_monitor = get_metrics_monitor(observer)
    metrics_monitor.reset_metrics()
    graph, *_ = _make_graph(observer)

    await process_content(Input(content="Doutor: tudo bem?"), graph, observer)
    await process_content(Input(content='{"patient": {"name": "Ana"}}'), graph, observer)

    metrics = await get_metrics(observer=observer)
    assert metrics["total_requests"] == 2
    assert metrics["classifications"]["conversation"] == 1
    assert metrics["classifications"]["json"] == 1


async def test_llm_error_path_sets_error_message():
    observer = create_default_observer()
    flaky_llm = _StubLLM("conversation", fail_times=1)
    judge_llm = _StubJudge(0.9)
    graph = create_graph(observer=observer, conversation_llm=flaky_llm, judge_llm=judge_llm)

    result = await process_content(Input(content="Doutor: tudo bem?"), graph, observer)
    assert result["classification"] == AgentConfig.CLASSIFICATION_OTHER
    assert "Error generating medical record" in result["error_message"]
    assert flaky_llm.calls == 1
