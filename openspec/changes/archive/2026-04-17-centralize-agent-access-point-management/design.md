## Context

The platform now has reusable questionnaire prompts and persona skills, but the runtime still behaves as if a single `promptKey` were the main control knob. `survey-patient` and `survey-frontend` often pass only prompt references, while the Clinical Writer runtime in production still depends on Google Drive for part of prompt resolution. This prevents `survey-builder` from acting as the operational source of truth and makes agent behavior hard to reason about, test, and audit.

The requested target state is explicit configuration per agent entry point. Each UI flow that invokes the clinical writer should reference a stable access-point key, and the backend should resolve the actual prompt stack from builder-managed configuration stored in MongoDB. Survey-level defaults remain useful, but only as fallback.

## Goals / Non-Goals

**Goals:**
- Introduce a first-class access-point configuration model that maps runtime entry points to questionnaire prompt, persona skill, and output profile.
- Make `survey-builder` the administrative source of truth for those mappings.
- Move Clinical Writer runtime resolution to Mongo-first builder-managed catalogs and take Google Drive out of the runtime-critical path for survey-driven flows.
- Update frontend consumers to reference access-point keys instead of assuming a single prompt-only contract.
- Preserve survey-level defaults as a fallback layer during migration.

**Non-Goals:**
- Rewriting the entire Clinical Writer graph architecture.
- Removing every legacy prompt flow in one step beyond the survey-driven paths covered here.
- Designing a full prompt-quality review workflow in this change; documentation and bootstrap content are handled by the catalog-governance change.

## Decisions

1. **Model runtime entry points explicitly as Access Points (AAPs)**
   Each AAP acts as the "glue" for a specific intent. It binds:
   - **Questionnaire Prompt (The Brain):** Clinical logic, scoring, and mapping.
   - **Persona Skill (The Voice):** Tone and audience-specific language.
   - **Output Profile (The Skeleton):** Structural sections and technical format (JSON UI vs. Document).

2. **Support Multi-Artifact Fan-Out during Orchestration**
   The system must support triggering multiple AAPs from a single survey completion event. For example, a single submission can generate a Clinical Dashboard (JSON), a Parent Letter (PDF), and a School Report (PDF) simultaneously by invoking three different AAPs.

3. **Resolve final prompt stacks in the backend (survey-backend)**
   `survey-backend` acts as the orchestrator. It resolves the `accessPointKey` provided by the frontend (or configured as a default for the survey) into the specific components before calling the Clinical Writer service.

4. **Use Mongo-backed catalogs as the runtime source**
   All three pillars (QuestionnairePrompts, PersonaSkills, OutputProfiles) and the AAP configurations themselves are managed in MongoDB via `survey-builder`.

4. **Keep migration compatibility through fallback resolution**
   Existing survey-level defaults and legacy prompt-only paths remain supported while access points are introduced. This allows stepwise migration without breaking existing reports.

## Risks / Trade-offs

- [Risk] Multiple configuration layers can create operator confusion. → Mitigation: document the precedence order clearly and surface the effective runtime configuration in builder UI.
- [Risk] Access-point misconfiguration could break report generation for a whole flow. → Mitigation: validate references at save time and fail with actionable configuration errors at runtime.
- [Risk] Removing Google Drive from the critical path too quickly could break unmigrated flows. → Mitigation: keep a documented non-survey fallback path until the catalog bootstrap is complete.

## Migration Plan

1. Introduce the access-point domain model, persistence, and admin APIs in the backend.
2. Add access-point management UI in `survey-builder`, including validation against prompt and persona catalogs.
3. Update backend runtime selection logic to resolve Clinical Writer settings by access point first, then survey defaults, then legacy fallback.
4. Update `survey-patient` and `survey-frontend` to send stable `accessPointKey` values from each agent entry point.
5. Switch survey-driven Clinical Writer resolution to Mongo-first and keep Google Drive only as an explicit migration fallback for non-migrated flows.

## Open Questions

- Should access points live in their own collection, or as a nested structure on surveys plus a global registry for shared flows?
- Do we need a builder-visible “effective configuration preview” in the first release, or can validation plus documentation cover the rollout?
