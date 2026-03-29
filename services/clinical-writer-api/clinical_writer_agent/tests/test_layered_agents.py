import json

from clinical_writer_agent.agents.clinical_analyzer_agent import ClinicalAnalyzerAgent
from clinical_writer_agent.agents.context_loader_agent import ContextLoaderAgent
from clinical_writer_agent.agents.persona_writer_agent import PersonaWriterAgent
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
