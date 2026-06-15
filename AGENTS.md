# LAPAN Survey Platform — Repository & Agent Guidelines

This document serves as the master guidelines and development handbook for the **LAPAN Survey Platform** ecosystem. It is the single source of truth for all developers and AI agent assistants (including Antigravity, Claude Code, Google Gemini, and OpenAI Codex).

---

## 1. Project Overview & Context

### Project Overview
The **LAPAN Survey Platform** is a comprehensive healthcare application designed to assess visual hypersensitivity in neurodevelopmental disorders (NDDs) in Brazil. It digitizes and validates the Brazilian Portuguese version of the Cardiff Hypersensitivity Scale (CHYPS-Br).

The platform uses a microservices architecture with a Python/FastAPI backend, MongoDB, and multiple Flutter web frontends. It features an AI-powered multi-agent system for clinical narrative generation and documentation.

### Project Evolution & Milestones
*   **Initial Phase (Jan 2026):** Implemented public patient screening flows.
*   **Professional Workflows (Feb 2026):** Added screener registration and administrative survey building capabilities.
*   **Clinical Documentation (Mar 2026):** 
    *   Launched the `clinical-narrative` application with AI-driven conversation engine.
    *   Implemented voice capture and hybrid transcription system.
    *   Added centralized template management and clinical document generation.
    *   Standardized shared design system, scaffolds, and security/privacy controls.
*   **Survey Prompts & Schema Stabilization (Mar 2026):**
    *   Refactored survey associations to use centralized reusable prompts.
    *   Stabilized response processing and collection naming (`survey_responses`, `patient_responses`).
    *   Implemented systematic migration framework for database consistency.
    *   Launched version `0.1.0` following Semantic Versioning (tracked in root `VERSION` file).
*   **Multi-Agent Architecture & Professional Core (Mar 2026):**
    *   Adopted a 4-stage LangGraph state graph (ContextLoader → ClinicalAnalyzer → PersonaWriter → ReflectorNode) for clinical report generation.
    *   Introduced composable prompt architecture (Domain + Persona + Context layers).
    *   Implemented reflection cycles for hallucination mitigation and clinical safety.
    *   Stored Agent Skills (Personas) in MongoDB for CMS-style management via `survey-builder`.
    *   **Shared Screener Auth:** Unified authentication across all professional applications.
    *   **Shared Component Library:** Launched `packages/design_system_flutter` for UI consistency.
*   **Autonomous Development & OpenSpec (Apr 2026):**
    *   Adoption of the **OpenSpec** workflow for change management and design-first development.
    *   Integration of specialized agent skills for exploration, proposal, and implementation.
*   **UX/UI Standardization & Clinical Safety (Apr 2026):**
    *   Executed a comprehensive UI/UX overhaul focusing on cognitive load reduction in `survey-builder`.
    *   Standardized feedback messaging, severity icons, and form validation patterns across all applications.
    *   Implemented high-visibility AI waiting states and conversational status indicators for Clinical AI.
    *   Integrated an Emotional Design layer to improve clinical user experience and patient trust.
    *   Added comprehensive platform-wide legal notices and a system-wide Dark Theme.
*   **Administrative Governance & Agent Lifecycle (Apr 2026 - Ongoing):**
    *   Transitioning clinical prompt resolution to a centralized Mongo-first model managed via `survey-builder`.
    *   Implementing dedicated administrative access control and audit trails for prompt governance.
    *   Centralizing Agent Access Points to decouple clinical AI configuration from external dependencies.

### Domain Context
*   **`Screener`**: Authorized healthcare professional (doctor, psychologist) with professional council registration.
*   **`Patient`**: Individual undergoing assessment. Public screening is anonymous; professional assessments use unique identifiers.
*   **`Questionnaire` / `Survey`**: Definitions and instances of structured assessments.
*   **`Narrative`**: Free-text or voice-captured clinical interview transformed by AI into medical records.

---

## 2. System Architecture & Components

### Monorepo Structure
*   **`apps/`**: Flutter web applications using shared design system.
    *   `survey-patient`: A public-facing screening tool (7 questions) for preliminary assessment. Compliant with WCAG 2.1 Level AA.
    *   `survey-frontend`: A professional platform for authorized screeners to administer full assessments (CHYPS-Br), manage patient records, and generate formal reports.
    *   `clinical-narrative`: A conversational documentation tool that transforms clinician-patient interactions into structured medical records using AI. Features voice capture and hybrid transcription.
    *   `survey-builder`: A secure administrative tool for managing questionnaires, reusable clinical prompts (Persona Skills), and Agent Access Points. Features dedicated admin authentication and persistent audit logging for clinical governance.
