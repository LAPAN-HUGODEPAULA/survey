# Change: centralize-fastapi-authorization-contracts

## Why

A route-by-route auth cleanup is error-prone. A centralized authorization contract creates an auditable route matrix, clarifies public exceptions, and reduces false positives.

## What Changes

- Create an authorization matrix for survey-backend routers.
- Apply route/router-level dependencies for authenticated, builder, screener, patient-link, and internal-service access patterns.
- Explicitly document public routes such as registration or link resolution with compensating controls.
- Add tests that assert protected mutating routes reject unauthenticated requests.

## Scope

survey-backend FastAPI route definitions, auth dependencies, tests, and route documentation. Does not change clinical-writer-api authentication unless discovered as a dependency.

## Impact

- Affected capability: `backend-auth`
- Refactor leverage: High
- Confidence: Medium: findings may be false positives if router-level or middleware guards exist
- Expected implementation style: focused PR, preserve external behavior unless the spec explicitly changes it.

## Evidence From Skylos v1

- Quality table reports 36 Framework Security rows for mutating routes with no obvious auth/permission/security/dependency guard.
- Affected route groups include agent access points, AI agents/settings, chat messages/sessions, clinical_writer, documents, medications, patient_responses, persona_skills, screener routes/settings, survey, survey_prompts, survey_responses, and voice_transcriptions.
- AGENTS.md says FastAPI routers should use dependency-injected repositories and review should watch unsafe validation and business logic leaking into routing.

## Non-Goals

- Do not perform unrelated formatting churn.
- Do not change API contracts unless a task explicitly requires OpenAPI/spec updates.
- Do not suppress findings without documenting whether they are generated noise, first-party import context, test-only scope, or proven false positives.
