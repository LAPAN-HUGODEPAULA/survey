# Design: decompose-clinical-writer-integration-client

## Context

This change decomposes the monolithic, high-churn `client.py` integration client within the LAPAN FastAPI backend. The goal is to simplify unit testing, increase type safety, and eliminate code duplication with the survey-worker.

## Goals

- Decompose the 600-line `client.py` into cohesive, single-responsibility modules.
- Eliminate duplicated report-to-text Markdown conversion in the background worker.
- Replace fragile HTTP patching in unit tests with clean dependency injection.
- Upgrade integration boundaries from raw dictionaries to typed Pydantic models.

## Architecture & Module Layout

The monolithic `client.py` is decomposed into the following structures:

1.  **`resolver.py` (`ClinicalWriterEndpointResolver`)**
    *   Resolves process, status, analysis, and transcription candidate URLs.
    *   Handles local/loopback fallback logic and settings.
    *   Enforces outbound URL verification via `lapan_core.validate_outbound_url`.
2.  **`health.py` (`ClinicalWriterHealthClient`)**
    *   Handles connectivity diagnostics (`/healthz` or `/`) on failure.
    *   Queries runtime run progress from `/status/{request_id}` endpoints.
3.  **`normalizer.py` (`AgentResponseNormalizer`)**
    *   Harmonizes camelCase/snake_case representation in raw agent payloads.
    *   Pseudonymizes patient PII (emails/names) using stable SHA256 hashes.
    *   Maps Google Gemini/model resource exhaustion (`RESOURCE_EXHAUSTED`) into retryable warning messages in Brazilian Portuguese.
4.  **`lapan_core/report_formatter.py` (`ReportTextFormatter`)**
    *   Pure Python utility that flattens structured report JSON structures to Markdown text.
    *   Placed in the shared `lapan_core` package to serve both `survey-backend` and `survey-worker`.
5.  **`client.py` (`ClinicalWriterRunClient`)**
    *   Orchestrator that implements the main execution loop over endpoints.
    *   Supports constructor injection of the `httpx.AsyncClient` and `ClinicalWriterRunLogRepository` to facilitate unit testing.
6.  **`__init__.py`**
    *   Provides stable facade functions mapping calls to `ClinicalWriterRunClient`.

## Decisions

- **Typed Boundaries**: The facade and run client return `AgentResponse` Pydantic models. We will update the three routes invoking it (`survey_responses.py`, `patient_responses.py`, and `clinical_writer.py`) to process the returned model directly instead of raw dict unpacking.
- **Worker Refactor**: We will keep the client module within `survey-backend` and avoid pushing the whole client into `lapan-core`. However, `ReportTextFormatter` will be extracted to `lapan-core` so `survey-worker` can import and reuse it, resolving the duplicate report flattening logic.

## Validation Strategy

- **Regression Unit Tests**: Verify fallback logic, timeouts, quota error mapping, and malformed inputs with mock clients.
- **Worker Validation**: Ensure `survey-worker` continues to format reports correctly via shared `ReportTextFormatter`.
- **Complexity Scan**: Confirm that `send_to_langgraph_agent` is simplified into a lightweight orchestrator.
