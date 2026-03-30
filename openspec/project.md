# Project Context

## Purpose

This project, the LAPAN Survey Platform, is a comprehensive healthcare application designed to address the lack of validated tools for assessing visual hypersensitivity in neurodevelopmental disorders (NDDs) within the Brazilian context. It aims to digitize and validate the Brazilian Portuguese version of the Cardiff Hypersensitivity Scale (CHYPS-Br).

The platform serves three primary goals:

1. **Enable early screening** for the general public to identify visual hypersensitivity symptoms.
2. **Support clinical assessment** by providing validated tools for healthcare professionals.
3. **Streamline clinical documentation** by using an AI-powered multi-agent system to transform clinical interactions into structured medical records.

## Key Architectural Principles

- **Application Architecture:** Microservices
- **Data Storage:** MongoDB
- **Tech Stack:** Python 3.13 (backend), Flutter for Web (frontend), Docker (containerization)
- **Localization:** All application UI must be in Brazilian Portuguese.

## Architectural Guidelines

When generating code, strictly adhere to the following architectural best practices:

1. **Enforce Separation of Concerns**: Isolate UI, business logic, and data access into distinct modules or layers.
2. **Apply the DRY principle**: Eliminate duplication by extracting shared logic into reusable functions, services, or utilities—avoid copy-paste.
3. **Follow SOLID principles**: Ensure classes have a single responsibility, depend on abstractions, and are open for extension but closed for modification.
4. **Structure code using Layered Architecture**: Enforce unidirectional dependencies (Presentation → Business → Data), with no cross-layer calls.
5. **Design for Microservices when appropriate**: Each service must own its data, expose a well-defined API, and be independently deployable.
6. **Prefer Event-Driven patterns for decoupled workflows**: Use message brokers and ensure idempotent event handlers.
7. **Model core logic using Domain-Driven Design**: Define Bounded Contexts, Aggregates, and a Ubiquitous Language; keep domain logic pure and framework-free.
8. **Adopt an API-First approach**: Define OpenAPI/AsyncAPI contracts before implementation; generate mocks, docs, and SDKs from specs.
9. **Build Cloud-Native, container-ready services**: Stateless, scalable, with health checks, and managed via Infrastructure-as-Code.
10. **Implement Clean Architecture**: Place business rules at the core; all dependencies must point inward; use Dependency Injection and interface adapters.

Always prioritize loose coupling, testability, and maintainability over premature optimization.

## Tech Stack

- **Backend:** Python 3.13/FastAPI (`survey-backend`, `survey-worker`)
- **AI Service:** Python 3.13/FastAPI with LangGraph (`clinical-writer-api`)
- **Frontend:** Flutter for Web (`survey-frontend`, `survey-patient`, `clinical-narrative`)
- **Database:** MongoDB, responsible for storing:
  - Patient assessment results and screening data
  - Screener professional credentials and access permissions
  - Medical record templates and report structures
  - AI processing logs and quality control metrics
  - Pseudonymized research data
- **API Specification:** OpenAPI
- **Containerization:** The backend is developed in Python, and all services (including frontends) are containerized using Docker and Docker Compose.

## Domain Context

### Business Domain Knowledge

- **`Screener`:** A healthcare professional (e.g., doctor, psychologist) authorized to administer apply validated questionnaires and generate medical reports. This user type must register with their professional council number and must log in.
- **`Patient`:** An individual undergoing screening or assessment for visual hypersensitivity symptoms. Patients may use the public screening tool without identification or be registered by a screener for professional assessments.
- **`Questionnaire`:** A structured set of questions designed to evaluate visual hypersensitivity symptoms.
- **`Survey`:** An instance of a questionnaire completed by a patient, resulting in a set of responses and a generated report. A survey may contain Patient metadata and medical history.
- **`Narrative`:** A free-text clinical interview or consultation conducted by a screener, which can be transformed into a structured medical record using AI.

### Application Components

The system consists of four interconnected web applications:

- **`survey-patient`:** A public-facing, 7-question screening tool for preliminary assessment. It requires no patient identification and generates a simplified summary to encourage professional follow-up.
- **`survey-frontend`:** A professional-facing platform for qualified screeners (e.g., doctors, psychologists) to administer validated questionnaires like the 20-item CHYPS-Br, manage patient records, and generate formal medical reports.
- **`clinical-narrative`:** A conversational documentation tool that transforms clinician-patient interactions into structured medical records. It is a complete clinical transcription and documentation platform with a conversational interface and integrated workflow.
  - **Conversational Platform**: The application is structured as a conversational platform with sessions, history, and clinical context.
  - **Voice Capture**: It has voice capture with hybrid transcription (browser preview + final server processing).
  - **Clinical Assistance**: It includes clinical assistance with suggestions and gap detection.
  - **Document Generation**: It can generate multiple clinical document types and allow export/printing.
  - **Template Management**: It has a centralized template management system with versioning and approvals.
- **`survey-builder`:** A dedicated application for administrators or researchers to create, view, update, and delete surveys directly within the LAPAN Survey Platform ecosystem.
  - **Full Survey Editing**: It allows editing of all survey fields, including instructions and questions.
  - **Validation**: It enforces that a survey must contain at least one question and each question must have at least one answer.
  - **Consistent UI/UX**: It leverages the existing design system to ensure UI/UX consistency with other platform applications.

### Clinical Writer AI Multi-Agent System

