## Why

The clinical writer currently depends on a single Gemini provider, which creates availability risk and limits cost/performance tuning. We need provider-level resiliency (GLM primary, Gemini fallback). Additionally, the system currently sends automatic emails containing patient data JSON, which is redundant for production use and violates LGPD privacy principles regarding unsolicited data sharing.

## What Changes

- Add a lightweight, provider-aware LLM router in `clinical-writer-agent` using the `openai` SDK for GLM (primary) and Gemini (fallback) to provide a robust, standardized integration.
- Remove automatic email sending tasks triggered upon patient screening and professional survey submission in `survey-backend`.
- Extend access-point runtime configuration to include provider/model selection fields so each access point can override default models.
- Persist default model values (`GEMINI_MODEL`, `GLM_MODEL`) in MongoDB automatically at backend startup for centralized baseline configuration.
- Extend `survey-builder` access-point administration UI to allow administrators to set provider/model strings for GLM and Gemini per access point.
- Update project documentation (API specs, architecture guides) to reflect the new AI routing and the removal of automatic email flows.

## Capabilities

### New Capabilities
- `clinical-writer-provider-routing`: Multi-provider LLM client routing with GLM primary and Gemini fallback, using the industry-standard `openai` SDK for GLM (via OpenAI-compatible endpoint) to ensure reliability and maintainability.

### Modified Capabilities
- `agent-access-point-management`: Extend access-point schema and resolution precedence to include provider/model bindings.
- `frontend-survey-builder`: Extend access-point forms and validation to manage provider/model strings.
- `privacy-compliance-cleanup`: Remove legacy automatic JSON email triggers in `patient_responses` and `survey_responses` routes.
- `layered-graph-orchestration`: Ensure all graph nodes consume provider-aware routing.

## Impact

- Affected services: `services/clinical-writer-api/clinical_writer_agent`, `services/survey-backend`, and `apps/survey-builder`.
- Privacy impact: Improved LGPD compliance by eliminating unsolicited email data exports.
- Operational impact: Improved resilience and runtime configurability; reduced external dependency surface by using `httpx` instead of `langchain-openai`.
- Documentation impact: Updated API guides and software design docs.
