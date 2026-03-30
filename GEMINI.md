## Project Overview

This is the LAPAN Survey Platform, a comprehensive healthcare application designed to assess visual hypersensitivity in neurodevelopmental disorders (NDDs) in Brazil. It digitizes and validates the Brazilian Portuguese version of the Cardiff Hypersensitivity Scale (CHYPS-Br).

The platform uses a microservices architecture with a Python/FastAPI backend, MongoDB, and multiple Flutter web frontends. It features an AI-powered multi-agent system for clinical narrative generation and documentation.

## Project Evolution & Milestones

The project has evolved from a basic screening tool into a comprehensive clinical documentation platform:

- **Initial Phase (Jan 2026):** Implemented public patient screening flows.
- **Professional Workflows (Feb 2026):** Added screener registration and administrative survey building capabilities.
- **Clinical Documentation (Mar 2026):** 
    - Launched the `clinical-narrative` application with AI-driven conversation engine.
    - Implemented voice capture and hybrid transcription system.
    - Added centralized template management and clinical document generation.
    - Standardized shared design system, scaffolds, and security/privacy controls.
- **Survey Prompts & Schema Stabilization (Mar 2026):**
    - Refactored survey associations to use centralized reusable prompts.
    - Stabilized response processing and collection naming (`survey_responses`, `patient_responses`).
    - Implemented systematic migration framework for database consistency.
    - Launched version `0.1.0` following Semantic Versioning (tracked in root `VERSION` file).
- **Multi-Agent Architecture Adoption (Mar 2026):**
    - Adopted a 4-stage LangGraph state graph (ContextLoader → ClinicalAnalyzer → PersonaWriter → ReflectorNode) for clinical report generation.
    - Introduced composable prompt architecture (Domain + Persona + Context layers).
    - Implemented reflection cycles for hallucination mitigation and clinical safety.
    - Stored Agent Skills (Personas) in MongoDB for CMS-style management via survey-builder.

## Application Components

The system consists of four interconnected Flutter web applications:

- **`survey-patient`**: A public-facing screening tool (7 questions) for preliminary assessment. Compliant with WCAG 2.1 Level AA.
- **`survey-frontend`**: A professional platform for authorized screeners to administer full assessments (CHYPS-Br), manage patient records, and generate formal reports.
- **`clinical-narrative`**: A conversational documentation tool that transforms clinician-patient interactions into structured medical records using AI.
- **`survey-builder`**: An administrative tool for creating and managing questionnaires, surveys, and reusable clinical prompts.

## Survey Prompt Management

The platform features a centralized system for managing clinical AI prompts:
- **Reusable Prompts**: Prompts are stored in the `survey_prompts` collection and can be referenced by multiple surveys.
- **Prompt References**: Surveys now reference a specific `promptKey`, ensuring consistent AI processing across different survey instances.
- **Management UI**: The `survey-builder` application provides a dedicated interface for CRUD operations on these reusable prompts.

## Multi-Agent Architecture

The Clinical Writer AI service uses a **4-stage LangGraph state graph** that separates clinical interpretation from narrative generation and applies reflection-based safety validation. See `docs/multiagent-architecture.md` for the full architectural rationale.

### 4-Stage Orchestration Graph

1. **ContextLoader** — Retrieves questionnaire interpretation prompts and persona skills from MongoDB.
2. **ClinicalAnalyzer** — Processes response JSON with clinical rules; outputs structured clinical facts (no narrative).
3. **PersonaWriter** — Transforms clinical facts into audience-appropriate Markdown narrative.
4. **ReflectorNode** — Validates grounding, tone, and safety; loops back to writing on failure (up to 2 retries).

### Composable Prompt Layers

- **Interpretation Layer (Domain):** Questionnaire-specific clinical rules from `QuestionnairePrompts` MongoDB collection.
- **Persona Layer (Profile):** Tone, vocabulary, and output format from `PersonaSkills` MongoDB collection.
- **Contextual Data Layer:** Pseudonymized patient response JSON.

### Key Decisions

- Skills/Personas stored in MongoDB as a clinical CMS managed via survey-builder.
- Reflection cycles for hallucination mitigation and clinical safety.
- Asymmetric model usage (lightweight models for analysis, advanced models for critique).
- API-only inference — no self-hosted GPU infrastructure; LoRA fine-tuning evaluated and deferred.

## Database Schema & Migrations

