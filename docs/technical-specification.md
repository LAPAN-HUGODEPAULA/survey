# Technical Specification

## Overview

The LAPAN Survey Platform is a monorepo delivering survey collection and AI-assisted clinical narratives. It includes a FastAPI backend, supporting worker jobs, multiple Flutter web clients, and an AI Clinical Writer service that runs a LangGraph pipeline to classify and generate medical narratives. MongoDB is the system of record and all data access is mediated by repositories.

## Core Principles

- **Contract-first**: `packages/contracts/survey-backend.openapi.yaml` defines the API and generates SDKs.
- **Layered data access**: MongoDB usage is isolated in `services/survey-backend/app/persistence/**` with dependency-injected repositories.
- **Stateless services**: API and worker rely on MongoDB and external services only.
- **Shared UX**: Flutter apps consume the shared `design_system_flutter` theme (seeded with `Colors.orange`).
- **Composable deployments**: Docker Compose orchestrates services with environment-based configuration.

## System Components

### Survey Backend (`services/survey-backend`)

- FastAPI application exposing `/api/v1` routes for reusable survey prompts, surveys, survey responses, and patient responses.
- Domain models in `app/domain/models`; adapters/integrations (e.g., email, Clinical Writer client) under `app/integrations`.
- Persistence via repository pattern in `app/persistence`, injected through `app.persistence.deps`.
- Background tasks for outbound email and optional AI enrichment per request.

### Survey Worker (`services/survey-worker`)

- Python worker that polls MongoDB `survey_responses` documents and submits pending items to the Clinical Writer service.
- Retries responses with missing agent output, failed status, pending status, or stale `processing` status after a configurable timeout.
- Updates documents with `agentResponse`, `agentResponseStatus`, and `agentResponseUpdatedAt`; configurable polling cadence, batch size, timeout, and stale-processing threshold.

### Clinical Writer API (`services/clinical-writer-api`)

- Independent FastAPI + LangGraph service for generating medical narratives.
- Uses `PromptRegistry` to resolve `prompt_key` to prompt text and `prompt_version`, with Google Drive as the primary provider.
- Exposes a `/process` endpoint (default port `9566` when run via root `docker-compose.yml`) consumed by the worker/backend.

### Flutter Applications (`apps/`)

- `survey-frontend`: screener-focused survey UI.
- `survey-patient`: patient-facing response flow (build args allow screener identity defaults).
- `clinical-narrative`: A conversational platform for clinical documentation. It supports session management, voice input with transcription, AI-driven clinical assistance, and document generation.
- `survey-builder`: An application for administrators and researchers to create and manage surveys. It provides a user-friendly interface for editing all aspects of a survey, including questions and instructions.
- All apps use the shared design system and generated Dart SDK from the OpenAPI contract.

### Shared Packages (`packages/`)

- `contracts`: OpenAPI contract and generated Dart/Python SDKs.
- `design_system_flutter`: Flutter theming and widgets (seed color `Colors.orange`).
- `shared_python`: shared Python utilities (if consumed by services).

## Security and Privacy

- The platform now has a stronger focus on security and privacy, with platform-wide access control, encryption, and audit logging.
- All services and applications are designed to be compliant with LGPD.

## Data Model & Persistence

- **SurveyPrompt**: reusable prompt definition stored in the `survey_prompts` collection.
- **Survey**: definition of questions and metadata, stored in the `surveys` collection with an embedded `prompt` reference (`promptKey`, `name`).
- **SurveyResponse**: captured answers plus patient info, stored in `survey_responses`; backend list/read routes strip internal worker-only enrichment fields from the plain response model.
- **PatientResponse**: patient-facing captured answers plus patient info, stored in `patient_responses`.
- **Agent response fields**: `agentResponse`, `agentResponseStatus`, and `agentResponseUpdatedAt` are maintained by backend/worker for enrichment flow; `agentResponse` itself carries `ok`, `input_type`, `prompt_version`, `model_version`, `report`, `warnings`, `classification`, `medicalRecord`, and `errorMessage`.

## Integrations

- **Email**: background tasks send survey/patient response emails via `app.integrations.email.service`.
- **Clinical Writer**: async HTTP client (`app.integrations.clinical_writer.client`) submits responses to the LangGraph service; worker can reprocess pending items.

## Interfaces & Contracts

- RESTful JSON APIs under `/api/v1`; OpenAPI contract is authoritative.
- Generated SDKs are the supported consumption method for Flutter clients; manual HTTP clients are discouraged.

### API Client Generation

The frontend applications consume the backend API via a generated Dart client. This client is created from the OpenAPI specification and requires an additional code generation step to create the necessary data models.

The entire generation process is automated via a script. This script uses a Docker image to run the `openapi-generator` and then executes `build_runner` to generate the Dart data models (`.g.dart` files).

To regenerate the client, run the following command from the project root:

```bash
./tools/scripts/generate_clients.sh
```

This script will:

1.  Remove the old generated client in `packages/contracts/generated/dart`.
2.  Generate a new client from `packages/contracts/survey-backend.openapi.yaml`.
3.  Run `dart pub get` inside the generated code directory.
4.  Run `dart pub run build_runner build --delete-conflicting-outputs` to generate the required `*.g.dart` model and serializer files.

It's important to run this script whenever the `survey-backend.openapi.yaml` contract is modified to ensure the frontend applications are using the latest API definitions.

## Non-Goals

- Multi-tenant authorization and tenant isolation are not implemented.
- Direct database or LLM access from client applications is prohibited.
