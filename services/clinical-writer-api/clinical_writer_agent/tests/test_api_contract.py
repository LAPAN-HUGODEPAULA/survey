import json

import pytest

from clinical_writer_agent.agent_graph import create_graph, create_default_observer, get_progress_tracker
from clinical_writer_agent.main import ProcessRequest, process_content
from clinical_writer_agent.prompt_registry import create_prompt_registry

pytestmark = pytest.mark.anyio("asyncio")


class _RequestStub:
    headers = {}


class _StubLLM:
    def __init__(self, name: str):
        self.name = name
        self.calls = 0
        self.prompts: list[str] = []

    def invoke(self, prompt: str):
        self.calls += 1
        self.prompts.append(prompt)

        class Response:
            def __init__(self, content: str):
                self.content = content

        if "clinical analysis engine" in prompt.lower():
            return Response(json.dumps({"summary": f"{self.name}-facts"}))
        if "clinical reflection validator" in prompt.lower():
            return Response(
                json.dumps(
                    {
                        "grounded": True,
                        "tone_ok": True,
                        "safety_ok": True,
                        "issues": [],
                        "revision_instructions": "",
                    }
                )
            )

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


def _build_graph(observer):
    conv_llm = _StubLLM("conversation")
    json_llm = _StubLLM("json")
    graph = create_graph(
        observer=observer,
        conversation_llm=conv_llm,
        json_llm=json_llm,
    )
    return graph, conv_llm, json_llm


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
    tracker = get_progress_tracker()
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
            tracker=tracker,
        )
        report_text = _collect_report_text(result.report)
        assert "conversation-response" in report_text


async def test_json_and_conversation_paths_use_injected_llms():
    observer = create_default_observer()
    graph, conv_llm, json_llm = _build_graph(observer)
    registry = create_prompt_registry()
    tracker = get_progress_tracker()

    conv_result = await process_content(
        ProcessRequest(input_type="consult", content="Doutor: tudo bem? Paciente: sim."),
        request=_RequestStub(),
        graph=graph,
        observer=observer,
        prompt_registry=registry,
        tracker=tracker,
    )
    json_result = await process_content(
        ProcessRequest(input_type="survey7", content='{"patient": {"name": "Ana"}}'),
        request=_RequestStub(),
        graph=graph,
        observer=observer,
        prompt_registry=registry,
        tracker=tracker,
    )

    assert conv_llm.calls == 3
    assert json_llm.calls == 3
    assert "conversation-response" in _collect_report_text(conv_result.report)
    assert "json-response" in _collect_report_text(json_result.report)


async def test_request_prompt_overrides_reach_graph_nodes():
    observer = create_default_observer()
    graph, _, json_llm = _build_graph(observer)
    registry = create_prompt_registry()
    tracker = get_progress_tracker()

    await process_content(
        ProcessRequest(
            input_type="survey7",
            content='{"patient": {"name": "Ana"}}',
            system_prompt_override="ACCESS_POINT_SYSTEM_OVERRIDE",
            format_prompt_override="ACCESS_POINT_FORMAT_OVERRIDE",
        ),
        request=_RequestStub(),
        graph=graph,
        observer=observer,
        prompt_registry=registry,
        tracker=tracker,
    )

    assert "ACCESS_POINT_SYSTEM_OVERRIDE" in json_llm.prompts[0]
    assert "ACCESS_POINT_SYSTEM_OVERRIDE" in json_llm.prompts[1]
    assert "ACCESS_POINT_FORMAT_OVERRIDE" in json_llm.prompts[0]
    assert "ACCESS_POINT_FORMAT_OVERRIDE" in json_llm.prompts[1]


async def test_default_flow_finishes_after_reflector_validation():
    observer = create_default_observer()
    tracker = get_progress_tracker()

    class _RewriteAwareWriterLLM(_StubLLM):
        def invoke(self, prompt: str):
            self.calls += 1

            class Response:
                def __init__(self, content: str):
                    self.content = content

            if "clinical analysis engine" in prompt.lower():
                return Response(json.dumps({"summary": "json-facts"}))
            if "clinical reflection validator" in prompt.lower():
                return Response(
                    json.dumps(
                        {
                            "grounded": True,
                            "tone_ok": True,
                            "safety_ok": True,
                            "issues": [],
                            "revision_instructions": "",
                        }
                    )
                )

            report = {
                "title": "Relatorio Clinico",
                "subtitle": "Initial Draft",
                "created_at": "2026-01-14T18:42:03Z",
                "patient": {},
                "sections": [
                    {
                        "title": "Resumo",
                        "blocks": [
                            {
                                "type": "paragraph",
                                "spans": [{"text": "json-response", "bold": False, "italic": False}],
                            }
                        ],
                    }
                ],
            }
            return Response(json.dumps(report))

    conv_llm = _StubLLM("conversation")
    json_llm = _RewriteAwareWriterLLM("json")
    graph = create_graph(
        observer=observer,
        conversation_llm=conv_llm,
        json_llm=json_llm,
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
        tracker=tracker,
    )

    assert json_llm.calls == 3
    assert "json-response" in _collect_report_text(result.report)
