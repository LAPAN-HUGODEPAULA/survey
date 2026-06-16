# Change: decompose-clinical-writer-integration-client

## Why

The Clinical Writer integration client is a high-churn seam between survey-backend and clinical-writer-api. Decomposing it improves testability, isolates security policy, and prevents future integration changes from editing a 300-line function.

## What Changes

- Split endpoint discovery, request submission, response normalization, progress events, health/status probing, and report text formatting into separate modules/classes.
- Introduce typed request/result models for integration outcomes.
- Unify report-to-text conversion with survey-worker and report-delivery code where feasible.
- Preserve existing external behavior while reducing complexity and nesting.
- Update technical and architectural documentation to reflect the new decomposed module structure.

## Scope

`survey-backend/app/integrations/clinical_writer/**`, `docs/**` (specifically architecture and technical spec documents referencing the client), and directly related tests. It may touch `survey-worker` only for shared formatter extraction.

## Impact

- Affected capability: `clinical-writer-integration`
- Refactor leverage: High
- Confidence: High for complexity and size findings
- Expected implementation style: focused PR, preserve external behavior unless the spec explicitly changes it.

## Evidence From Skylos v1

- Quality table reports survey-backend/app/integrations/clinical_writer/client.py as 598 lines.
- send_to_langgraph_agent has complexity 45/64 and 328 lines.
- The same client has complex report text conversion, normalization, endpoint selection, health/status handling, duplicate literals, and O(N^2) report conversion loops.

## Non-Goals

- Do not perform unrelated formatting churn.
- Do not change API contracts unless a task explicitly requires OpenAPI/spec updates.
- Do not suppress findings without documenting whether they are generated noise, first-party import context, test-only scope, or proven false positives.
