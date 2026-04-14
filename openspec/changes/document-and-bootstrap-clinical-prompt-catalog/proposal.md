## Why

The current prompt catalog is operationally under-documented, stored partly in Google Drive, and not yet seeded into the Mongo-managed catalogs that the platform intends to govern through `survey-builder`. The visible prompt inventory also shows content drift and audience-key mismatches, so the team needs a documented architecture and a reviewed bootstrap pack before publishing canonical records.

## What Changes

- Document the structure of questionnaire prompts, persona skills, output profiles, and agent access points in detail.
- Decompose the current Google Drive prompts into reusable prompt-stack components that can serve as a reviewed starting point.
- Produce a Portuguese runbook for the administrator responsible for registering and maintaining prompts in `survey-builder`.
- Produce a Deep Research brief that helps refine prompt quality before MongoDB seed data is published.
- Define and prepare an initial bootstrap catalog for survey prompts, persona skills, output profiles, and starter access-point defaults.

## Capabilities

### New Capabilities
- `clinical-prompt-catalog-governance`: Documentation, governance rules, and bootstrap structure for the Clinical Writer prompt catalog.

### Modified Capabilities
- `clinical-writer-prompt-resolution`: Align runtime prompt composition with the documented questionnaire-plus-persona model.
- `survey-prompt-management`: Clarify the role, authoring rules, and bootstrap content for questionnaire prompts.
- `persona-skill-management`: Clarify the role, authoring rules, and bootstrap content for persona skills.
- `data-privacy-governance`: Define prompt-authoring and runbook guidance that avoids PHI in prompts, examples, and admin workflows.

## Impact

- Affected docs: technical documentation, prompt architecture reference, Portuguese admin runbook, research brief
- Affected storage planning: initial seed content for `QuestionnairePrompts`, `PersonaSkills`, output profiles, and access-point defaults
- Affected operations: prompt review workflow before catalog publication
- Dependencies: access-point management model, builder admin ownership
