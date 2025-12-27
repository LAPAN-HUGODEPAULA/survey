# Clinical Writer AI – Software Engineering Guide

This document captures the end-to-end engineering view of the Clinical Writer AI system: architecture, runtime behavior, configuration, testing, and operational guidance. It complements the focused documents in `docs/` (API, architecture, deployment, security) by summarizing how the pieces fit together.

## System Overview
- Goal: transform clinical conversations or structured questionnaire JSON into a formal medical record using Google Gemini, with strict safety and input validation.
- Stack: Python 3.13, FastAPI (`clinical_writer_agent/main.py`), LangGraph workflow (`clinical_writer_agent/agent_graph.py`), LangChain Google GenAI client, pytest.
- Entry points: REST API (`/process`, `/metrics`) plus direct LangGraph invocation for internal/testing use.
- Patterns: Strategy Pattern for input classification, Observer Pattern for logging/metrics, dependency injection for LLM clients (including the validation judge) to keep tests fast and deterministic.

## Codebase Layout (key modules)
- `clinical_writer_agent/main.py`: FastAPI app, input schema validation, API token guard, dependency wiring for the compiled graph and observer, `/process` and `/metrics` routes.
- `clinical_writer_agent/agent_graph.py`: Builds the LangGraph state machine with nodes for validation, classification, conversation processing, JSON processing, and fallback handling. Attaches observers and exposes shared compiled graph.
- `clinical_writer_agent/agents/`: Agent implementations:
  - `input_validator_agent.py`: sanitizes input, runs basic checks, and consults an LLM judge for appropriateness.
  - `classification_agent.py`: executes the Strategy Pattern for semantic routing (inappropriate, JSON, conversation, fallback).
  - `conversation_processor_agent.py`: renders conversation prompt and calls Gemini.
  - `json_processor_agent.py`: renders questionnaire prompt and calls Gemini.
  - `other_inputs_handler_agent.py`: deterministic fallback for flagged/unclassified inputs.
- `clinical_writer_agent/classification_strategies.py`: Strategy Pattern implementations (inappropriate-content, JSON, conversation, fallback) and the classification context orchestrator.
- `clinical_writer_agent/monitoring/`: Observer Pattern implementations for logging (`LoggingMonitor`) and metrics (`MetricsMonitor`), plus a composite to fan out events.
- `clinical_writer_agent/prompts.py`: Prompt templates for conversation and JSON flows (Portuguese, structured outputs).
- `clinical_writer_agent/repository/`: Domain assets (bad words, slang lists) loaded by the validator.
- `clinical_writer_agent/tests/`: Pytest suite covering config, API contract, classification, prompts, monitoring, and integration paths.

## Request Lifecycle
1. **Inbound API** (`/process`): FastAPI validates `Input.content` (non-empty) and optional bearer token (`API_TOKEN` env). The handler injects a shared observer and the compiled LangGraph.
2. **Validation & Judge** (`InputValidatorAgent.validate`):
   - Removes scripts/HTML, normalizes whitespace, and rejects empty payloads after sanitization.
   - Calls an LLM judge for appropriateness scoring (0–1). Scores below `JUDGE_APPROPRIATENESS_THRESHOLD` short-circuit to the fallback handler with `flagged_inappropriate`.
   - Observer receives validation timing; judge failures fail closed (flagged) and emit `on_error`.
3. **Classification** (`ClassificationAgent.classify`):
   - Applies strategies in priority order: inappropriate-content, JSON (including JSON-in-a-string), conversation cues, fallback.
   - Attaches error messages for flagged/unclassified paths and emits classification events.
4. **Routing** (`agent_graph.py` conditional edges):
   - `conversation` → `ConversationProcessorAgent.process`.
   - `json` → `JsonProcessorAgent.process`.
   - `flagged_inappropriate` or `other` → `OtherInputHandlerAgent.handle`.
5. **Processing Agents**:
   - Conversation/JSON agents lazily create or receive injected LLM instances (`AgentConfig.create_llm_instance`), render prompts, invoke Gemini, and store `medical_record`.
   - Exceptions are caught; state switches to `classification=other` with a formatted error message, and observers are notified via `on_error`.
5. **Response**: Observer is stripped from the returned state; client receives `classification`, `medical_record`, and optional `error_message`.
6. **Metrics**: `/metrics` returns aggregated counters/latencies from the shared `MetricsMonitor`.