A centralized AI engine built on a **4-stage LangGraph state graph** that separates clinical interpretation from narrative generation and applies reflection-based safety validation. See [multiagent-architecture.md](file:///home/hugo/Documents/LAPAN/dev/survey/docs/multiagent-architecture.md) for the full architectural rationale.

#### 4-Stage Orchestration Graph

| Stage | Node | Responsibility |
|:---|:---|:---|
| **1. Context** | `ContextLoader` | Retrieves the questionnaire's `interpretation_prompt` and the target persona skill from MongoDB |
| **2. Analysis** | `ClinicalAnalyzer` | Processes response JSON applying only clinical rules (e.g., CHYPS scoring); outputs structured clinical facts — no narrative text |
| **3. Writing** | `PersonaWriter` | Transforms clinical facts into a Markdown narrative following the persona's tone and format guidelines |
| **4. Critique** | `ReflectorNode` | Validates tone adequacy, checks for invasive recommendations, and verifies grounding in questionnaire data. Returns **PASS** (end) or **FAIL** (loop back to Writing, up to 2 retries) |

#### Composable Prompt Architecture

Prompts are assembled at runtime from three independent layers:
- **Interpretation Layer (Domain):** Questionnaire-specific clinical rules stored in `QuestionnairePrompts` collection.
- **Persona Layer (Profile):** Tone, vocabulary, and output format stored in `PersonaSkills` collection.
- **Contextual Data Layer:** Pseudonymized patient response JSON.

This separation ensures that updating a school persona affects all questionnaires without code changes.

#### Key Architectural Decisions

- **Skills in MongoDB:** Agent Skills (Personas) are stored as MongoDB documents so the `survey-builder` acts as a clinical CMS — specialists version prompts without deployments.
- **Reflection Cycles:** A dedicated critique node mitigates hallucinations by verifying every report assertion against the raw questionnaire data.
- **Asymmetric Model Usage:** Lightweight models for stages 1–3; high-reasoning models only for the Reflection Node to optimize cost.
- **API-Only Inference:** The system uses third-party LLM APIs exclusively; self-hosted model infrastructure (e.g., LoRA adapters, GPU serving) was evaluated and deferred.

## Security and Privacy

The platform has a strong focus on security and privacy, with platform-wide access control, encryption, and audit logging. All services and applications are designed to be compliant with LGPD.

- **Access Control**: Platform-wide access control and session security.
- **Encryption**: Encryption at rest and in transit with centralized key management expectations.
- **Audit Logging**: Audit logging and security monitoring requirements.
- **Data Lifecycle**: Data lifecycle and deletion workflows without fixed retention periods.

## Project Conventions

### Code Style & Localization

- **Language:** All user-facing UI in the frontend applications must be developed in Brazilian Portuguese (pt-BR).
- **Comments & Docs:** All internal documentation and code comments should be written in Brazilian Portuguese.
- **Formatting:** Adhere to standard Python (PEP 8) and Dart/Flutter style guides.
- **Type Hinting:** Use Type Annotations for all Python function and method definitions. For complex type signatures, define an alias for clarity.

### Architecture Patterns

- **Service-Oriented Architecture:** The system is composed of distinct backend, frontend, and worker microservices.
- **Repository Pattern:** The backend uses the repository pattern to abstract database interactions with MongoDB.
- **Data Contract Pattern:** All data interacting with MongoDB **must** first pass through a Pydantic BaseModel definition, serving as the contract for data shape and types. Use these models for input validation in APIs (like FastAPI) and for data serialization/deserialization.
- **Shared & Consistent UI:** All Flutter applications (`survey-frontend`, `survey-patient`, `clinical-narrative`) **must** share the same theme, UI principles, and core components from the `packages/design_system_flutter` package to ensure a consistent user experience.
- **Feature-First Structure:** Flutter apps follow a feature-first directory organization.

### Git Workflow

- **Commits:** Use the Conventional Commits specification. The format is `{type}({scope}): {:emoji:} {Message}`. E. g.:
  - `feat({scope}): ✨ ...`,
  - `fix({scope}): 🐛 ...`,
  - `chore({scope}): 🧹 ...`.
  - `docs({scope}): 📝 ...`
  - `test({scope}): ✅ ...`
  - `ops({scope}): 🚀 ...`
  - `refactor({scope}): ♻️ ...`
- **Branching:** Keep commits small and trunk-friendly. Avoid mixing backend, contracts, and Flutter changes in one commit when possible.
- **Pull Requests:** Pull requests should describe scope, testing performed (commands run), and any known gaps; link issues when relevant.

## Important Constraints

- **Accessibility:** The `survey-patient` application must comply with WCAG 2.1 Level AA standards.
- **Professional Validation:** The `survey-frontend` app must manage screener credentials and require professional registration numbers from recognized councils.
- **Environment:** The entire application stack is designed to be run via Docker Compose. A `.env` file must be configured at the project root.

## External Dependencies

- **Docker/Docker Compose:** Required for the development and production environment.
- **Google Drive:** Used for storing and managing prompts for the AI Clinical Writer service.

## Future Requirements (Roadmap)

- **Data Security & Compliance:** Implement an LGPD compliance framework (end-to-end encryption, audit trails) and enhanced, multi-factor authentication for professionals.
- **Clinical Safety:** Implement a human-in-the-loop review workflow for all AI-generated reports and an automated validation pipeline to check for AI hallucinations.
- **User Experience:** Add voice interaction (text-to-speech/speech-to-text), adaptive interfaces for different age groups, and an offline mode for questionnaires.
- **Workflow Integration:** Enable secure data sharing between the applications and develop a longitudinal analytics dashboard for clinicians.
- **Scalability:** Implement a load-balancing architecture and intelligent caching strategies.
