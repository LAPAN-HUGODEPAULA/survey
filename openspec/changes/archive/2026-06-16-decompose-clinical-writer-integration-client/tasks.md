# Tasks

- [x] 1. **Characterize Behavior**: Write robust regression tests in `test_clinical_writer_client.py` covering fallback retry, read timeout (handling health probes), quota warnings, non-JSON, and partial report results.
- [x] 2. **Extract Endpoint Resolver**: Create `app/integrations/clinical_writer/resolver.py` containing `ClinicalWriterEndpointResolver`. Move candidate resolution, fallback settings, allowed host lists, and URL validation.
- [x] 3. **Extract Health Client**: Create `app/integrations/clinical_writer/health.py` containing `ClinicalWriterHealthClient`. Move health probing (`/healthz`) and status polling (`/status/{request_id}`).
- [x] 4. **Extract Response Normalizer**: Create `app/integrations/clinical_writer/normalizer.py` containing `AgentResponseNormalizer`. Move field mapping, SHA256 patient pseudonymization, resource exhaustion checks, and retry delays.
- [x] 5. **Extract shared Report Text Formatter**:
    *   Create `packages/python/lapan-core/lapan_core/report_formatter.py` and implement `ReportTextFormatter`.
    *   Expose it in `packages/python/lapan-core/lapan_core/__init__.py`.
    *   Refactor `services/survey-worker/app/jobs/clinical_writer.py` to import and use it, removing the duplicated formatting code.
- [x] 6. **Build Run Client**: Create `app/integrations/clinical_writer/client.py` containing `ClinicalWriterRunClient`. Orchestrate calls utilizing the resolver, health, and normalizer components. support dependency injection for the `httpx.AsyncClient` and repository.
- [x] 7. **Update Facade & Boundaries**:
    *   Expose the client facade in `app/integrations/clinical_writer/__init__.py`.
    *   Have the client return `AgentResponse` Pydantic models.
    *   Refactor calling routes (`survey_responses.py`, `patient_responses.py`, and `clinical_writer.py`) to process the model directly instead of raw dict unpacking.
- [x] 8. **Update Documentation**: Update [technical-specification.md](file:///home/hugo/Documents/LAPAN/dev/survey/docs/technical-specification.md) and [software-design.md](file:///home/hugo/Documents/LAPAN/dev/survey/docs/software-design.md) to document the decomposed `app.integrations.clinical_writer` package structure.
- [x] 9. **Run & Verify**: Update unit tests to use dependency injection, confirm total coverage meets the 80% threshold, and run complexity scans to verify `send_to_langgraph_agent` complexity is minimal.

## Validation

- [x] V1. Existing clinical writer client tests pass.
- [x] V2. New unit tests for each extracted component.
- [x] V3. `survey-worker` successfully processes and enriches jobs using the shared `ReportTextFormatter`.
- [x] V4. Route authorization and unit tests pass on all modified routes.
- [x] V5. Skylos complexity for `send_to_langgraph_agent` is eliminated.
