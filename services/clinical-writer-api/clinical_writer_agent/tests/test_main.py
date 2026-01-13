import pytest

from clinical_writer_agent.agent_graph import create_graph, create_default_observer, get_metrics_monitor
from clinical_writer_agent.main import ProcessRequest, get_metrics, process_content, verify_token
from clinical_writer_agent.prompt_registry import create_prompt_registry

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


def _make_graph(observer):
    conv_llm = _StubLLM("conversation")
    json_llm = _StubLLM("json")
    graph = create_graph(observer=observer, conversation_llm=conv_llm, json_llm=json_llm)
    return graph, conv_llm, json_llm


def _collect_report_text(report) -> str:
    parts = []
    for section in report.sections:
        parts.append(section.title)
        for block in section.blocks:
            if block.type == "paragraph":
                parts.append("".join(span.text for span in block.spans))
            elif block.type == "bullet_list":
                for item in block.items:
                    parts.append("".join(span.text for span in item.spans))
            elif block.type == "key_value":
                for item in block.items:
                    parts.append(item.key)
                    parts.append("".join(span.text for span in item.value))
    return "\n".join(parts)


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
    "input_content, input_type, expected_record_part",
    [
        ("Oi, doutor! Tudo bem? Paciente de 17 anos.", "consult", "conversation-response"),
        ('{"patient": {"name": "João", "age": 17}, "surveyId": "lapan_q7"}', "survey7", "json-response"),
        ("This is some random text.", "consult", "conversation-response"),
        ("Hello there! 👋", "consult", "conversation-response"),
        ("This is <b>bold</b> text.", "consult", "conversation-response"),
    ],
)
async def test_process_content_contract(input_content, input_type, expected_record_part):
    observer = create_default_observer()
    graph, *_ = _make_graph(observer)
    registry = create_prompt_registry()
    payload = ProcessRequest(input_type=input_type, content=input_content)
    result = await process_content(payload, graph, observer, registry)
    report_text = _collect_report_text(result.report)
    assert expected_record_part in report_text
    assert isinstance(report_text, str)
    assert len(report_text) > 0


async def test_empty_content_rejected():
    with pytest.raises(ValueError):
        ProcessRequest(input_type="consult", content="   ")


async def test_metrics_reflects_live_observer():
    observer = create_default_observer()
    metrics_monitor = get_metrics_monitor(observer)
    metrics_monitor.reset_metrics()
    graph, *_ = _make_graph(observer)
    registry = create_prompt_registry()

    await process_content(ProcessRequest(input_type="consult", content="Doutor: tudo bem?"), graph, observer, registry)
    await process_content(ProcessRequest(input_type="survey7", content='{"patient": {"name": "Ana"}}'), graph, observer, registry)

    metrics = await get_metrics(observer=observer)
    assert metrics["total_requests"] == 2


async def test_llm_error_path_sets_error_message():
    observer = create_default_observer()
    flaky_llm = _StubLLM("conversation", fail_times=1)
    graph = create_graph(observer=observer, conversation_llm=flaky_llm)
    registry = create_prompt_registry()

    result = await process_content(ProcessRequest(input_type="consult", content="Doutor: tudo bem?"), graph, observer, registry)
    report_text = _collect_report_text(result.report)
    assert "Error generating medical record" in "\n".join(result.warnings)
    assert flaky_llm.calls == 1
