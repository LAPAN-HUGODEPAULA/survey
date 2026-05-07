## Context

The system's AI processing is currently susceptible to infinite retry loops due to rate limits and lacks a robust configuration hierarchy. Model versions are hardcoded in environment files and Python code, making it difficult for administrators to control costs and model quality without developer intervention.

## Goals / Non-Goals

**Goals:**
- Stop infinite retry loops in background jobs.
- Centralize AI model defaults in the database.
- Ensure a consistent configuration hierarchy: Request Override > Access Point > Global Mongo Settings > Environment/System Defaults.
- Make all model versions configurable via UI.
- Remove legacy flat AI configuration fields from runtime patterns and enforce `aiConfig` as the single source of truth.

**Non-Goals:**
- Implementing a full automated CI/CD for model testing.
- Adding real-time model monitoring metrics (separate initiative).

## Decisions

### 1. Job Retry and Failure States
We will implement an environment-driven retry limit in `survey-worker`.
- **Reasoning**: To prevent cost spikes and logs flooding when external APIs (GLM/Google) are down or rate-limited.
- **Configuration**: `WORKER_MAX_RETRIES` controls the limit (default `1` while debugging; expected `3` in steady-state).
- **State Transition**: `pending` -> `processing` -> (`succeeded` OR `failed`). If `retry_count >= WORKER_MAX_RETRIES`, transition to `permanently_failed`.
- **Diagnostics Logging**: Add runtime flags to log request payload, raw clinical writer response, and normalized agent response without recompilation.

### 2. Global AI Configuration Collection
A new singleton AI settings document will store global defaults using the same `aiConfig` shape used by access points.
- **Fields**: `aiConfig.primaryProvider`, `aiConfig.primaryModel`, `aiConfig.fallbackProvider`, `aiConfig.fallbackModel`, `aiConfig.temperature`, `aiConfig.reasoningEffort`, `aiConfig.enableCaching`.
- **Reasoning**: This provides a "safety net" for the entire platform, allowing a single point of update for all non-overridden access points.

### 3. Decoupling Model Logic from Code
The `clinical-writer-api` will be refactored to remove all hardcoded strings like `glm-4.7`.
- **Implementation**: The `ModelRouter` will be initialized from the resolved request payload. Environment values remain emergency last-resort fallback, but never hardcoded literals in class definitions.
- **Authority Boundary**: `clinical-writer-api` is an executor only; it MUST NOT implement independent provider/model policy beyond required fallback behavior.

### 4. Legacy Pattern Removal
Legacy flat AI fields (`aiProvider`, `glmModel`, `geminiModel`) are retired.
- **Implementation**: Remove these fields from backend models, runtime selection, and builder repository payload construction.
- **Reasoning**: Coexisting schemas create contradictory state and ambiguous precedence.

### 5. UI: Global AI Settings Page
A new page in `survey-builder` will provide the interface for the `system_settings` document.
- **Inheritance UX**: Access Point forms MUST explicitly present "Use Global AI Settings" vs "Override with Access Point aiConfig" to eliminate ambiguity.

### 6. Single-Proposal Cutover Strategy
All governance cleanup remains inside this single change proposal.
- **Reasoning**: The project is pre-production and requires a hard cut to one schema without transition code.
- **Constraint**: No compatibility or dual-schema runtime policy is introduced.

## Risks / Trade-offs

- **[Risk]** Permanent failure state might lose important reports. → **Mitigation**: Add a "Retry Manually" button in the `survey-builder` or `survey-frontend` to reset the `retryCount`.
- **[Risk]** Misconfiguration in Global Settings could affect all apps. → **Mitigation**: Add validation in the backend to ensure selected models are from a known supported list.
