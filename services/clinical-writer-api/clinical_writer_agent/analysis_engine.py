import re
from typing import List

from .analysis_models import (
    AnalysisMessage,
    Suggestion,
    Entity,
    ClinicalAlert,
    DiagnosticHypothesis,
    KnowledgeItem,
)


_ALERT_KEYWORDS = {
    "suicidal": ("Potential self-harm risk reported.", "high"),
    "suicidio": ("Potential self-harm risk reported.", "high"),
    "chest pain": ("Chest pain mentioned; evaluate urgently.", "high"),
    "dor no peito": ("Chest pain mentioned; evaluate urgently.", "high"),
    "shortness of breath": ("Shortness of breath reported.", "medium"),
    "falta de ar": ("Shortness of breath reported.", "medium"),
}

_HYPOTHESIS_KEYWORDS = {
    "depression": "Possible depressive symptoms",
    "depressao": "Possible depressive symptoms",
    "anxiety": "Possible anxiety symptoms",
    "ansiedade": "Possible anxiety symptoms",
    "infection": "Possible infection",
    "febre": "Possible infection",
}

_ENTITY_PATTERNS = {
    "age": r"\b(\d{1,3})\s*(anos|years)\b",
    "medication": r"\b(aspirin|ibuprofen|paracetamol|dipirona|warfarin)\b",
    "symptom": r"\b(dor|pain|febre|fever|nausea|tontura|dizziness)\b",
}

_CODE_LOOKUP = {
    "depression": ("ICD-10 F32", "ICD-10"),
    "anxiety": ("ICD-10 F41", "ICD-10"),
    "fever": ("ICD-10 R50", "ICD-10"),
}

_INTERACTIONS = [
    ({"warfarin", "ibuprofen"}, "Potential bleeding risk (warfarin + NSAID)."),
]


def _aggregate_text(messages: List[AnalysisMessage]) -> str:
    return "\n".join(msg.content for msg in messages if msg.content)


def extract_entities(messages: List[AnalysisMessage]) -> List[Entity]:
    text = _aggregate_text(messages).lower()
    entities: List[Entity] = []
    for entity_type, pattern in _ENTITY_PATTERNS.items():
        for match in re.findall(pattern, text):
            value = match[0] if isinstance(match, tuple) else match
            entities.append(Entity(type=entity_type, value=str(value), confidence=0.7))
    return entities


def detect_phase(messages: List[AnalysisMessage]) -> str:
    text = _aggregate_text(messages).lower()
    if "plan" in text or "plano" in text:
        return "plan"
    if "assessment" in text or "avaliacao" in text:
        return "assessment"
    if "follow-up" in text or "acompanhamento" in text:
        return "wrap_up"
    return "intake"


def generate_suggestions(messages: List[AnalysisMessage]) -> List[Suggestion]:
    text = _aggregate_text(messages).lower()
    suggestions: List[Suggestion] = []
    if "allerg" not in text and "alerg" not in text:
        suggestions.append(
            Suggestion(
                id="missing-allergies",
                text="Ask about allergies and adverse reactions.",
                category="missing_info",
                confidence=0.6,
            )
        )
    if "medication" not in text and "medic" not in text:
        suggestions.append(
            Suggestion(
                id="missing-medications",
                text="Ask about current medications and dosages.",
                category="missing_info",
                confidence=0.6,
            )
        )
    if "duration" not in text and "quanto tempo" not in text:
        suggestions.append(
            Suggestion(
                id="missing-duration",
                text="Clarify symptom duration and onset.",
                category="follow_up",
                confidence=0.55,
            )
        )
    return suggestions


def generate_hypotheses(messages: List[AnalysisMessage]) -> List[DiagnosticHypothesis]:
    text = _aggregate_text(messages).lower()
    hypotheses: List[DiagnosticHypothesis] = []
    for keyword, label in _HYPOTHESIS_KEYWORDS.items():
        if keyword in text:
            hypotheses.append(
                DiagnosticHypothesis(
                    id=f"hyp-{keyword}",
                    label=label,
                    confidence=0.4,
                    evidence=f"Keyword match: {keyword}",
                )
            )
    return hypotheses


def detect_alerts(messages: List[AnalysisMessage]) -> List[ClinicalAlert]:
    text = _aggregate_text(messages).lower()
    alerts: List[ClinicalAlert] = []
    for keyword, (text_alert, severity) in _ALERT_KEYWORDS.items():
        if keyword in text:
            alerts.append(
                ClinicalAlert(
                    id=f"alert-{keyword.replace(' ', '-')}",
                    text=text_alert,
                    severity=severity,
                    evidence=f"Matched term: {keyword}",
                )
            )
    return alerts


def knowledge_lookup(messages: List[AnalysisMessage]) -> List[KnowledgeItem]:
    text = _aggregate_text(messages).lower()
    items: List[KnowledgeItem] = []
    for keyword, (label, source) in _CODE_LOOKUP.items():
        if keyword in text:
            items.append(
                KnowledgeItem(
                    id=f"code-{keyword}",
                    label=label,
                    source=source,
                    reference=keyword,
                )
            )
    meds = {match[0] if isinstance(match, tuple) else match for match in re.findall(_ENTITY_PATTERNS["medication"], text)}
    for combo, warning in _INTERACTIONS:
        if combo.issubset(meds):
            items.append(
                KnowledgeItem(
                    id="interaction-warfarin-nsaid",
                    label=warning,
                    source="interaction_rules",
                )
            )
    return items
