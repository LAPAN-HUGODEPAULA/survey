from app.integrations.clinical_writer.resolver import (
    ClinicalWriterEndpointResolver,
    DEFAULT_LANGGRAPH_URL,
    DEFAULT_LOCAL_LANGGRAPH_URL,
    DEFAULT_LOOPBACK_LANGGRAPH_URL,
)


def test_process_endpoints_include_local_fallbacks_when_default_service_url_is_used(monkeypatch) -> None:
    monkeypatch.delenv("CLINICAL_WRITER_URL", raising=False)
    monkeypatch.delenv("LANGGRAPH_URL", raising=False)

    resolver = ClinicalWriterEndpointResolver()

    assert resolver.process_endpoints() == [
        DEFAULT_LANGGRAPH_URL,
        DEFAULT_LOCAL_LANGGRAPH_URL,
        DEFAULT_LOOPBACK_LANGGRAPH_URL,
    ]


def test_status_endpoint_reuses_process_base_path() -> None:
    resolver = ClinicalWriterEndpointResolver()

    assert resolver.status_endpoints("req-123")[0].endswith("/status/req-123")


def test_analysis_and_transcription_endpoints_derive_from_process_url(monkeypatch) -> None:
    monkeypatch.delenv("LANGGRAPH_ANALYSIS_URL", raising=False)
    monkeypatch.delenv("LANGGRAPH_TRANSCRIPTION_URL", raising=False)

    resolver = ClinicalWriterEndpointResolver()

    assert resolver.analysis_endpoint().endswith("/analysis")
    assert resolver.transcription_endpoint().endswith("/transcriptions")
    assert (
        resolver.to_base_endpoint("http://localhost:9566/process")
        == "http://localhost:9566"
    )
