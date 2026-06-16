"""PDF compilation helpers for clinical report delivery."""

from __future__ import annotations

from html import escape
from io import BytesIO
from typing import Protocol


class PDFCompiler(Protocol):
    """Protocol for PDF compilers used by report delivery."""

    def compile(self, report_text: str) -> bytes: ...


class ReportlabPDFCompiler:
    """Compile clinical report text into a PDF using ReportLab."""

    def compile(self, report_text: str) -> bytes:
        """Render the provided report text as a readable PDF document."""
        try:
            from reportlab.lib.pagesizes import A4
            from reportlab.lib.styles import getSampleStyleSheet
            from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer
        except Exception as exc:  # pragma: no cover - dependency guard
            raise RuntimeError("PDF generation dependency is unavailable.") from exc

        buffer = BytesIO()
        styles = getSampleStyleSheet()
        body_style = styles["BodyText"]
        story = []

        for raw_line in report_text.splitlines() or [" "]:
            line = raw_line.strip()
            if not line:
                story.append(Spacer(1, 8))
                continue
            story.append(Paragraph(escape(line), body_style))
            story.append(Spacer(1, 6))

        doc = SimpleDocTemplate(
            buffer,
            pagesize=A4,
            leftMargin=36,
            rightMargin=36,
            topMargin=42,
            bottomMargin=42,
            pageCompression=0,
        )
        doc.build(story)
        return buffer.getvalue()
