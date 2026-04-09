import json

from clinical_writer_agent.agents.clinical_analyzer_agent import ClinicalAnalyzerAgent
from clinical_writer_agent.agents.context_loader_agent import ContextLoaderAgent
from clinical_writer_agent.agents.persona_writer_agent import PersonaWriterAgent
from clinical_writer_agent.agents.reflector_node import ReflectorNode
from clinical_writer_agent.prompt_registry import PromptNotFoundError, ResolvedPrompt


class _Response:
    def __init__(self, content: str):
        self.content = content


class _StubRegistry:
    def __init__(self, resolved_prompt: ResolvedPrompt | None = None, error: Exception | None = None):
        self._resolved_prompt = resolved_prompt
        self._error = error

    def resolve_process_prompt(self, **_kwargs):
        if self._error is not None:
            raise self._error
        return self._resolved_prompt


class _StubLLM:
    def __init__(self, payload: dict, *, name: str = "stub-model"):
        self.payload = payload
        self.name = name
        self.prompts: list[str] = []

    def invoke(self, prompt: str):
        self.prompts.append(prompt)
        return _Response(json.dumps(self.payload))


def _report_payload(label: str) -> dict:
    return {
        "title": "Relatorio Clinico",
        "subtitle": label,
        "created_at": "2026-01-14T18:42:03Z",
        "patient": {},
        "sections": [
            {
                "title": "Resumo",
                "blocks": [
                    {
                        "type": "paragraph",
                        "spans": [{"text": label, "bold": False, "italic": False}],
                    }
                ],
            }
        ],
    }


def test_context_loader_hydrates_split_prompts():
    resolved = ResolvedPrompt(
        prompt_text="combined prompt",
        prompt_version="combined-version",
        interpretation_prompt="analyze survey strictly",
        persona_prompt="write for school staff",
        questionnaire_prompt_version="questionnaire-v1",
        persona_skill_version="persona-v2",
        persona_skill_key="school_report",
        output_profile="school_report",
    )
    agent = ContextLoaderAgent(_StubRegistry(resolved_prompt=resolved))

    result = agent.load(
        {
            "input_type": "survey7",
            "prompt_key": "survey7",
            "persona_skill_key": "school_report",
            "output_profile": "school_report",
        }
    )

    assert result["interpretation_prompt"] == "analyze survey strictly"
    assert result["persona_prompt"] == "write for school staff"
    assert result["questionnaire_prompt_version"] == "questionnaire-v1"
    assert result["persona_skill_version"] == "persona-v2"


def test_context_loader_marks_prompt_lookup_errors():
    agent = ContextLoaderAgent(
        _StubRegistry(error=PromptNotFoundError("missing school_report"))
    )

    result = agent.load({"input_type": "survey7", "prompt_key": "survey7"})

    assert result["validation_status"] == "prompt_not_found"
    assert result["error_kind"] == "prompt_not_found"
    assert "missing school_report" in result["error_message"]


def test_clinical_analyzer_writes_structured_facts():
    agent = ClinicalAnalyzerAgent(
        conversation_llm=_StubLLM({"summary": "facts", "scores": {"visual": 3}}, name="conversation"),
    )

    result = agent.analyze(
        {
            "input_type": "consult",
            "interpretation_prompt": "extract clinical findings",
            "input_content": "Paciente relata fotofobia.",
        }
    )

    assert result["clinical_facts"]["summary"] == "facts"
    assert result["clinical_facts"]["scores"]["visual"] == 3
    assert result["model_version"] == "conversation"


def test_persona_writer_generates_report_and_draft():
    agent = PersonaWriterAgent(
        json_llm=_StubLLM(_report_payload("school-json"), name="json"),
    )

    result = agent.write(
        {
            "input_type": "survey7",
            "persona_prompt": "write with school tone",
            "clinical_facts": {"summary": "moderate visual distress"},
        }
    )

    assert result["report"]["subtitle"] == "school-json"
    assert "Relatorio Clinico" in result["draft_narrative"]
    assert result["medical_record"] == result["draft_narrative"]
    assert result["model_version"] == "json"


def test_persona_writer_includes_reflector_feedback_on_rewrite():
    llm = _StubLLM(_report_payload("rewrite"), name="json")
    agent = PersonaWriterAgent(json_llm=llm)

    agent.write(
        {
            "input_type": "survey7",
            "persona_prompt": "write with school tone",
            "clinical_facts": {"summary": "moderate visual distress"},
            "reflection_feedback": "Remove prescriptive medical guidance.",
            "reflection_retries_used": 1,
        }
    )

    assert "REFLECTOR CORRECTION FEEDBACK" in llm.prompts[0]
    assert "Remove prescriptive medical guidance." in llm.prompts[0]


def test_reflector_passes_safe_report():
    reflector = ReflectorNode(
        critique_llm=_StubLLM(
            {"decision": "pass", "issues": [], "feedback": ""},
            name="judge",
        )
    )

    result = reflector.reflect(
        {
            "report": _report_payload("safe school report"),
            "clinical_facts": {"summary": "moderate visual distress"},
            "output_profile": "school_report",
        }
    )

    assert result["reflection_status"] == "passed"
    assert result["validation_status"] == "reflection_passed"
    assert result["critique_model_version"] == "judge"


def test_reflector_requests_rewrite_for_school_prescription():
    reflector = ReflectorNode(
        critique_llm=_StubLLM(
            {
                "decision": "fail",
                "issues": ["Contains a medical prescription for a school audience."],
                "feedback": "Remove the prescription and rewrite for school staff.",
            },
            name="judge",
        )
    )

    result = reflector.reflect(
        {
            "report": _report_payload("unsafe school report"),
            "clinical_facts": {"summary": "moderate visual distress"},
            "output_profile": "school_report",
            "reflection_retries_used": 0,
            "max_reflection_iterations": 2,
        }
    )

    assert result["reflection_status"] == "failed"
    assert result["reflection_retries_used"] == 1
    assert "Remove the prescription" in result["reflection_feedback"]
    assert "error_message" not in result


def test_reflector_fails_after_iteration_cap():
    reflector = ReflectorNode(
        critique_llm=_StubLLM(
            {
                "decision": "fail",
                "issues": ["Tone remains too prescriptive."],
                "feedback": "Rewrite with school-friendly tone.",
            },
            name="judge",
        )
    )

    result = reflector.reflect(
        {
            "report": _report_payload("still unsafe"),
            "clinical_facts": {"summary": "moderate visual distress"},
            "output_profile": "school_report",
            "reflection_retries_used": 2,
            "max_reflection_iterations": 2,
        }
    )

    assert result["error_kind"] == "reflection_failed"
    assert "safe final report" in result["error_message"]
