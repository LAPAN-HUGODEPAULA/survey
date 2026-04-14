# Survey Builder Admin and Agent Configuration Roadmap

## Context

The current `survey-builder` is not yet the authoritative control plane for the LAPAN Survey platform.
The runtime prompt stack is split across:

- `survey-builder`, which can already edit surveys, reusable prompts, and persona skills
- `survey-backend`, which already understands `prompt`, `personaSkillKey`, and `outputProfile`
- `clinical-writer-api`, which is still running with `PROMPT_PROVIDER=google_drive` in the current deployment
- `survey-patient` and `survey-frontend`, which still model the runtime mostly as `promptKey` only

This creates four immediate risks:

1. Unauthorized access to the admin surface
2. Lack of LGPD-grade auditability for admin changes
3. Runtime drift between builder-managed data and Google Drive prompts
4. Operational ambiguity because prompt structure, ownership, and intended usage are not documented well enough

## Evidence Gathered

- `survey-builder` boots directly into `SurveyListPage` without authentication in [main.dart](/home/hugo/Documents/LAPAN/dev/survey/apps/survey-builder/lib/main.dart:8)
- the current deployment of `clinical_writer_agent` is configured with `PROMPT_PROVIDER=google_drive`
- the current runtime failure in `survey-patient` is caused by prompt resolution through Google Drive, not by quota exhaustion
- `QuestionnairePrompts` and `PersonaSkills` are currently empty in MongoDB
- `survey-patient` and `survey-frontend` still ignore survey-level `personaSkillKey` and `outputProfile`

## Change Set

The implementation should be decomposed into five coordinated OpenSpec changes:

1. `secure-survey-builder-admin-access`
2. `add-survey-builder-admin-audit-trail`
3. `centralize-agent-access-point-management`
4. `improve-survey-builder-navigation-ux`
5. `document-and-bootstrap-clinical-prompt-catalog`

## Recommended Order

### Phase 1: Governance and source of truth

1. `document-and-bootstrap-clinical-prompt-catalog`
2. `centralize-agent-access-point-management`

Rationale:
- the team needs a documented prompt architecture before writing seed data
- the runtime must stop depending on Google Drive as the critical path
- access-point configuration should be defined before UX-only work expands the builder UI

### Phase 2: Security and compliance

3. `secure-survey-builder-admin-access`
4. `add-survey-builder-admin-audit-trail`

Rationale:
- admin access must be restricted before broader builder adoption
- audit logging must cover the final admin flows rather than a temporary UI state

### Phase 3: Builder usability

5. `improve-survey-builder-navigation-ux`

Rationale:
- navigation improvements should be applied after the authenticated admin shell and access-point workflows are defined

## Planned Outcomes

### Admin control plane

- `survey-builder` becomes the only supported admin surface for survey prompt governance
- only the platform default screener account may authenticate into the builder
- builder routes become session-aware and reject anonymous access

### Auditability and LGPD posture

- every admin action in `survey-builder` produces a persistent audit event
- audit events record actor, timestamp, action, target resource, result, and request correlation id
- prompt and persona edits become traceable without storing PHI in admin audit payloads

### Runtime consistency

- prompt logic is resolved from Mongo-managed catalogs first
- Google Drive stops being a mandatory runtime dependency for survey-driven flows
- `survey-patient` and `survey-frontend` call the agent through explicit access points rather than implicit prompt-only assumptions

### Builder UX

- the builder gets a persistent home/dashboard shell
- prompt and skill screens become reachable and escapable through clear global navigation
- future admin sections can be added without routing dead ends

### Documentation and enablement

- prompt architecture is documented in detail
- a Portuguese runbook is defined for the admin responsible for prompt registration
- a research brief is prepared so prompt quality can be iterated in Deep Research before seeding MongoDB

## Seed Strategy

The prompt catalog should be seeded in two steps:

1. Create a reviewed Markdown source pack first
   - decompose the current Google Drive prompts into questionnaire logic, persona style, and output profile rules
   - identify inconsistencies and missing variants
   - define the target catalog structure
2. Seed MongoDB only after review
   - create initial `QuestionnairePrompts`
   - create initial `PersonaSkills`
   - create initial access-point defaults
   - validate representative report outputs before treating the catalog as canonical

## Acceptance Gates Before Implementation

- every OpenSpec proposal is written in English
- the admin runbook requirement is explicitly included in the documentation change
- the research brief captures current Google Drive prompt behavior and known flaws
- no proposal assumes direct production writes before prompt review

## Deliverables Created In This Planning Pass

- OpenSpec proposal for builder admin access control
- OpenSpec proposal for builder audit trail
- OpenSpec proposal for access-point-based prompt management
- OpenSpec proposal for builder navigation improvements
- OpenSpec proposal for prompt catalog documentation and bootstrap
- prompt research brief for Deep Research preparation
