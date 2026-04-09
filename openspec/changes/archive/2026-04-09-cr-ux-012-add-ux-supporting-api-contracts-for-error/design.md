## Context

The LAPAN Survey Platform requires a more robust communication channel between the backend and frontends to support high-quality user interactions during failures and long-running operations. Currently, error details are often lost, and long tasks are handled synchronously, leading to timeouts and a poor user experience.

## Goals / Non-Goals

**Goals:**
- Standardize the error response schema across all services.
- Implement a reusable asynchronous job pattern for AI-related tasks.
- Expose granular processing stages for background jobs.
- Enhance authentication failure reporting.

**Non-Goals:**
- Implementing the actual token-based reset link logic (only defining the contract).
- Migrating all existing endpoints to the new error schema in one go (prioritize AI and Auth).

## Decisions

### 1. Standardized Error Response Model
**Decision:** All services will adopt a shared `ApiError` model in Pydantic, which will be used in FastAPI exception handlers.
**Rationale:** Consistency allows the Flutter design system to build a single error-parsing logic that works for all apps.
**Implementation:** Create `app/api/errors.py` in `survey-backend` with a global handler for `HTTPException`.

### 2. Job-Based Asynchronous AI Pattern
**Decision:** Use a simple in-memory job store (or Redis/MongoDB for persistence in later phases) to track the lifecycle of long-running tasks.
**Rationale:** Enables immediate `202 Accepted` responses and avoids frontend timeouts.
**Implementation:** Extend the existing `_TASKS` dictionary pattern in `clinical_writer.py` to other long-running routes if needed.

### 3. Stage-Based Progress Reporting
**Decision:** Standardize AI processing stages: `queued`, `loading_context`, `analyzing`, `drafting`, `reviewing`, `formatting`, `completed`, `failed`.
**Rationale:** Provides reassurance to users through specific pt-BR messages corresponding to each stage.

### 4. Tokenized Recovery Contract
**Decision:** Update the `/screeners/recover-password` response to be generic and successful even if the email isn't found, preventing user enumeration.

## Risks / Trade-offs

- **[Risk]** Breaking existing API clients that expect the old error format. → **Mitigation:** Use a phased rollout or provide a middleware that transforms errors based on an `Accept` header or API version.
- **[Risk]** In-memory job store loss on server restart. → **Mitigation:** Acceptable for MVP; move to MongoDB-backed jobs if persistence becomes critical.
- **[Risk]** Polling overhead. → **Mitigation:** Keep polling intervals reasonable (1-2s) and ensure status endpoints are lightweight.
