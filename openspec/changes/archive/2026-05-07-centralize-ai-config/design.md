## Context

The current AI configuration is split between hardcoded environment variables (for models) and hardcoded Python strings (for orchestrator prompts). While `AgentAccessPoint` already has a structured `AIConfig` model in the backend, it is not fully exposed in the `survey-builder` UI. Furthermore, there is no mechanism to override the core system prompts used by the LangGraph agents in `clinical-writer-api`.

## Goals / Non-Goals

**Goals:**
- Provide full administrative control over LLM selection (Primary/Fallback) and sampling parameters per access point.
- Allow overriding the base orchestrator prompts (Instructions and JSON Format) without code changes.
- Maintain backward compatibility with existing environment-based configurations.

**Non-Goals:**
- Changing the underlying LangGraph state machine logic.
- Adding real-time prompt A/B testing (out of scope for this phase).

## Decisions

### 1. Data Model Extension
We will extend the `AgentAccessPoint` model in `survey-backend` to include `systemPromptOverride` and `formatPromptOverride`.
*   **Rationale**: Placing these in the Access Point (instead of a global setting) allows different applications or flows to use different orchestrator logic or formatting rules (e.g., one for medical reports, another for patient summaries).

### 2. UI Integration in survey-builder
The `AgentAccessPointFormPage` will be updated with two new expandable sections:
- **Configuração de IA**: Fields for Primary/Fallback providers and models, plus a temperature slider.
- **Prompts do Orchestrator**: Text areas for System and Format prompt overrides.
*   **Rationale**: Keeping these within the Access Point form centralizes all runtime configuration in one place for the administrator.

### 3. Priority-based Resolution
The `clinical-writer-api` will follow a strict priority for configuration:
1.  **Request Overrides**: Values passed in the `/process` request (originating from the DB via the backend).
2.  **Environment Variables**: Legacy fallback for models.
3.  **Hardcoded Constants**: Final fallback for prompts.
*   **Rationale**: This ensures a safe transition where existing setups continue to work while allowing surgical overrides where needed.

## Risks / Trade-offs

- **[Risk]** Invalid prompt overrides could break the AI agent's logic. → **Mitigation**: Add validation in `survey-builder` (non-empty, basic formatting) and ensure the backend handles agent failures gracefully.
- **[Risk]** Overriding the JSON format prompt could result in responses that the frontend cannot parse. → **Mitigation**: Add clear warnings in the UI that format overrides must be compatible with the application's data contracts.
