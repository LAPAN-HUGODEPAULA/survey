# Change: stabilize-clinical-writer-agent-core

## Why

The Clinical Writer API implements a critical clinical AI workflow. Over time, configuration, model routing, prompt loading, and database calls have become coupled with the agent node definitions. Additionally, the actual graph construction lacks the required 4th stage (`ReflectorNode`) specified in the platform's architectural guidelines.

To ensure clinical safety, lower latency, and reduced LLM inference costs, we must stabilize the core graph. This requires:
1. Decommissioning the deprecated Google Drive prompt provider.
2. Standardizing MongoDB as the secure, audited source of truth.
3. Implementing explicit Pydantic input/output boundaries for all nodes.
4. Adding the `ReflectorNode` validation loop.
5. Decoupling database queries from routing/registry helpers.
6. Proactively cleaning up temporary audio files at startup to guarantee patient data privacy.

## What Changes

- **Graph Structure & Reflection:** Include `ReflectorNode` as the 4th stage in the LangGraph workflow. The graph will loop from `PersonaWriter` back to it up to 2 times on validation failures, appending a warning to the final response if constraints are still not fully satisfied on the final try.
- **Google Drive Removal:** Delete all Google Drive prompt loaders and metadata lookups. Remove `google-api-python-client` and `google-auth` dependencies from package specifications.
- **Repository Abstraction:** Move direct MongoDB calls out of `layered_node_utils.py` and `prompt_registry.py`. Create clean `PromptRepository` and `AgentRouteRepository` protocols with Mongo-based implementations.
- **Typed Stage Boundaries:** Implement formal Pydantic model contracts for all input/output state updates at each stage.
- **Monitoring Normalization:** Provide default empty hook implementations in the abstract `ProcessingMonitor` class to reduce boilerplate in monitor subclasses.
- **Audio Retention:** Implement a startup filesystem hook to clean up stranded audio files in the temporary directory to comply with safety/privacy guidelines.

## Scope

- `services/clinical-writer-api/clinical_writer_agent/**`
- `packages/python/lapan-core/lapan_core/security_boundaries.py` (reviewing usage only)
- Dependency config (`services/clinical-writer-api/clinical_writer_agent/pyproject.toml`)

## Impact

- **Affected capability:** `clinical-writer-agent`
- **Refactor leverage:** High
- **Confidence:** High
- **Expected implementation style:** Non-breaking codebase cleanup. No external API contracts or OpenAPI schemas will change, but the internal reliability and test coverage will improve significantly.

## Non-Goals

- Do not alter the external JSON structure of `ReportDocument` or the public `/process` endpoint schema.
- Do not perform styling/formatting changes on prompt instruction strings.
- Do not introduce external state management or memory databases (like Redis) for caching.
