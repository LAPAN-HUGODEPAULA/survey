# shared-flutter-component-library Specification

## Purpose
Define the ownership and reuse rules for shared Flutter UI in `packages/design_system_flutter`.
## Requirements
### Requirement: The platform MUST provide a shared Flutter component library in `packages/design_system_flutter`
The LAPAN platform SHALL maintain reusable cross-app Flutter components in `packages/design_system_flutter` as the canonical package for shared UI composition beyond basic theme primitives.

#### Scenario: A reusable component is needed by multiple Flutter applications
- **WHEN** the same Flutter component or form rule is required in more than one LAPAN app
- **THEN** the canonical implementation MUST live in `packages/design_system_flutter`
- **AND** the shared component API MUST NOT require app-specific routers, repositories, or provider classes to be imported into the package

### Requirement: Survey respondent applications MUST reuse shared respondent-flow components
The applications `survey-frontend` and `survey-patient` SHALL consume shared respondent-flow components for the duplicated survey experience, including async page state, demographic data capture, instruction comprehension, linear question presentation, and survey metadata presentation.

#### Scenario: A survey app renders a duplicated respondent-flow screen
- **WHEN** `survey-frontend` or `survey-patient` renders a demographics, instructions, survey runner, or survey details screen
- **THEN** the screen MUST be composed from shared components exported by `packages/design_system_flutter`
- **AND** the application MAY keep a thin local page wrapper for navigation, repository access, and provider integration

### Requirement: Shared survey-form components MUST preserve common demographic rules
The shared demographics components SHALL centralize the common business rules already duplicated across the survey respondent applications, including required demographic fields, diagnosis multi-select behavior, conditional medication-name entry, and loading of shared reference data such as diagnoses, education levels, and professions.

#### Scenario: A user completes the shared demographics flow
- **WHEN** the user fills the shared demographics fields in a survey respondent application
- **THEN** the same validation and conditional field rules MUST apply in every consuming app
- **AND** the available diagnosis, education, and profession options MUST come from the same shared component contract

### Requirement: Survey-builder MUST reuse shared administrative CRUD components
The `survey-builder` application SHALL consume shared administrative components for repeated catalog and editor patterns, including loading and empty-state shells, create and refresh actions, edit and delete affordances, save and cancel action bars, confirmation dialogs, and standardized key-field validation.

#### Scenario: An administrator manages repeated catalog entities
- **WHEN** an administrator opens a prompt or persona management screen in `survey-builder`
- **THEN** the page MUST render through shared administrative CRUD components from `packages/design_system_flutter`
- **AND** app-specific repository calls and entity-specific field mapping MAY remain in the `survey-builder` app layer

### Requirement: Shared components MUST preserve app-owned orchestration
The shared component library SHALL provide reusable composition without changing application workflow ownership.

#### Scenario: An app integrates a shared component into an existing flow
- **WHEN** a Flutter app adopts a shared component from `packages/design_system_flutter`
- **THEN** the application MUST retain control over route transitions, persisted state, repository writes, and feature-specific side effects
- **AND** the shared component MUST expose callbacks or simple data contracts instead of embedding those app-specific behaviors

### Requirement: The platform MUST document shared Flutter component ownership and usage
The repository SHALL include developer-facing documentation that explains when Flutter UI belongs in `packages/design_system_flutter`, how shared components should be exported, and how applications should compose them safely.

#### Scenario: A developer adds a new reusable Flutter surface
- **WHEN** a contributor identifies a Flutter component that is reused across LAPAN apps
- **THEN** the repository documentation MUST tell them to place the canonical implementation in `packages/design_system_flutter`
- **AND** the documentation MUST describe how to keep app-specific navigation and business logic outside the shared component package

### Requirement: Professional Auth UI MUST Be Shared Through the Flutter Component Library
The canonical professional sign-in, sign-up, and account-menu UI used by `survey-frontend` and `clinical-narrative` MUST live in `packages/design_system_flutter`.

#### Scenario: A professional auth surface is needed in both apps
- **WHEN** `survey-frontend` and `clinical-narrative` need the same professional auth page composition or account-menu affordance
- **THEN** the canonical implementation MUST be owned by `packages/design_system_flutter`
- **AND** the shared component API MUST NOT require app-specific router, provider, or repository classes to be imported into the package

### Requirement: Shared Legal Footer Surface
The canonical legal footer link used by `survey-patient`, `survey-frontend`, `clinical-narrative`, and `survey-builder` MUST live in `packages/design_system_flutter`.

#### Scenario: A Flutter app needs the platform legal footer
- **WHEN** any Survey Flutter app needs to expose the `Termo de Uso e Política de Privacidade`
- **THEN** the canonical footer link widget MUST be provided by `packages/design_system_flutter`
- **AND** the consuming app MAY keep only a thin wrapper for shell placement and navigation wiring

### Requirement: Shared Legal Reader and Acknowledgement Surfaces
The canonical legal document reader and acknowledgement UI used across the Survey apps MUST live in `packages/design_system_flutter`.

#### Scenario: An app renders a full legal document
- **WHEN** `survey-patient`, `survey-frontend`, `clinical-narrative`, or `survey-builder` opens the full `Termo de Uso e Política de Privacidade`
- **THEN** the app MUST render the shared legal reader from `packages/design_system_flutter`
- **AND** the shared component API MUST NOT require app-specific router, provider, or repository classes to be imported into the package

#### Scenario: An app renders the initial-notice acknowledgement gate
- **WHEN** `survey-patient`, `survey-frontend`, or `clinical-narrative` needs to show the `Aviso Inicial de Uso` acknowledgement flow
- **THEN** the app MUST render the shared acknowledgement surface from `packages/design_system_flutter`
- **AND** the consuming app MUST retain ownership of route transitions, local state resets, and backend write orchestration

