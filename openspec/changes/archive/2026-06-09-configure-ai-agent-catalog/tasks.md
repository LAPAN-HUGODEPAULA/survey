## 1. Backend AI Agent Catalog

- [ ] 1.1 Add backend domain models for AI agents and `aiConfig.agentRefs`, including validation for agent keys, provider type, URL, env-var references, temperature, and enabled state.
- [ ] 1.2 Add a Mongo-backed `AIAgents` repository with indexes for `agentKey` and enabled/provider lookups.
- [ ] 1.3 Add builder-protected CRUD routes for `/ai_agents/` that redact secret values and expose only `apiKeyEnvVar`.
- [ ] 1.4 Update access-point validation so new writes validate `aiConfig.agentRefs` against enabled AI agent records.
- [ ] 1.5 Keep backward-compatible access-point resolution for legacy `primaryProvider` / `primaryModel` / `fallbackProvider` / `fallbackModel` records.

## 2. Contracts And SDKs

- [ ] 2.1 Update `packages/contracts/survey-backend.openapi.yaml` with `AIAgent`, `AIAgentUpsert`, `AIAgentRouteRef`, and updated `AIConfig` schemas.
- [ ] 2.2 Remove fixed `glm`/`gemini` provider enums from the access-point AI config contract.
- [ ] 2.3 Regenerate Dart clients with `tools/scripts/generate_clients.sh` and verify generated diffs are intentional.

## 3. Clinical Writer Executor

- [ ] 3.1 Add route resolution that converts `aiConfig.agentRefs` plus catalog records into ordered executable agent attempts.
- [ ] 3.2 Add an `openai_compatible` provider adapter that uses configured `baseUrl`, model, temperature, max tokens, response format, stream mode, and optional RAG payload fields.
- [ ] 3.3 Refactor `ModelRouter` to attempt enabled agents in order and continue to fallback agents on configuration or provider failures.
- [ ] 3.4 Resolve API keys from `apiKeyEnvVar` at runtime and log missing secret references without logging secret values.
- [ ] 3.5 Report `model_version` as `agentKey:model` for both primary and fallback successes.

## 4. Survey Builder UI

- [ ] 4.1 Add Survey Builder models and repository methods for AI agent catalog CRUD.
- [ ] 4.2 Add an AI Agents administration screen reachable from the builder navigation.
- [ ] 4.3 Replace the current Global AI settings UI with catalog management and remove Builder writes to `settings/ai`.
- [ ] 4.4 Update the access-point form to use ordered agent route rows with select, model override, temperature, max tokens, enabled, remove, and reorder controls.
- [ ] 4.5 Surface backend validation errors for missing, disabled, or invalid AI agent route entries without silently replacing selections.

## 5. Migration And Seeds

- [ ] 5.1 Add a migration/seed script that creates initial AI agent records for current GLM, Gemini, and local Qwen.
- [ ] 5.2 Seed local Qwen as `providerType=openai_compatible`, host `lapan-ai.tailf9eac9.ts.net`, model `qwen2.5-coder:7b`, and `apiKeyEnvVar=AI_API_KEY`.
- [ ] 5.3 Update the existing 9 `AgentAccessPoints` in place to include ordered `aiConfig.agentRefs` while preserving prompt/persona/output bindings.
- [ ] 5.4 Do not create or restore `global_ai_config`; remove code paths that seed it as a default inheritance layer.

## 6. Tests And Validation

- [ ] 6.1 Add backend tests for AI agent CRUD, secret redaction, access-point route validation, and legacy `aiConfig` compatibility.
- [ ] 6.2 Add Clinical Writer tests for OpenAI-compatible request formatting, ordered fallback behavior, missing env-var handling, and effective model metadata.
- [ ] 6.3 Add Survey Builder tests for AI agent repository mapping and access-point ordered route serialization.
- [ ] 6.4 Run `uv run python -m compileall services/survey-backend/app`.
- [ ] 6.5 Run relevant Clinical Writer tests through the service project environment.
- [ ] 6.6 Run `flutter analyze` from `apps/survey-builder`.