*   **`services/`**: Python FastAPI backend and workers.
    *   `survey-backend`: Main API with MongoDB repositories, JWT auth, and modular routes. Backend lives in `services/survey-backend/app`, with persistence in `app/persistence/**` and domain models in `app/domain/models`.
    *   `survey-worker`: Background processor for response enrichment.
    *   `clinical-writer-api`: LLM-based clinical narrative generation using LangGraph state graph.
*   **`packages/`**: Shared packages.
    *   `contracts`: OpenAPI spec with generated Python/Dart SDKs (`survey-backend.openapi.yaml` and `generated/dart/`).
    *   `design_system_flutter`: Shared Flutter design system package for theming and reusable UI patterns.
    *   `shared_python`: Common Python utilities.
*   **`tools/`**: Tooling, CI scripts, and database migrations.
*   **`docs/`**: Platform documentation.
*   **`openspec/`**: OpenSpec specifications and changes.

### Multi-Agent Architecture
The Clinical Writer AI service (`services/clinical-writer-api`) uses a **4-stage LangGraph state graph** that separates clinical interpretation from narrative generation and applies reflection-based safety validation. It exposes `/process` with JSON-only `ReportDocument` output.

#### 4-Stage Orchestration Graph
1.  **ContextLoader** — Retrieves questionnaire interpretation prompts and persona skills from MongoDB.
2.  **ClinicalAnalyzer** — Processes response JSON with clinical rules; outputs structured clinical facts (no narrative).
3.  **PersonaWriter** — Transforms clinical facts into audience-appropriate Markdown narrative.
4.  **ReflectorNode** — Validates grounding, tone, and safety; loops back to writing on failure (up to 2 retries) to mitigate hallucinations.

#### Composable Prompt Layers
*   **Interpretation Layer (Domain):** Questionnaire-specific clinical rules from `QuestionnairePrompts` MongoDB collection.
*   **Persona Layer (Profile):** Tone, vocabulary, and output format from `PersonaSkills` MongoDB collection.
*   **Contextual Data Layer:** Pseudonymized patient response JSON.

### Survey Prompt Management & Agent Routing
The platform features a centralized system for managing clinical AI prompts and agent behavior:
*   **Reusable Prompts**: Prompts are stored in the `survey_prompts` collection and can be shared across multiple clinical contexts.
*   **Agent Access Points**: High-level configuration entries that map specific entry points (keys) to a combination of Questionnaire Prompts, Persona Skills, and Output Profiles.
*   **Mongo-First Resolution**: The system has transitioned from hardcoded or external prompt resolution to a dynamic, builder-managed model where `survey-builder` acts as the source of truth.
*   **Access-Point Keys**: Applications (`survey-patient`, `survey-frontend`) reference stable `accessPointKey` identifiers, allowing administrators to update underlying AI logic without code changes.
*   **Management UI**: The `survey-builder` application provides a dedicated interface for CRUD operations on these reusable prompts, Persona Skills, and Agent Access Points.

### Database Schema & Migrations
The project uses MongoDB with a systematic migration framework.
*   **Collections**:
    *   `surveys`: Definitions of clinical questionnaires.
    *   `survey_prompts`: Reusable AI instructions for clinical narrative generation.
    *   `questionnaire_prompts`: Questionnaire-specific clinical interpretation logic (Domain layer).
    *   `persona_skills`: Output persona definitions with tone, format, and safety constraints (Persona layer).
    *   `agent_access_points`: Runtime configuration mapping keys to specific prompt and persona combinations.
    *   `survey_responses`: Records of professional assessments.
    *   `patient_responses`: Records of public screenings (pseudonymized).
    *   `screeners`: Registered healthcare professionals.
    *   `survey_builder_audit_logs`: Persistent audit trail for administrative actions in `survey-builder`.
    *   `clinical_writer_run_logs`: Audit logs for AI processing tasks.
*   **Migrations**: Found in `tools/migrations/survey-backend/`, these scripts ensure schema consistency.

---

## 3. Architecture & Design Principles

