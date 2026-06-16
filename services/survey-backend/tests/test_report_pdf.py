from app.services.report_pdf import ReportlabPDFCompiler


def test_reportlab_pdf_compiler_generates_pdf_bytes_with_text_content() -> None:
    compiler = ReportlabPDFCompiler()

    pdf = compiler.compile("Linha 1\n\nLinha 2 & teste")

    assert pdf.startswith(b"%PDF")
    assert b"Linha 1" in pdf
    assert b"Linha 2 & teste" in pdf
