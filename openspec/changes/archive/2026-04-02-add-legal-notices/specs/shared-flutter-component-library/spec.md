## ADDED Requirements

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
