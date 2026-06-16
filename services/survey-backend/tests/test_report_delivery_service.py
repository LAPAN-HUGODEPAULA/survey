from pathlib import Path

import pytest

from app.services.report_delivery import (
    ReportDeliveryService,
    SendReportCommand,
)


@pytest.mark.asyncio
async def test_report_delivery_service_sends_and_cleans_up_temp_pdf(tmp_path: Path) -> None:
    sent: dict[str, object] = {}

    class _Compiler:
        def compile(self, report_text: str) -> bytes:
            sent["report_text"] = report_text
            return b"%PDF-1.4 fake"

    async def _sender(*, response_id, recipients, attachment_paths) -> None:
        sent["response_id"] = response_id
        sent["recipients"] = recipients
        sent["attachment_paths"] = attachment_paths
        sent["file_exists_during_send"] = Path(attachment_paths[0]).exists()

    service = ReportDeliveryService(
        pdf_compiler=_Compiler(),
        email_sender=_sender,
        copy_recipient="lapan@example.com",
        temp_dir=tmp_path,
    )

    result = await service.execute(
        SendReportCommand(
            response_id="response-1",
            patient_email="patient@example.com",
            report_text="Resumo clínico",
        )
    )

    assert result.status == "sent"
    assert result.response_id == "response-1"
    assert result.recipients == ["patient@example.com", "lapan@example.com"]
    assert sent["report_text"] == "Resumo clínico"
    assert sent["response_id"] == "response-1"
    assert sent["file_exists_during_send"] is True
    attachment_path = Path(sent["attachment_paths"][0])
    assert attachment_path.name.endswith("response-1_report.pdf")
    assert not attachment_path.exists()


@pytest.mark.asyncio
async def test_report_delivery_service_cleans_up_temp_pdf_on_send_failure(tmp_path: Path) -> None:
    sent: dict[str, object] = {}

    class _Compiler:
        def compile(self, report_text: str) -> bytes:
            return b"%PDF-1.4 fake"

    async def _sender(*, response_id, recipients, attachment_paths) -> None:
        sent["attachment_path"] = attachment_paths[0]
        raise RuntimeError("smtp unavailable")

    service = ReportDeliveryService(
        pdf_compiler=_Compiler(),
        email_sender=_sender,
        temp_dir=tmp_path,
    )

    with pytest.raises(RuntimeError, match="smtp unavailable"):
        await service.execute(
            SendReportCommand(
                response_id="response-1",
                patient_email="patient@example.com",
                report_text="Resumo clínico",
            )
        )

    assert not Path(sent["attachment_path"]).exists()
