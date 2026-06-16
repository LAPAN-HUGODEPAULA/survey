import httpx

from app.integrations.clinical_writer.normalizer import AgentResponseNormalizer


def test_normalize_agent_response_harmonizes_payload_shape() -> None:
    normalizer = AgentResponseNormalizer()

    response = normalizer.normalize_agent_response(
        {
            "ok": True,
            "report": {
                "sections": [
                    {
                        "title": "Resumo",
                        "blocks": [
                            {
                                "type": "paragraph",
                                "spans": [{"text": "Conteudo do laudo."}],
                            }
                        ],
                    }
                ]
            },
            "warnings": None,
            "error_message": None,
            "ai_progress": {
                "user_message": "Aguardando",
                "stage_label": "Na fila",
                "updated_at": "2026-06-16T00:00:00Z",
            },
        }
    )

    assert response.medical_record == "Resumo\nConteudo do laudo."
    assert response.ai_progress["userMessage"] == "Aguardando"
    assert response.ai_progress["stageLabel"] == "Na fila"
    assert response.ai_progress["updatedAt"] == "2026-06-16T00:00:00Z"
    assert response.warnings == []


def test_extract_retry_after_seconds_supports_quota_detail_patterns() -> None:
    normalizer = AgentResponseNormalizer()

    assert normalizer.extract_retry_after_seconds("Please retry in 33.072s.") == 33
    assert normalizer.extract_retry_after_seconds("retryDelay: 17s") == 17


def test_status_error_response_maps_resource_exhausted_to_retryable_warning() -> None:
    response = httpx.Response(
        500,
        request=httpx.Request("POST", "http://localhost/process"),
        json={"detail": "RESOURCE_EXHAUSTED. Please retry in 12s."},
    )
    error = httpx.HTTPStatusError(
        "upstream error",
        request=response.request,
        response=response,
    )

    normalized = AgentResponseNormalizer().status_error_response(error)

    assert normalized.error_message == "AI quota exceeded for clinical analysis"
    assert normalized.ai_progress["retryable"] is True
    assert "12s" in normalized.ai_progress["userMessage"]
