## 1. Fix GLM Client Runtime Path

- [x] 1.1 Refactor `GLMClient` to use synchronous `openai.OpenAI` invocation in `invoke()`.
- [x] 1.2 Remove `asyncio.run(...)`/coroutine wrappers from GLM provider call path and preserve typed error propagation.
- [x] 1.3 Add or update tests covering: GLM success path, GLM exception path, and router fallback to Gemini.

## 2. Optimize Layered Graph Flow

- [x] 2.1 Update graph edges so the default path is `ContextLoader -> ClinicalAnalyzer -> PersonaWriter -> END`.
- [x] 2.2 Ensure `ReflectorNode` remains implemented but bypassed in default execution (no reflection rewrite loop).
- [x] 2.3 Preserve compatibility of `create_graph(...)` and `clinical_writer_graph` usage in FastAPI dependencies.

## 3. Maintain Routing and Telemetry Guarantees

- [x] 3.1 Verify active LLM stages (Analyzer and PersonaWriter) continue using the shared provider-aware router.
- [x] 3.2 Verify effective model/provider metadata still reflects primary vs fallback execution correctly.
- [x] 3.3 Add or update logging/metrics to observe GLM failures, fallback frequency, and quota-pressure signals.

## 4. Validate and Roll Out Safely

- [x] 4.1 Run `uv run python -m compileall services/clinical-writer-api/clinical_writer_agent`.
- [x] 4.2 Run `pylint --disable=C services/clinical-writer-api/clinical_writer_agent/**/*.py`.
- [x] 4.3 Execute relevant automated tests and record validation evidence for PR review.
