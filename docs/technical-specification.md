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

- FastAPI application exposing `/api/v1` routes for surveys, survey responses, and patient responses.
- Domain models in `app/domain/models`; adapters/integrations (e.g., email, Clinical Writer client) under `app/integrations`.
- Persistence via repository pattern in `app/persistence`, injected through `app.persistence.deps`.
- Background tasks for outbound email and optional AI enrichment per request.

### Survey Worker (`services/survey-worker`)

- Python worker that polls MongoDB for pending survey results and submits them to the Clinical Writer service.
- Updates documents with `agentResponse`, `agentResponseStatus`, and timestamps; configurable polling cadence and batch size.

### Clinical Writer API (`services/clinical-writer-api`)

- Independent FastAPI + LangGraph service for generating medical narratives.
- Uses a **classification Strategy Pattern** (ported from previous docs): prioritizes inappropriate-content detection, JSON payload detection, conversation recognition, and a fallback “other” strategy to route input to the right agent before invoking the LLM. Central configuration lives in `AgentConfig` and strategies are orchestrated through `ClassificationContext`.
- Exposes an `/invoke` style endpoint (default port `9566` when run via its compose file) consumed by the worker/backend.

### Flutter Applications (`apps/`)

- `survey-frontend`: screener-focused survey UI.
- `survey-patient`: patient-facing response flow (build args allow screener identity defaults).
- `clinical-narrative`: displays generated narratives.
- All apps use the shared design system and generated Dart SDK from the OpenAPI contract.

### Shared Packages (`packages/`)

- `contracts`: OpenAPI contract and generated Dart/Python SDKs.
- `design_system_flutter`: Flutter theming and widgets (seed color `Colors.orange`).
- `shared_python`: shared Python utilities (if consumed by services).

## Data Model & Persistence

- **Survey**: definition of questions and metadata, stored in `surveys` collection.
- **SurveyResponse** and **PatientResponse**: captured answers plus patient info, stored in respective collections; enriched with `agentResponse` payloads from the Clinical Writer.
- **Agent response fields**: classification, generated medical record, optional error, and status metadata maintained by backend/worker.

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

- Authentication/authorization and multi-tenancy are not implemented.
- Direct database or LLM access from client applications is prohibited.
