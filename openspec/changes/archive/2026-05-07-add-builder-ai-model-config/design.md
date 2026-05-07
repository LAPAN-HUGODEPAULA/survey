## Context

The Clinical Writer AI Agent currently uses a centralized and largely static configuration for LLM providers and parameters (temperature, model names). While `ProcessRequest` already supports basic model overrides, it lacks support for advanced parameters like reasoning effort and input caching, and the configuration isn't fully integrated with the dynamic prompt/persona resolution from MongoDB. Furthermore, the request polling logic in the frontend/backend does not account for the high latency of reasoning-capable models, leading to unnecessary load.

## Goals / Non-Goals

**Goals:**
- **MVP Cost-Effectiveness**: Enable a "Ultra-Low Cost" mode by default (no thinking, deterministic sampling, aggressive caching).
- **Dynamic Configuration**: Allow overriding AI parameters (model, temperature, reasoning) via `survey-builder` Access Points.
- **LangGraph State Integration**: Parameters flow from `ContextLoader` -> `GraphState` -> `ModelRouter`.
- **Input Caching**: Implement context caching for stable prompt prefixes (50% cost reduction).
- **Resilient Polling**: Refactor polling to reduce load (15s delay, 10s intervals).

**Non-Goals:**
- Full response caching (focus only on input/prefix caching).
- Generic LLM proxy (GLM and Gemini only).

## Decisions

### 1. AI Parameter Flow via LangGraph State
**Decision**: The `ContextLoader` node will retrieve `aiConfig` from the Access Point and store it in the graph's `state`. Subsequent nodes (`ClinicalAnalyzer`, `PersonaWriter`) will pull these values from the state and pass them to `ModelRouter.invoke()`.
- **Rationale**: Keeps the graph's configuration centralized and manageable, while the `ModelRouter` remains a stateless executor.

### 2. MVP "Ultra-Low Cost" Defaults
**Decision**: When `aiConfig` is missing or in "MVP Mode", use the following:
- `primaryModel`: `glm-4.5-flash` (Current cost-effective flagship)
- `thinking`: `disabled`
- `do_sample`: `false` (Deterministic)
- `temperature`: `0.0`
- `enableCaching`: `true`

### 3. Cache-Friendly Prompt Construction
**Decision**: Ensure prompt templates are constructed with **Static Instructions** (Instructions, Domain Rules) at the beginning and **Dynamic Data** (Patient JSON) at the end.
- **Rationale**: LLM providers require a matching prefix for cache hits. Putting variable data at the end maximizes the reusable prefix length.

### 4. Polling Optimization
**Decision**: Update `survey-backend` and frontends to use a `Delayed Start` polling pattern.
- **Rationale**: Reasoning-capable models often take >30s. Polling immediately at 2s intervals creates unnecessary backend/database load.
- **New Intervals**: 15s initial delay, then 10s intervals.

## Risks / Trade-offs

- **[Risk]** Mismatched parameters (e.g., passing `reasoning_effort` to a model that doesn't support it). → **Mitigation**: Implement provider-specific parameter mapping in `ModelRouter` with safe defaults.
- **[Risk]** Increased configuration complexity for admins. → **Mitigation**: Use sensible system-wide defaults in `SystemSettings` that can be overridden at the `AgentAccessPoint` level.
- **[Risk]** Caching expiration/invalidation. → **Mitigation**: Focus on "Input Caching" (context caching) for stable prefixes (prompts) rather than full response caching.

## Migration Plan

1. **Database**: Run migration script to add `aiConfig` fields to `AgentAccessPoints`.
2. **Backend**: Update `survey-backend` to fetch and pass these new fields to the clinical writer.
3. **AI Service**: Update `ProcessRequest` model and `ModelRouter` implementation.
4. **Builder**: Add the "AI Config" tab/section to the Access Point editor.
5. **Frontend**: Update `survey_patient` and `survey_frontend` AI waiting components.
