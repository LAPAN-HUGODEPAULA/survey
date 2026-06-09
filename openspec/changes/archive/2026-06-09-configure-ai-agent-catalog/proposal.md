## Why

AI provider usage is currently modeled around fixed GLM/Gemini provider names and a global AI singleton. New local and self-hosted agents are becoming part of normal operations, so administrators need to add endpoints, choose defaults, and manage fallbacks from Survey Builder without changing executor code for every server or provider change.

## What Changes

- Introduce a MongoDB-backed AI agent catalog for executable model endpoints, including OpenAI-compatible gateways, GLM, and Gemini.
- Replace hardcoded provider dropdowns with Survey Builder controls for managing AI agents and assigning ordered agent routes to access points.
- Evolve access-point `aiConfig` from primary/fallback provider fields to an ordered `agentRefs` route while retaining backward-compatible resolution for existing records.
- Update the Clinical Writer executor to resolve agent catalog entries, read API keys from environment variable references, and attempt configured agents in order.
- Deprecate the global AI singleton path for runtime defaults; access points remain the operational source of truth for AI routing.

## Capabilities

### New Capabilities

- `ai-agent-catalog`: Defines configurable AI agent endpoint records, secret reference handling, and builder-managed catalog operations.

### Modified Capabilities

- `agent-access-point-management`: Access points will store ordered AI agent routes instead of a two-provider primary/fallback model.
- `clinical-writer-provider-routing`: Clinical Writer will route through configured agent catalog entries and support OpenAI-compatible gateways without provider-specific code changes.
- `frontend-survey-builder`: Survey Builder will expose AI agent catalog management and ordered access-point routing controls.
- `ai-model-configuration`: Model selection and sampling parameters will be driven by access-point agent routes rather than hardcoded provider choices.
- `ai-parameter-governance`: Global AI defaults will no longer be the runtime inheritance layer for access points.

## Impact

- Backend: new `AIAgents` repository, domain models, builder-protected API routes, OpenAPI updates, and migration/seed script.
- Clinical Writer API: model routing refactor to use ordered catalog-resolved agents and an OpenAI-compatible adapter.
- Survey Builder: new AI Agents administration screen and updated access-point AI configuration UI.
- Contracts: `AIConfig` schema and generated Dart SDKs must support `agentRefs` and remove fixed `glm`/`gemini` enums.
- Operations: API key values remain environment-managed; MongoDB stores only environment variable names such as `AI_API_KEY`.