### Core Architectural Guidelines
1.  **Separation of Concerns**: Isolate UI, business logic, and data access into distinct layers.
2.  **DRY Principle**: Extract shared logic into reusable packages or common utility modules.
3.  **SOLID Principles**: Code to abstractions; enforce single responsibilities.
4.  **Clean Architecture Boundaries**: Enforce dependencies pointing inwards (Presentation → Business/Domain → Data), with no cross-layer shortcuts.
5.  **Microservices Boundaries**: Services must own their data models and interact via clean APIs.
6.  **Event-Driven Patterns**: Decouple intensive background processing using event workers.
7.  **Domain-Driven Design (DDD)**: Use bounded contexts and a ubiquitous domain language.
8.  **API-First**: Treat OpenAPI contracts as the source of truth. Update contracts first, then generate SDKs or mocks.
9.  **Cloud-Native**: Design stateless, container-ready services with robust health endpoints.

### Key Architecture Patterns
*   **Repository Pattern**: MongoDB access is strictly abstracted via repositories. Only `app/persistence/**` may import `pymongo` directly. Routers must use dependency-injected repositories from `app.persistence.deps`.
*   **Contract-First Development**: All client-server communication is driven by the OpenAPI specification.
*   **UI/UX Consistency**: Full-screen Flutter pages must utilize `DsScaffold` from `design_system_flutter`. The shared theme uses `Colors.orange` as the seed color.

---

## 4. Development Environment & Commands

### Project Tooling
*   **Python Package Manager**: The project uses `uv` to manage the virtual environment, workspace dependencies, and command execution.
*   **Virtual Environment**: The project virtual environment lives in `.venv`.
*   **Dev Servers**: Dev workflows utilize `npm run` scripts and `docker compose` to run components locally.

### Version Management
*   Sync version across managed files: `npm run version:sync`
*   Check version consistency: `npm run version:check`
*   Prepare for release: `npm run release:prepare`

### Backend Development Commands
*   **Local Run (Uvicorn):**
    ```bash
    uv run uvicorn app.main:app --reload --app-dir services/survey-backend/app
    ```
*   **Docker Compose up (local core stack):**
    ```bash
    # Starts mongodb, survey-backend, survey-frontend, survey-patient, clinical-narrative, survey-builder, and survey-worker
    docker compose up -d mongodb survey-backend survey-frontend survey-patient clinical-narrative survey-builder survey-worker
    ```
    Or via tool script:
    ```bash
    ./tools/scripts/compose_local.sh up -d mongodb survey-backend survey-frontend survey-patient clinical-narrative survey-builder survey-worker
    ```
*   **Docker Compose up (Clinical Writer API):**
    ```bash
    docker compose -f services/clinical-writer-api/docker-compose.yml up -d
    ```
    Or via tool script:
    ```bash
    ./tools/scripts/compose_local.sh up -d clinical-writer-api
    ```
*   **Dependency Management:**
    *   Add dependency: `uv add <package>`
    *   Add dev dependency: `uv add -D <package>`
    *   Sync dependencies: `uv sync`
    *   Run env command: `uv run <command>`
*   **Backend Compile Check:**
    ```bash
    uv run python -m compileall services/survey-backend/app
    ```
*   **API Client Generation:**
    ```bash
    tools/scripts/generate_clients.sh
    ```

### Flutter Development Commands
Run these from the respective app directory or using repository root npm scripts:
*   **Survey Frontend (Screener):** `npm run dev:survey-frontend` (Port 8080)
*   **Patient App:** `npm run dev:survey-patient` (Port 8081)
*   **Clinical Narrative:** `npm run dev:clinical-narrative` (Port 8082)
*   **Survey Builder:** `npm run dev:survey-builder` (Port 8083)
*   **Flutter Setup:** Run `flutter pub get` and `flutter analyze` from each affected app directory under `apps/` or package directory under `packages/`.
*   **Flutter Web Build:** Run `flutter build web` inside the specific app directory when deploying.

### Runtime Configuration
*   **Configuration Source-of-Truth:** `config/runtime/config.private.json`
*   **Generate Runtime Config Artifacts:**
    ```bash
    python3 tools/scripts/render_runtime_config.py
    ```
*   **Scaffold from Example:**
    ```bash
    cp config/runtime/config.private.example.json config/runtime/config.private.json
    ```