## Configuration & Environment
- Core settings live in `AgentConfig`:
  - `GEMINI_API_KEY` (required), `LLM_MODEL_NAME` (`gemini-2.5-flash`), `LLM_TEMPERATURE` (0.0).
  - `JUDGE_APPROPRIATENESS_THRESHOLD` (0.5 by default) controls the LLM judge gate.
  - Paths to bad word and slang files; emoji ranges and ad keyword lists for filtering.
  - Classification labels and reusable error messages.
- Env vars: `GEMINI_API_KEY` (required for LLM calls), `API_TOKEN` (optional bearer auth for `/process`), standard FastAPI/uvicorn host/port if overridden at run time.
- Local setup: create `.venv` inside `clinical_writer_agent`, `pip install -r requirements.txt`. Docker/Docker Compose flows are available via the root `Dockerfile` and `docker-compose.yml`.

## Observability
- **Logging**: `LoggingMonitor` emits structured messages for validation, processing start/stop, and errors. It attaches a console handler by default and is composed into the shared observer.
- **Metrics**: `MetricsMonitor` tracks classification distribution, processing counts/timings by agent, validation results, error counts, runtime, and requests/sec. Accessible through `/metrics`; can be exported to JSON via `export_metrics_json` or reset in tests.
- **Composition**: `CompositeMonitor` fans out events so both logging and metrics capture every step without coupling agents to specific sinks.

## Error Handling & Safety
- Validation rejects empty payloads at the Pydantic schema layer.
- Inappropriate content or unclassified inputs yield safe, deterministic messages (`ERROR_MSG_INAPPROPRIATE_CONTENT`, `ERROR_MSG_UNCLASSIFIED_INPUT`) via the fallback handler.
- LLM failures are caught per-agent; the request still returns a structured response with `classification=other` and an error message, enabling clients to surface graceful degradation.
- Observer hooks fire on errors, enabling alerting via downstream logging/metrics backends.

## Testing Strategy
- Command: `pytest tests -q` (run from `clinical_writer_agent/`).
- Coverage themes:
  - Config validation and LLM factory behavior (`test_agent_config.py`).
  - Classification correctness and prioritization (`test_classification_strategies.py`).
  - API contract, auth guard, and end-to-end graph execution with stub LLMs (`test_main.py`, `test_api_contract.py`, `test_integration.py`).
  - Prompt generation sanity (`test_prompts.py`).
  - Observer/metrics behaviors (`test_monitoring.py`).
- Tests inject stub LLMs to avoid network calls and assert deterministic outputs; metrics are reset within tests to ensure isolation.

## Extensibility Guidelines
- **New classification rules**: implement a `ClassificationStrategy`, assign a priority, and register via `ClassificationAgent` constructor or `AgentConfig.CLASSIFICATION_STRATEGY_FACTORIES`.
- **New processing paths**: add a new agent with a `process` method, register it as a node in `agent_graph.create_graph`, and wire a conditional edge from validation to the new node.
- **Additional observers**: subclass `ProcessingMonitor`, implement event hooks, and add it to the composite via `create_default_observer` or a custom observer passed into `create_graph`.
- **Prompt updates**: adjust templates in `prompts.py`; keep output structure stable for downstream consumers and tests.

## Deployment & Operations
- Local dev server: `uvicorn main:app --reload` from `clinical_writer_agent/` after activating the venv.
- Docker: build with `docker build -t clinical-writer -f clinical_writer_agent/Dockerfile clinical_writer_agent` and run with `--env-file clinical_writer_agent/.env -p 9566:8000`.
- Docker Compose: `docker compose up --build` from repo root (loads `.env` automatically).
- Runtime dependencies: outbound network for Gemini API, optional API token for incoming requests, writable location if exporting metrics.

## Security & Privacy Notes
- Never commit `.env` or API keys; `GEMINI_API_KEY` is loaded via `python-dotenv`.
- Optional bearer token protects `/process` in shared environments; absent token allows open access for local/dev.
- Input sanitization removes or flags advertising, markup, emojis, and inappropriate content to reduce prompt injection and safety risks.
- Avoid logging PHI beyond classification/length metadata; observers focus on event metadata rather than full payloads.

## Operational Runbook (condensed)
- **Health**: GET `/` for a basic liveness response; GET `/metrics` for runtime stats.
- **Common issues**:
  - Missing `GEMINI_API_KEY`: raises at LLM creation time (`AgentConfig.validate_config`).
  - Payload rejected as empty or flagged: client receives descriptive `error_message`; classification indicates `flagged_inappropriate` or `other`.
  - LLM outages: request returns error message while preserving response shape; monitor error counts in metrics.
- **Maintenance**: refresh bad word/slang lists under `clinical_writer_agent/repository/`, bump `requirements.txt` as needed, and re-run tests.
