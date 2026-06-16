from lapan_core import ReportTextFormatter


def test_report_formatter_flattens_section_blocks() -> None:
    report = {
        "title": "Laudo",
        "sections": [
            {
                "title": "Resumo",
                "blocks": [
                    {
                        "type": "paragraph",
                        "spans": [{"text": "Conteudo."}],
                    },
                    {
                        "type": "bullet_list",
                        "items": [
                            {"spans": [{"text": "Item 1"}]},
                            {"spans": [{"text": "Item 2"}]},
                        ],
                    },
                ],
            }
        ],
    }

    assert ReportTextFormatter.to_text(report) == "Laudo\nResumo\nConteudo.\n- Item 1\n- Item 2"


def test_report_formatter_flattens_generic_nested_payloads() -> None:
    report = {
        "summary": "Texto principal",
        "signals": [
            {"name": "Luminosidade", "severity": "Alta"},
            "Fotofobia",
        ],
    }

    assert ReportTextFormatter.to_text(report) == (
        "Summary: Texto principal\n"
        "Signals:\n"
        "  -\n"
        "    Name: Luminosidade\n"
        "    Severity: Alta\n"
        "  - Fotofobia"
    )
