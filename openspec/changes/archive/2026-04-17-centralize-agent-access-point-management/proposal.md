## Why

The platform now has the pieces for reusable prompts and persona skills, but not the configuration model that links them to real agent entry points. At the same time, survey-driven runtime behavior still depends on Google Drive in production, while consumer apps still think mostly in terms of `promptKey` only. This prevents `survey-builder` from acting as the real source of truth.

## What Changes

- Introduce explicit agent access points that can be configured from `survey-builder`.
- Allow administrators to select a questionnaire prompt, persona skill, and output profile for each access point.
- Move survey-driven clinical writer resolution to a Mongo-first model managed by builder data.
- Update `survey-patient` and `survey-frontend` to reference access-point keys instead of implicit prompt-only assumptions.
- Keep survey-level defaults as a fallback layer, but make access-point configuration the primary runtime contract.
- Remove Google Drive from the runtime-critical path for survey-driven prompt resolution.

## Capabilities

### New Capabilities
- `agent-access-point-management`: Configure runtime agent entry points and map each one to prompt, persona, and output defaults.

### Modified Capabilities
- `clinical-writer-prompt-resolution`: Resolve survey-driven prompt stacks from builder-managed Mongo catalogs first.
- `survey-prompt-management`: Promote questionnaire prompts from passive catalog entries to runtime-linked components.
- `persona-skill-management`: Promote persona skills from passive catalog entries to runtime-linked components.
- `frontend-survey-builder`: Add admin workflows for access-point configuration.
- `survey-completion-handoff`: Align patient and screener completion flows with explicit access-point-based agent routing.

## Impact

- Affected apps: `apps/survey-builder`, `apps/survey-patient`, `apps/survey-frontend`
- Affected backend areas: survey runtime selection, clinical writer request composition, admin APIs
- Affected storage: new access-point configuration collection or survey-linked structure
- Dependencies: prompt catalog documentation, builder admin auth, prompt registry reconfiguration
