from clinical_writer_agent.analysis_engine import (
    extract_entities,
    detect_alerts,
    generate_suggestions,
    generate_hypotheses,
    knowledge_lookup,
)
from clinical_writer_agent.analysis_models import AnalysisMessage


def _msg(content: str) -> AnalysisMessage:
    return AnalysisMessage(role="clinician", content=content, messageType="user")


def test_extract_entities_and_alerts():
    messages = [
        _msg("Paciente com 45 anos, dor no peito e falta de ar."),
        _msg("Usa warfarin e ibuprofen."),
    ]
    entities = extract_entities(messages)
    assert any(e.type == "age" for e in entities)
    alerts = detect_alerts(messages)
    assert any(alert.severity == "high" for alert in alerts)


def test_generate_suggestions():
    messages = [_msg("Paciente relata dor e febre há 2 dias.")]
    suggestions = generate_suggestions(messages)
    assert any("allergies" in s.text.lower() for s in suggestions)


def test_generate_hypotheses_and_knowledge():
    messages = [_msg("Patient with anxiety and fever.")]
    hypotheses = generate_hypotheses(messages)
    assert any("anxiety" in h.label.lower() for h in hypotheses)
    knowledge = knowledge_lookup(messages)
    assert any("ICD-10" in k.label for k in knowledge)
