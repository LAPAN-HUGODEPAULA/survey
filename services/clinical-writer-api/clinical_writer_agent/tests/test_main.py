import json

import pytest
from fastapi import HTTPException

from clinical_writer_agent.agent_graph import create_graph, create_default_observer, get_metrics_monitor
from clinical_writer_agent.main import ProcessRequest, get_metrics, process_content, verify_token
from clinical_writer_agent.prompt_registry import create_prompt_registry

pytestmark = pytest.mark.anyio("asyncio")


class _RequestStub:
    headers = {}

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

        if "clinical analysis engine" in prompt.lower():
            return Response(json.dumps({"summary": f"{self.name}-facts"}))

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


class _StubCritiqueLLM:
    def __init__(self, payloads: list[dict] | None = None, name: str = "judge"):
        self.name = name
        self.payloads = payloads or [{"decision": "pass", "issues": [], "feedback": ""}]
        self.calls = 0

    def invoke(self, prompt: str):
        self.calls += 1
        index = min(self.calls - 1, len(self.payloads) - 1)

        class Response:
            def __init__(self, content: str):
                self.content = content

        return Response(json.dumps(self.payloads[index]))


def _make_graph(observer, critique_llm=None):
    conv_llm = _StubLLM("conversation")
    json_llm = _StubLLM("json")
    judge_llm = critique_llm or _StubCritiqueLLM()
    graph = create_graph(
        observer=observer,
        conversation_llm=conv_llm,
        json_llm=json_llm,
        critique_llm=judge_llm,
    )
    return graph, conv_llm, json_llm, judge_llm


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
    monkeypatch.delenv("ENVIRONMENT", raising=False)
    monkeypatch.delenv("ALLOW_UNAUTHENTICATED_ACCESS", raising=False)
    assert verify_token() is True


def test_verify_token_rejects_missing(monkeypatch):
    monkeypatch.setenv("API_TOKEN", "secret-token")
    with pytest.raises(Exception):
        verify_token(api_key=None)


def test_verify_token_accepts_valid(monkeypatch):
    monkeypatch.setenv("API_TOKEN", "secret-token")
    assert verify_token(api_key="Bearer secret-token") is True


def test_verify_token_rejects_missing_token_in_production(monkeypatch):
    monkeypatch.delenv("API_TOKEN", raising=False)
    monkeypatch.setenv("ENVIRONMENT", "production")
    monkeypatch.delenv("ALLOW_UNAUTHENTICATED_ACCESS", raising=False)
    with pytest.raises(HTTPException) as exc_info:
        verify_token()
    assert exc_info.value.status_code == 503


def test_verify_token_allows_explicit_unsafe_override(monkeypatch):
    monkeypatch.delenv("API_TOKEN", raising=False)
    monkeypatch.setenv("ENVIRONMENT", "production")
    monkeypatch.setenv("ALLOW_UNAUTHENTICATED_ACCESS", "true")
    assert verify_token() is True


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
    result = await process_content(
        payload,
        request=_RequestStub(),
        graph=graph,
        observer=observer,
        prompt_registry=registry,
    )
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

    await process_content(
        ProcessRequest(input_type="consult", content="Doutor: tudo bem?"),
        request=_RequestStub(),
        graph=graph,
        observer=observer,
        prompt_registry=registry,
    )
    await process_content(
        ProcessRequest(input_type="survey7", content='{"patient": {"name": "Ana"}}'),
        request=_RequestStub(),
        graph=graph,
        observer=observer,
        prompt_registry=registry,
    )

    metrics = await get_metrics(observer=observer)
    assert metrics["total_requests"] == 2


async def test_llm_error_path_sets_error_message():
    observer = create_default_observer()
    flaky_llm = _StubLLM("conversation", fail_times=1)
    graph = create_graph(
        observer=observer,
        conversation_llm=flaky_llm,
        critique_llm=_StubCritiqueLLM(),
    )
    registry = create_prompt_registry()

    with pytest.raises(HTTPException) as exc_info:
        await process_content(
            ProcessRequest(input_type="consult", content="Doutor: tudo bem?"),
            request=_RequestStub(),
            graph=graph,
            observer=observer,
            prompt_registry=registry,
        )

    assert exc_info.value.status_code == 500
    assert "temporary failure" in str(exc_info.value.detail)
    assert flaky_llm.calls == 1


def test_graph_ascii_contains_layered_nodes():
    observer = create_default_observer()
    graph, *_ = _make_graph(observer)
    inner_graph = graph.get_graph()

    try:
        ascii_graph = inner_graph.draw_ascii()
        assert "context_loader" in ascii_graph
        assert "clinical_analyzer" in ascii_graph
        assert "persona_writer" in ascii_graph
        assert "reflector" in ascii_graph
    except ImportError:
        assert "context_loader" in inner_graph.nodes
        assert "clinical_analyzer" in inner_graph.nodes
        assert "persona_writer" in inner_graph.nodes
        assert "reflector" in inner_graph.nodes


async def test_reflection_failure_after_iteration_cap_surfaces_http_error():
    observer = create_default_observer()
    critique_llm = _StubCritiqueLLM(
        payloads=[
            {
                "decision": "fail",
                "issues": ["Contains a prescription for school staff."],
                "feedback": "Remove the prescription.",
            },
            {
                "decision": "fail",
                "issues": ["Tone remains too prescriptive."],
                "feedback": "Use school-friendly language.",
            },
            {
                "decision": "fail",
                "issues": ["Still contains invasive guidance."],
                "feedback": "Remove all medical directives.",
            },
        ]
    )
    graph, *_ = _make_graph(observer, critique_llm=critique_llm)
    registry = create_prompt_registry()

    with pytest.raises(HTTPException) as exc_info:
        await process_content(
            ProcessRequest(
                input_type="survey7",
                content='{"patient": {"name": "Ana"}}',
                output_profile="school_report",
            ),
            request=_RequestStub(),
            graph=graph,
            observer=observer,
            prompt_registry=registry,
        )

    assert exc_info.value.status_code == 500
    assert "safe final report" in str(exc_info.value.detail)
