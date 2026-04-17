# Agent Access-Point Runtime

This runbook documents the runtime precedence and migration path for survey-driven Clinical Writer orchestration.

## Scope

This applies to:

- `POST /survey_responses/`
- `POST /patient_responses/`
- `POST /clinical_writer/process` when `accessPointKey` is provided

It does not replace the broader prompt-catalog governance guidance in [clinical-prompt-catalog-governance.md](/home/hugo/Documents/LAPAN/dev/survey/docs/clinical-prompt-catalog-governance.md). This document is the operational runtime view.

## Runtime Model

An agent access point is a builder-managed record that binds one runtime entry point to:

- `promptKey`
- `personaSkillKey`
- `outputProfile`
- `sourceApp`
- `flowKey`
- optional `surveyId`

This lets the frontend identify intent with a stable key while the backend resolves the effective prompt stack.

## Precedence Order

The backend resolves runtime configuration in this order:

1. Explicit request overrides
2. Access-point bindings
3. Survey defaults
4. Legacy fallback

The concrete fields are:

1. Explicit request overrides
   - `promptKey`
   - `personaSkillKey`
   - `outputProfile`
2. Access-point bindings
   - record resolved by `accessPointKey`
3. Survey defaults
   - `survey.prompt.promptKey`
   - `survey.personaSkillKey`
   - `survey.outputProfile`
4. Legacy fallback
   - historical prompt-selection fallback for non-migrated survey flows

## Fan-Out Behavior

Survey completion can trigger multiple Clinical Writer artifacts from one submission.

The backend:

1. resolves the primary selection from the request and precedence rules
2. looks up all configured access points for the same `sourceApp`, `flowKey`, and `surveyId`
3. invokes Clinical Writer once per resolved access point
4. returns:
   - `agentResponse`: first artifact, kept for backward compatibility
   - `agentResponses`: full list of generated artifacts, each tagged with `accessPointKey`

If no additional runtime access points are configured, the request still produces the primary artifact only.

## Current Client Keys

The survey completion flows currently use these stable keys:

- `survey_patient.thank_you.auto_analysis`
- `survey_frontend.thank_you.auto_analysis`

Do not replace these in clients with prompt-specific assumptions. If runtime behavior must change, update the access-point catalog instead.

## Migration Path

Use this sequence when migrating a survey flow:

1. Create or validate the questionnaire prompt in the Mongo-backed prompt catalog.
2. Create or validate the persona skill and its `outputProfile`.
3. Create an access point for the target `sourceApp` and `flowKey`.
4. Update the client entry point to send the stable `accessPointKey`.
5. Keep survey defaults in place until the access-point path is validated.
6. Remove reliance on survey-level defaults only after the access-point-backed flow is stable.

## Fallback Expectations

Fallback remains intentional during migration:

- Access-point resolution is the preferred path for migrated flows.
- Survey defaults remain a safety net.
- The legacy prompt fallback remains available only for non-migrated paths and should not be treated as the long-term operating model.

If a migrated access point references missing prompt or persona records, the backend should fail with a configuration error instead of silently inventing a runtime selection.

## Operator Checks

Before publishing or modifying an access point, confirm:

- the `promptKey` exists
- the `personaSkillKey` exists
- the `outputProfile` matches the referenced persona skill
- the optional `surveyId` points to a real survey
- the target client flow sends the intended `accessPointKey`

## Release Impact

This change is additive at the API contract level but operationally important:

- clients can keep reading `agentResponse`
- clients that need all generated artifacts should move to `agentResponses`
- runtime behavior should now be changed through builder-managed access points rather than direct prompt edits in application code