The project uses MongoDB with a systematic migration framework:
- **Collections**:
    - `surveys`: Definitions of clinical questionnaires.
    - `survey_prompts`: Reusable AI instructions for clinical narrative generation.
    - `questionnaire_prompts`: Questionnaire-specific clinical interpretation logic (Domain layer).
    - `persona_skills`: Output persona definitions with tone, format, and safety constraints (Persona layer).
    - `survey_responses`: Records of professional assessments.
    - `patient_responses`: Records of public screenings (pseudonymized).
    - `screeners`: Registered healthcare professionals.
    - `clinical_writer_run_logs`: Audit logs for AI processing tasks.
- **Migrations**: Found in `tools/migrations/survey-backend/`, these scripts ensure schema consistency and handle collection renaming or data normalization.

## Domain Context

- **`Screener`**: Authorized healthcare professional (doctor, psychologist) with professional council registration.
- **`Patient`**: Individual undergoing assessment. Public screening is anonymous; professional assessments use unique identifiers.
- **`Questionnaire` / `Survey`**: Definitions and instances of structured assessments.
- **`Narrative`**: Free-text or voice-captured clinical interview transformed by AI into medical records.

## Tech Stack

- **Versioning**: Semantic Versioning (v0.1.0+) tracked in root `VERSION` file.
- **Backend:** Python 3.13/FastAPI (`survey-backend`, `survey-worker`).
- **AI Service:** Python 3.13/FastAPI with a 4-stage LangGraph state graph (`clinical-writer-api`). See Multi-Agent Architecture section.
- **Frontend:** Flutter for Web, sharing `packages/design_system_flutter`.
- **Database:** MongoDB (surveys, reusable prompts, responses, credentials, logs).
- **Containerization:** Orchestrated with Docker Compose.

## Building and Running the Project

### Prerequisites

- Docker and Docker Compose installed.
- `.env` file at root (use `.env.example` as template).

### Running the Core Stack

```bash
docker compose up -d
```

- **Backend API Docs:** `http://localhost:8000/docs`
- **Screener App:** `http://localhost:8080`
- **Patient App:** `http://localhost:8081`
- **Clinical Narrative App:** `http://localhost:8082`
- **Survey Builder App:** `http://localhost:8083`

### Running the AI Clinical Writer Service

```bash
docker compose -f services/clinical-writer-api/docker-compose.yml up -d
```

- **Clinical Writer API:** `http://localhost:9566`

## Development Conventions

### Coding Style & Localization

- **Localization:** All application UI and code comments MUST be in Brazilian Portuguese (pt-BR).
- **Python:** PEP 8, strict type annotations. `pymongo` only in `app/persistence/**`.
- **Flutter:** Feature-first structure, shared design system with `Colors.orange` primary.

### Architecture Patterns

- **Repository Pattern:** Abstracting MongoDB interactions.
- **Data Contract Pattern:** All data MUST pass through Pydantic models (BaseModel).
- **API-First:** OpenAPI specification is the source of truth (`packages/contracts/survey-backend.openapi.yaml`).

### API and Client Generation

Regenerate SDKs after API changes:
```bash
./tools/scripts/generate_clients.sh
```

## Security and Privacy

- **LGPD Compliance:** Focus on data pseudonymization, encryption, and audit logging.
- **Access Control:** Platform-wide role-based access control (RBAC).
- **Audit Logging:** Comprehensive tracking of AI processing and clinical data access.

## Architectural Guidelines

1.  **Separation of Concerns**: Isolate UI, business logic, and data access.
2.  **DRY Principle**: Extract shared logic into reusable modules.
3.  **SOLID Principles**: Single responsibility, depend on abstractions.
4.  **Layered Architecture**: Presentation → Business → Data.
5.  **Microservices**: Services own their data and expose APIs.
6.  **Event-Driven Patterns**: Decoupled workflows with message brokers.
7.  **Domain-Driven Design (DDD)**: Use Bounded Contexts and Ubiquitous Language.
8.  **API-First**: Define contracts before implementation.
9.  **Cloud-Native**: Stateless, container-ready services.
10. **Clean Architecture**: Business rules at the core; dependencies point inward.

## Commit & Pull Request Guidelines

- **Format:** `{type}({scope}): {:emoji:} {Message}` (Conventional Commits).
- **Types:** `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `perf`, `style`, `build`, `ops`.
- **Small Commits:** Keep changes surgical and independent.
- **PRs:** Link issues, describe testing performed and any gaps.

## When stuck

- Ask a clarifying question, propose a short plan, or open a draft PR with notes.
