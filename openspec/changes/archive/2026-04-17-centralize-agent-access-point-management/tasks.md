## 1. Access-point domain and persistence

- [x] 1.1 Define the backend data model and storage contract for agent access points, including stable keys, target-flow metadata, prompt bindings, persona bindings, and output profiles.
- [x] 1.2 Implement backend validation that enforces referential integrity against questionnaire prompts, persona skills, and output profiles.
- [x] 1.3 Add backend APIs and tests for listing, creating, updating, and deleting access-point definitions.

## 2. Runtime resolution and orchestration

- [x] 2.1 Update survey-driven runtime selection so Clinical Writer resolves effective configuration by request override, then access point, then survey defaults, then documented legacy fallback.
- [x] 2.2 Implement "Multi-Artifact Fan-Out" in `survey-backend`, allowing a single survey completion to trigger multiple independent Clinical Writer requests based on a list of associated Access Points.
- [x] 2.3 Switch survey-driven Clinical Writer prompt resolution to use Mongo-managed catalogs as the primary source and keep Google Drive only as an explicit fallback for non-migrated flows.
- [x] 2.4 Add runtime tests covering configured access points, missing bindings, invalid references, and fallback behavior during migration.

## 3. Builder and consumer application integration

- [x] 3.1 Add access-point catalog and form workflows to `apps/survey-builder`, including validation, loading states, and conflict handling.
- [x] 3.2 Update `survey-patient` and `survey-frontend` agent entry points to send stable `accessPointKey` values instead of relying on prompt-only assumptions.
- [x] 3.3 Document the precedence order and migration path from survey defaults to access-point-driven runtime configuration.
