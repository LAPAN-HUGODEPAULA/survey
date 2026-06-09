## Context

The current runtime can pass `aiConfig` from access points to the Clinical Writer executor, but the effective provider model is still built around fixed `glm` and `gemini` identifiers. Survey Builder also exposes hardcoded GLM/Gemini controls and a global AI settings section, while operations now need to onboard local/self-hosted OpenAI-compatible agents such as `qwen2.5-coder:7b`.

The desired control plane is the access-point catalog: each runtime entry point should define which agents are attempted, in what order, and with which request parameters. Provider endpoint details should be configurable data, not source-code branches or generated environment files that must be edited whenever an agent changes.

## Goals / Non-Goals

**Goals:**

- Add a builder-managed AI agent catalog stored in MongoDB.
- Allow each `AgentAccessPoint` to define ordered agent routing through `aiConfig.agentRefs`.
- Keep API key values out of MongoDB and responses by storing only environment variable names.
- Support OpenAI-compatible gateways as a first-class executor adapter.
- Preserve current access-point records and migrate them in place.
- Keep backward-compatible execution for existing `primaryProvider` / `fallbackProvider` records during rollout.

**Non-Goals:**

- Do not create or restore `global_ai_config` as a default inheritance layer.
- Do not build in-app secret editing or encrypted secret storage in this change.
- Do not add RAG management UI beyond preserving compatibility for agent metadata that declares RAG support.
- Do not refactor prompt/persona selection outside the AI routing changes.

## Decisions

1. Store executable endpoints in a new `AIAgents` collection.

   Each agent record uses a stable `agentKey`, display metadata, `providerType`, `baseUrl`, `apiKeyEnvVar`, default model, capability flags, and timestamps. This separates endpoint/credential configuration from access-point workflow bindings while keeping the source of truth in MongoDB.

   Alternative considered: continue using provider strings directly in access points. That would require repeated endpoint data and keep Survey Builder tied to provider-specific enums.

2. Store access-point routing as ordered `agentRefs`.

   `aiConfig.agentRefs` is an ordered list where the first enabled entry is primary and later enabled entries are fallbacks. Each entry can override `model`, `temperature`, `maxTokens`, and enabled state. This handles more than one fallback without introducing a separate global routing profile.

   Alternative considered: primary plus one fallback. That is simpler but would need another schema change as soon as multiple local/remote fallbacks are required.

3. Resolve secrets through environment variable names.

   MongoDB stores `apiKeyEnvVar` such as `AI_API_KEY`; the executor reads the secret from its own environment at request time. Builder APIs must never return secret values.

   Alternative considered: encrypted MongoDB secret storage. That can be added later, but it needs masking, rotation, audit, encryption-key policy, and a secret-write UI.

4. Use provider adapters selected by `providerType`.

   The Clinical Writer executor will route through adapters for `openai_compatible`, `glm`, and `gemini`. The local Qwen gateway uses `openai_compatible`, so future OpenAI-style servers can be added by database records instead of source changes.

   Alternative considered: reuse `glm` for all OpenAI-compatible endpoints. That would work technically but keeps misleading provider names in telemetry and UI.

5. Deprecate global AI settings in favor of access-point routing.

   Access points remain the runtime authority. Existing fallback logic can temporarily interpret old `aiConfig` fields, but new Builder writes must use `agentRefs`.

   Alternative considered: a named global profile. It reduces editing across many access points, but reintroduces indirection that previously caused confusion and does not match the current operational model.

## Risks / Trade-offs

- Missing environment secret for an enabled agent -> executor fails before that agent call and attempts the next configured fallback; logs identify the missing env var name but not secret values.
- Misconfigured endpoint URL -> executor marks that agent attempt failed and continues to the next enabled route; admin can fix the URL through Survey Builder.
- Existing clients generated from old OpenAPI enums reject new provider values -> update OpenAPI and regenerated Dart SDKs in the same change.
- UI complexity increases for ordered routes -> use compact repeated route rows with reorder controls and clear validation instead of a global settings form.
- Mixed old/new `aiConfig` records during rollout -> resolver supports both shapes and migration updates the existing 9 access points in place.

## Migration Plan

1. Add `AIAgents` collection indexes and seed agents for current GLM, Gemini, and local Qwen.
2. Update existing 9 `AgentAccessPoints` in place to include `aiConfig.agentRefs`; preserve prompt/persona/output bindings.
3. Keep old `primaryProvider` fields readable until all access points and generated clients use `agentRefs`.
4. Remove Survey Builder writes to `settings/ai` and replace the UI with AI agent catalog and per-access-point route editing.
5. Deploy backend and Clinical Writer together so the executor understands `agentRefs` before Builder writes them.
6. Roll back by leaving old `primaryProvider` data readable and restoring previous access-point documents from Mongo export if needed.

## Open Questions

- None for initial implementation. Future work can add encrypted secret editing and named route profiles if operational needs justify them.
