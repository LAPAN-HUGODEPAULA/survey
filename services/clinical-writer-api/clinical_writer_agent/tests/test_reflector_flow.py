import json
import os

from clinical_writer_agent.agent_graph import create_graph
from clinical_writer_agent.agents.clinical_analyzer_agent import ClinicalAnalyzerAgent
from clinical_writer_agent.agents.persona_writer_agent import PersonaWriterAgent
from clinical_writer_agent.agents.reflector_agent import ReflectorAgent
from clinical_writer_agent.agents.schemas import ReflectorInput


class _Response:
    def __init__(self, content: str):
        self.content = content


class _RetryingJsonLLM:
    def __init__(self):
        self.prompts: list[str] = []
        self.writer_calls = 0

    def invoke(self, prompt: str):
        self.prompts.append(prompt)
        if "clinical analysis engine" in prompt.lower():
            return _Response(
                json.dumps(
                    {
                        "summary": "moderate visual distress",
                        "clinical_findings": ["fotossensibilidade autorreferida"],
                        "scores": {"visual": 3},
                    }
                )
            )

        self.writer_calls += 1
        subtitle = "Corrected Draft" if "REFLECTION FEEDBACK" in prompt else "Initial Draft"
        text = "grounded-response" if "REFLECTION FEEDBACK" in prompt else "unsupported-response"
        return _Response(
            json.dumps(
                {
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
            )
        )


class _ReflectorLLM:
    def __init__(self):
        self.prompts: list[str] = []

    def invoke(self, prompt: str):
        self.prompts.append(prompt)
        if "unsupported-response" in prompt:
            return _Response(
                json.dumps(
                    {
                        "grounded": False,
                        "tone_ok": True,
                        "safety_ok": True,
                        "issues": ["Remove unsupported-response and keep grounded wording."],
                        "revision_instructions": "Replace unsupported-response with grounded wording.",
                    }
                )
            )
        return _Response(
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


def test_graph_retries_persona_writer_after_reflection_failure():
    json_llm = _RetryingJsonLLM()
    reflector_llm = _ReflectorLLM()
    graph = create_graph(
        json_llm=json_llm,
        reflector_llm=reflector_llm,
        prompt_registry=None,
    )

    result = graph.invoke(
        {
            "input_type": "survey7",
            "input_content": '{"patient": {"name": "Ana"}}',
            "prompt_key": "default",
            "prompt_text": "combined prompt",
            "interpretation_prompt": "extract facts conservatively",
            "persona_prompt": "write for school staff",
            "validation_status": "context_loaded",
            "observer": None,
        }
    )

    assert json_llm.writer_calls == 2
    assert result["reflection_retries_used"] == 1
    assert result["reflection_outcome"] == "accepted"
    assert result["report"]["subtitle"] == "Corrected Draft"
    assert "Replace unsupported-response" in json_llm.prompts[-1]


def test_prompt_prefix_layout_keeps_static_context_before_dynamic_content():
    analyzer_prompt = ClinicalAnalyzerAgent._build_prompt(
        input_type="survey7",
        interpretation_prompt="interpret carefully",
        content='{"patient": {"name": "Ana"}}',
        format_override=None,
    )
    writer_prompt = PersonaWriterAgent._build_prompt(
        persona_prompt="write for school staff",
        clinical_facts={"summary": "moderate visual distress"},
        format_override=None,
        reflection_feedback="remove unsupported phrasing",
        reflection_retries_used=1,
    )
    reflector_prompt = ReflectorAgent._build_prompt(
        ReflectorInput(
            input_type="survey7",
            persona_prompt="write for school staff",
            clinical_facts={"summary": "moderate visual distress"},
            report={
                "title": "Relatorio Clinico",
                "subtitle": "Draft",
                "created_at": "2026-01-14T18:42:03Z",
                "patient": {},
                "sections": [],
            },
        )
    )

    assert analyzer_prompt.index("CLINICAL INTERPRETATION RULES") < analyzer_prompt.index("SOURCE INPUT")
    assert writer_prompt.index("PERSONA STYLE AND RESTRICTIONS") < writer_prompt.index("CLINICAL FACTS")
    assert writer_prompt.index("REFLECTION FEEDBACK") < writer_prompt.index("CLINICAL FACTS")
    assert reflector_prompt.index("PERSONA STYLE AND RESTRICTIONS") < reflector_prompt.index("CLINICAL FACTS")
    assert reflector_prompt.index("CLINICAL FACTS") < reflector_prompt.index("REPORT DRAFT")