### Linting, Validation & Testing
*   **FastAPI Backend Linting:**
    ```bash
    pylint --disable=C services/survey-backend/app/**/*.py
    ```
*   **Clinical Writer API Linting:**
    ```bash
    pylint --disable=C services/clinical-writer-api/clinical_writer_agent/**/*.py
    ```
*   **Flutter Linting:** Run `flutter analyze` in the target app directory.
*   **Markdown Linting:**
    ```bash
    markdownlint docs/**/*.md --fix
    ```
*   **Backend Testing:** Run `pytest` inside `services/survey-backend`.
*   **Flutter Testing:** Run `flutter test` inside the respective app's directory (e.g., `apps/survey-patient`).

---

## 5. Development Conventions & Standards

### Mandatory Documentation & Localization Rules
*   **Legal Documents:** **NEVER** modify files under `docs/legal/**`. Only legal staff is authorized to change these documents.
*   **Naming:** Use "**LAPAN Survey Platform**" as the official name for the whole ecosystem. In Portuguese documentation, use "**Plataforma LAPAN Survey**".
*   **Localization:** All application UI and code comments **MUST** be in Brazilian Portuguese (pt-BR). Exception: Guidelines and structural documentation may be written in English.

### Coding Style & Naming Conventions
*   **Python:** Follow PEP 8 style guides. Avoid runtime imports from legacy folders.
*   **Dart/Flutter:** Prefer a feature-first structure (`app/`, `features/<feature>/data|domain|presentation`, `shared/`). Use the shared design system.
*   **Filenames:** Use `snake_case` for Python modules, `lower_snake_case` for Dart files, and `PascalCase` for classes and types.

### Commenting Standards
*   Write comments and docstrings in English.
*   Explain intent, invariants, edge cases, and non-obvious behavior rather than repeating code actions.
*   **Documentation Formats:**
    *   Python: PEP 257 triple-double-quote (`"""`) docstrings.
    *   Dart: Triple-slash (`///`) doc comments for libraries, public types, and members.
    *   Java: Standard Javadoc (`/** ... */`) for handwritten Java.
*   Remove legacy annotations (e.g., `Added`, `Changed`, patch notes). Focus purely on intent.
*   Add author tags only when explicitly required; use `Hugo de Paula`.

### Git Workflow & Commits
*   **Branching:** Never push directly to `main`. Always work on a feature/bug branch and open a Pull Request.
*   **Conventional Commits:** Format commit messages as `{type}({scope}): {:emoji:} {Message}` using:
    *   `feat(scope): ✨ add ...`
    *   `fix(scope): 🐛 fix ...`
    *   `chore(scope): 🧹 update ...`
    *   `docs(scope): 📝 document ...`
    *   `test(scope): ✅ add tests ...`
    *   `ops(scope): 🚀 deploy ...`
    *   `refactor(scope): ♻️ refactor ...`
*   **Granularity:** Keep commits small, surgical, and trunk-friendly. Avoid mixing backend, contract, and Flutter modifications in a single commit unless they are strictly coupled.

---

## 6. Security, Privacy & Review Guidelines

### Security & Configuration Tips
*   **Secrets Management:** Never hardcode secrets. Clinical Writer and email integrations are environment-driven in `app/config/settings.py`. Configure MongoDB connection using `MONGO_URI` and `MONGO_DB_NAME`.
*   **LGPD Compliance:** Enforce strict pseudonymization of patient data, encrypt sensitive PII, and maintain secure audit logging.
*   **Logging:** Avoid logging secrets, raw tokens, or sensitive patient/clinical payloads.
*   **Prompt Governance:** `PromptRegistry` uses Google Drive `modifiedTime` as `prompt_version`; do not embed prompt content in MongoDB.

### Review Guidelines
*   **FastAPI Backend:** Check that routers only use dependency-injected repositories. Verify that no raw `pymongo` imports leak outside `app/persistence/**`. Check contracts against OpenAPI specs.
*   **Flutter Apps:** Flag any components bypassing `design_system_flutter` without explicit justification. Watch for async lifecycle issues and null safety.
*   **Contracts:** Re-run contract generation scripts and confirm that any changes in request/response models are correctly reflected in the OpenAPI yaml definition.

### When Stuck
*   Ask a clarifying question if a requirement is ambiguous.
*   Propose a short plan before making broad or risky changes.
*   If work is partially complete, summarize blockers clearly before opening or updating a draft PR.
