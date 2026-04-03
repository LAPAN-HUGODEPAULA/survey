# shared-flutter-scaffold Specification

## ADDED Requirements

### Requirement: The shared Flutter page shell MUST render the canonical dark structure
The shared scaffold contract in `packages/design_system_flutter` SHALL provide the canonical full-screen dark shell for LAPAN Flutter apps, including platform background treatment, header integration, content spacing, and footer/status-bar placement.

#### Scenario: A full-screen Flutter route renders through the shared shell
- **WHEN** a LAPAN Flutter route renders a primary page
- **THEN** the route MUST render through the shared scaffold contract from `packages/design_system_flutter`
- **AND** that shell MUST apply the canonical dark background and surface hierarchy defined by the shared theme instead of app-local scaffold styling

### Requirement: Shared shell composition MUST support consistent headers across apps
The shared scaffold contract SHALL support reusable header composition for the LAPAN Flutter apps so that navigation chrome stays visually consistent while still allowing route-specific actions and callbacks.

#### Scenario: An app needs a page title, navigation action, or account menu
- **WHEN** `survey-patient`, `survey-frontend`, `clinical-narrative`, or `survey-builder` renders a full-screen page header
- **THEN** the header MUST be composed through the shared shell or a shared header primitive from `packages/design_system_flutter`
- **AND** the consuming app MAY continue to provide its own navigation callbacks, menu items, and route decisions

### Requirement: Every production Flutter screen MUST adopt the shared shell
The production screens in `survey-patient`, `survey-frontend`, `clinical-narrative`, and `survey-builder` SHALL adopt the shared scaffold contract or a shared shell derivative so the platform presents a unified visual frame across all Flutter applications.

#### Scenario: A user navigates between LAPAN Flutter applications
- **WHEN** the user opens any production screen in the LAPAN Flutter apps
- **THEN** the screen MUST inherit the shared shell structure, footer treatment, and baseline spacing behavior from `packages/design_system_flutter`
- **AND** screen-specific workflow content MAY vary without changing the canonical shell styling
