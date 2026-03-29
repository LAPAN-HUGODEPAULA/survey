import json

import pytest

from clinical_writer_agent.agent_graph import create_graph, create_default_observer
from clinical_writer_agent.main import ProcessRequest, process_content
from clinical_writer_agent.prompt_registry import create_prompt_registry

pytestmark = pytest.mark.anyio("asyncio")


class _RequestStub:
    headers = {}


class _StubLLM:
    def __init__(self, name: str):
        self.name = name
        self.calls = 0

    def invoke(self, prompt: str):
        self.calls += 1

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


def _build_graph(observer, critique_llm=None):
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


async def test_schema_validation_rejects_blank_input():
    with pytest.raises(ValueError):
        ProcessRequest(input_type="consult", content="")


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


async def test_sanitized_inputs_flow_to_writer():
    observer = create_default_observer()
    graph, *_ = _build_graph(observer)
    registry = create_prompt_registry()
    inputs = [
        "Hello there! 👋",
        "This is <b>html</b>",
        "Buy now and get a discount!",
    ]
    for text in inputs:
        result = await process_content(
            ProcessRequest(input_type="consult", content=text),
            request=_RequestStub(),
            graph=graph,
            observer=observer,
            prompt_registry=registry,
        )
        report_text = _collect_report_text(result.report)
        assert "conversation-response" in report_text


async def test_json_and_conversation_paths_use_injected_llms():
    observer = create_default_observer()
    graph, conv_llm, json_llm, judge_llm = _build_graph(observer)
    registry = create_prompt_registry()

    conv_result = await process_content(
        ProcessRequest(input_type="consult", content="Doutor: tudo bem? Paciente: sim."),
        request=_RequestStub(),
        graph=graph,
        observer=observer,
        prompt_registry=registry,
    )
    json_result = await process_content(
        ProcessRequest(input_type="survey7", content='{"patient": {"name": "Ana"}}'),
        request=_RequestStub(),
        graph=graph,
        observer=observer,
        prompt_registry=registry,
    )

    assert conv_llm.calls == 2
    assert json_llm.calls == 2
    assert judge_llm.calls == 2
    assert "conversation-response" in _collect_report_text(conv_result.report)
    assert "json-response" in _collect_report_text(json_result.report)


async def test_reflection_requests_rewrite_before_success():
    observer = create_default_observer()

    class _RewriteAwareWriterLLM(_StubLLM):
        def invoke(self, prompt: str):
            self.calls += 1

            class Response:
                def __init__(self, content: str):
                    self.content = content

            if "clinical analysis engine" in prompt.lower():
                return Response(json.dumps({"summary": "json-facts"}))

            subtitle = "Initial Draft"
            text = "json-response"
            if "REFLECTOR CORRECTION FEEDBACK" in prompt:
                subtitle = "Corrected Draft"
                text = "json-response-corrected"

            report = {
                "title": "Relatorio Clinico",
                "subtitle": subtitle,
                "created_at": "2026-01-14T18:42:03Z",
                "patient": {},
                "sections": [
                    {
                        "title": "Resumo",
                        "blocks": [
                            {
                                "type": "paragraph",
                                "spans": [{"text": text, "bold": False, "italic": False}],
                            }
                        ],
                    }
                ],
            }
            return Response(json.dumps(report))

    conv_llm = _StubLLM("conversation")
    json_llm = _RewriteAwareWriterLLM("json")
    judge_llm = _StubCritiqueLLM(
        payloads=[
            {
                "decision": "fail",
                "issues": ["Contains a prescription for school staff."],
                "feedback": "Remove the prescription and use educational language.",
            },
            {"decision": "pass", "issues": [], "feedback": ""},
        ]
    )
    graph = create_graph(
        observer=observer,
        conversation_llm=conv_llm,
        json_llm=json_llm,
        critique_llm=judge_llm,
    )
    registry = create_prompt_registry()

    result = await process_content(
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

    assert judge_llm.calls == 2
    assert json_llm.calls == 3
    assert "json-response-corrected" in _collect_report_text(result.report)
