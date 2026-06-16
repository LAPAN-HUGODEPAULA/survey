"""Command-based clinical report delivery service."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import tempfile
from typing import Awaitable, Callable
import uuid

from lapan_core import get_safe_write_path, write_bytes_to_safe_path

from .report_pdf import PDFCompiler

REPORT_TEMP_DIR = Path(tempfile.gettempdir()) / "survey-backend-report-pdfs"

ReportEmailSender = Callable[..., Awaitable[None]]


@dataclass(frozen=True)
class SendReportCommand:
    """DTO for report delivery execution."""

    response_id: str
    patient_email: str
    report_text: str
    attachment_label: str = "report"


@dataclass(frozen=True)
class SendReportResult:
    """Result of a report delivery execution."""

    status: str
    response_id: str
    recipients: list[str]


class ReportDeliveryService:
    """Compile, persist temporarily, and email clinical reports."""

    def __init__(
        self,
        *,
        pdf_compiler: PDFCompiler,
        email_sender: ReportEmailSender,
        copy_recipient: str | None = None,
        temp_dir: Path = REPORT_TEMP_DIR,
    ) -> None:
        self._pdf_compiler = pdf_compiler
        self._email_sender = email_sender
        self._copy_recipient = copy_recipient
        self._temp_dir = temp_dir

    async def execute(self, command: SendReportCommand) -> SendReportResult:
        """Compile the report PDF and deliver it via email."""
        report_text = command.report_text.strip()
        if not report_text:
            raise ValueError("No report data available to generate PDF.")

        pdf_bytes = self._pdf_compiler.compile(report_text)
        recipients = self._resolve_recipients(command.patient_email)
        temp_file_path = self._write_temp_pdf(
            pdf_bytes,
            response_id=command.response_id,
            attachment_label=command.attachment_label,
        )
        try:
            await self._email_sender(
                response_id=command.response_id,
                recipients=recipients,
                attachment_paths=[temp_file_path],
            )
        finally:
            self._cleanup_temp_pdf(temp_file_path)

        return SendReportResult(
            status="sent",
            response_id=command.response_id,
            recipients=recipients,
        )

    def _resolve_recipients(self, patient_email: str) -> list[str]:
        recipients = [patient_email]
        if (
            self._copy_recipient
            and self._copy_recipient.strip()
            and self._copy_recipient.lower() != patient_email.lower()
        ):
            recipients.append(self._copy_recipient)
        return recipients

    def _write_temp_pdf(
        self,
        pdf_bytes: bytes,
        *,
        response_id: str,
        attachment_label: str,
    ) -> str:
        safe_response_id = self._safe_filename_component(response_id)
        temp_path = write_bytes_to_safe_path(
            self._temp_dir,
            f"{uuid.uuid4().hex}_{safe_response_id}_{attachment_label}.pdf",
            pdf_bytes,
        )
        return str(temp_path)

    def _cleanup_temp_pdf(self, temp_file_path: str) -> None:
        temp_path = get_safe_write_path(self._temp_dir, Path(temp_file_path).name)
        temp_path.unlink(missing_ok=True)

    @staticmethod
    def _safe_filename_component(value: str) -> str:
        normalized = "".join(
            char if char.isalnum() or char in {"-", "_"} else "_"
            for char in value
        )
        return (normalized[:80] or "response").strip("._") or "response"
