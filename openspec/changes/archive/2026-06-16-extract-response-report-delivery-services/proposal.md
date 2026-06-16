# Change: extract-response-report-delivery-services

## Why

Patient and survey response routes combine routing, persistence, clinical writer invocation, report formatting, PDF/email generation, and error handling. Extracting a report-delivery service reduces duplicated risk and makes contract changes safer.

## What Changes

- Move response creation orchestration from route bodies into services/use cases.
- Create a shared ReportDeliveryService for resolving report content, generating attachments, and sending emails.
- Add response models and return annotations for affected routes.
- Coordinate with auth and safe-path proposals for authorization and attachment containment.

## Scope

survey-backend app/api/routes/patient_responses.py, survey_responses.py, integrations/email, document/PDF generation helpers, and tests.

## Impact

- Affected capability: `report-delivery`
- Refactor leverage: High
- Confidence: High for complexity/duplication, medium for auth until route inventory is done
- Expected implementation style: focused PR, preserve external behavior unless the spec explicitly changes it.

## Evidence From Skylos v1

- patient_responses.py create_patient_response is 145 lines with complexity 17/24; send_report_email lacks a response model/return annotation and has auth and path traversal findings.
- survey_responses.py create_survey_response is 134 lines with complexity 17/19; send_report_email/resend_survey_email have missing response models/auth findings.
- Both patient_responses.py and survey_responses.py contain _resolve_report_text and _report_dict_to_text complexity findings, indicating duplicated report formatting behavior.

## Non-Goals

- Do not perform unrelated formatting churn.
- Do not change API contracts unless a task explicitly requires OpenAPI/spec updates.
- Do not suppress findings without documenting whether they are generated noise, first-party import context, test-only scope, or proven false positives.
