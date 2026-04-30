"""Shared default access-point seed data for Mongo migrations."""

from __future__ import annotations

from datetime import datetime, timezone


ACCESS_POINT_SEED_SOURCE = "default_agent_access_points_v1"

DEFAULT_AGENT_ACCESS_POINT_SEEDS = [
    {
        "accessPointKey": "survey_frontend.thank_you.auto_analysis",
        "name": "Análise automática do questionário profissional",
        "sourceApp": "survey-frontend",
        "flowKey": "thank_you.auto_analysis",
        "promptKey": "survey7",
        "personaSkillKey": "patient_condition_overview",
        "outputProfile": "patient_condition_overview",
        "description": (
            "Gera automaticamente o relatório final após o envio do "
            "questionário pelo profissional usando a base de triagem de pacientes."
        ),
    },
    {
        "accessPointKey": "survey_patient.thank_you.auto_analysis",
        "name": "Análise automática do questionário do paciente",
        "sourceApp": "survey-patient",
        "flowKey": "thank_you.auto_analysis",
        "promptKey": "survey7",
        "personaSkillKey": "patient_condition_overview",
        "outputProfile": "patient_condition_overview",
        "description": (
            "Gera automaticamente a avaliação preliminar após o envio do "
            "questionário pelo paciente."
        ),
    },
    {
        "accessPointKey": "survey_patient.report.detailed_analysis",
        "name": "Relatório detalhado do questionário do paciente",
        "sourceApp": "survey-patient",
        "flowKey": "report.detailed_analysis",
        "promptKey": "survey7",
        "personaSkillKey": "patient_condition_report",
        "outputProfile": "patient_condition_report",
        "description": (
            "Gera o relatório clínico detalhado a partir das respostas "
            "do questionário do paciente."
        ),
    },
    {
        "accessPointKey": "screener.report.detailed_analysis",
        "name": "Relatório clínico detalhado do paciente",
        "sourceApp": "survey-frontend",
        "flowKey": "report.detailed_analysis",
        "promptKey": "full_intake",
        "personaSkillKey": "clinical_diagnostic_report",
        "outputProfile": "clinical_diagnostic_report",
        "description": (
            "Gera um relatório clínico detalhado do paciente a partir das "
            "respostas registradas pelo profissional."
        ),
    },
    {
        "accessPointKey": "screener.document.clinical_referral",
        "name": "Geração de carta de encaminhamento clínico",
        "sourceApp": "survey-frontend",
        "flowKey": "report.clinical_referral",
        "promptKey": "full_intake",
        "personaSkillKey": "clinical_referral_letter",
        "outputProfile": "clinical_referral_letter",
        "description": (
            "Gera uma carta de encaminhamento clínico para especialista."
        ),
    },
    {
        "accessPointKey": "screener.document.school_referral",
        "name": "Geração de carta de encaminhamento escolar",
        "sourceApp": "survey-frontend",
        "flowKey": "report.school_referral",
        "promptKey": "full_intake",
        "personaSkillKey": "school_report",
        "outputProfile": "school_report",
        "description": (
            "Gera uma carta de encaminhamento escolar para equipe pedagógica."
        ),
    },
    {
        "accessPointKey": "screener.document.parent_orientation",
        "name": "Geração de carta de orientação aos pais",
        "sourceApp": "survey-frontend",
        "flowKey": "report.parent_orientation",
        "promptKey": "full_intake",
        "personaSkillKey": "parental_guidance",
        "outputProfile": "parental_guidance",
        "description": (
            "Gera uma carta de orientação aos pais com recomendações práticas."
        ),
    },
    {
        "accessPointKey": "clinical_narrative.narrative.generate_report",
        "name": "Geração de prontuário da narrativa clínica",
        "sourceApp": "clinical-narrative",
        "flowKey": "narrative.generate_report",
        "promptKey": "default",
        "personaSkillKey": "clinical_diagnostic_report",
        "outputProfile": "clinical_diagnostic_report",
        "description": (
            "Gera o prontuário final a partir do rascunho clínico "
            "preparado pelo profissional."
        ),
    },
]


def build_access_point_documents(
    source_tag: str,
    *,
    timestamp: datetime | None = None,
) -> list[dict]:
    """Return normalized default access-point seed documents."""
    resolved_timestamp = timestamp or datetime.now(timezone.utc)
    documents: list[dict] = []
    for item in DEFAULT_AGENT_ACCESS_POINT_SEEDS:
        documents.append(
            {
                **item,
                "createdAt": resolved_timestamp,
                "modifiedAt": resolved_timestamp,
                "seedSource": ACCESS_POINT_SEED_SOURCE,
                "seedAppliedBy": source_tag,
            }
        )
    return documents


def should_refresh_seeded_access_point(
    existing: dict | None,
    access_point_key: str,
) -> bool:
    """Refresh only documents previously managed by this seed."""
    if existing is None:
        return True
    if existing.get("seedSource") == ACCESS_POINT_SEED_SOURCE:
        return True
    template = next(
        (
            item
            for item in DEFAULT_AGENT_ACCESS_POINT_SEEDS
            if item["accessPointKey"] == access_point_key
        ),
        None,
    )
    if template is None:
        return False
    comparable_fields = (
        "accessPointKey",
        "name",
        "sourceApp",
        "flowKey",
        "promptKey",
        "personaSkillKey",
        "outputProfile",
        "description",
    )
    return all(existing.get(field) == template.get(field) for field in comparable_fields)
