# Software Requirements

## Purpose
Define the capabilities and constraints of the LAPAN Survey Platform as it exists today.

## Stakeholders & Roles
- **Screener/Clinician**: Creates surveys and records responses with patients.
- **Patient**: Provides answers via patient-facing flows (no authentication).
- **Operator**: Runs the platform, manages deployments, monitors worker jobs and the Clinical Writer AI service.

## Functional Requirements
- Create and list surveys; retrieve survey definitions by id.
- Capture survey responses and patient responses, persist them in MongoDB.
- Send email notifications for survey and patient responses via background tasks.
- Enrich survey and patient responses with AI-generated narratives and classifications through the Clinical Writer service (triggered by backend tasks or the survey-worker).
- Expose REST APIs under `/api/v1` with OpenAPI as the contract source.
- Provide Flutter web applications for screeners, patients, and clinical narratives, all using the shared design system.
- Generate client SDKs from the OpenAPI contract (`tools/scripts/generate_clients.sh`).

## Non-Functional Requirements
- Maintainability through clear layering (API → domain → persistence) and contract-first development.
- Reliability: database writes must confirm success or surface errors; background jobs should log and mark failed attempts.
- Deployability via Docker Compose with environment-driven configuration.
- Consistent UX: shared Flutter theme seeded with `Colors.orange`.
- Observability: structured logging across backend, worker, and Clinical Writer service.

## Constraints & Non-Goals
- MongoDB is the system of record (no secondary datastore).
- No patient authentication or multi-tenancy implemented.
- Clients must not access MongoDB or AI services directly; all access goes through backend/worker.
- Secrets and API keys are provided via environment variables; none are committed to source control.
