import pytest

from clinical_writer_agent.agent_graph import create_graph, create_default_observer
from clinical_writer_agent.main import ProcessRequest, process_content
from clinical_writer_agent.prompt_registry import create_prompt_registry

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


def _build_graph(observer):
    conv_llm = _StubLLM("conversation")
    json_llm = _StubLLM("json")
    graph = create_graph(observer=observer, conversation_llm=conv_llm, json_llm=json_llm)
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
    inputs = [
        "Hello there! 👋",
        "This is <b>html</b>",
        "Buy now and get a discount!",
    ]
    for text in inputs:
        result = await process_content(
            ProcessRequest(input_type="consult", content=text),
            graph,
            observer,
            registry,
        )
        report_text = _collect_report_text(result.report)
        assert "conversation-response" in report_text


async def test_json_and_conversation_paths_use_injected_llms():
    observer = create_default_observer()
    graph, conv_llm, json_llm = _build_graph(observer)
    registry = create_prompt_registry()

    conv_result = await process_content(
        ProcessRequest(input_type="consult", content="Doutor: tudo bem? Paciente: sim."),
        graph,
        observer,
        registry,
    )
    json_result = await process_content(
        ProcessRequest(input_type="survey7", content='{"patient": {"name": "Ana"}}'),
        graph,
        observer,
        registry,
    )

    assert conv_llm.calls == 1
    assert json_llm.calls == 1
    assert "conversation-response" in _collect_report_text(conv_result.report)
    assert "json-response" in _collect_report_text(json_result.report)
