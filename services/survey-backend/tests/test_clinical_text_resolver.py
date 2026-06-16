from app.services.clinical_text_resolver import ClinicalTextResolver


def test_clinical_text_resolver_prefers_override_text() -> None:
    resolver = ClinicalTextResolver()

    resolved = resolver.resolve(
        {"agentResponse": {"medicalRecord": "Texto persistido"}},
        "  Texto customizado  ",
    )

    assert resolved == "Texto customizado"


def test_clinical_text_resolver_reads_medical_record_report_and_error() -> None:
    resolver = ClinicalTextResolver()

    report_text = resolver.resolve(
        {
            "agentResponses": [
                {"report": {"title": "Laudo", "summary": "Resumo"}},
                {"errorMessage": "Falha controlada"},
            ]
        }
    )
    error_text = resolver.resolve(
        {
            "agentResponses": [
                {"errorMessage": "Falha controlada"},
            ]
        }
    )

    assert report_text == "Title: Laudo\nSummary: Resumo"
    assert error_text == "Falha controlada"
