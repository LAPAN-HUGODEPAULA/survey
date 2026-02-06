import base64

import pytest

from clinical_writer_agent.main import transcribe_audio
from clinical_writer_agent.transcription_models import TranscriptionRequest

pytestmark = pytest.mark.anyio("asyncio")


async def test_transcription_endpoint_returns_response():
    payload = TranscriptionRequest(
        audioBase64=base64.b64encode(b"fake-audio").decode("utf-8"),
        audioFormat="audio/webm",
        previewText="Preview text",
        metadata={"requestId": "api-test"},
    )
    result = await transcribe_audio(payload)
    assert result.text == "Preview text"
    assert result.provider == "stub"
