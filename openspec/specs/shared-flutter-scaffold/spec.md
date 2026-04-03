# shared-flutter-scaffold Specification

## Purpose
TBD - created by archiving change refactor-shared-flutter-scaffold. Update Purpose after archive.
## Requirements
### Requirement: The platform MUST provide a shared Flutter page-shell abstraction.
The LAPAN Survey Platform SHALL provide a shared Flutter scaffold contract in `packages/design_system_flutter` for full-screen application pages.

#### Scenario: Shared scaffold contract is defined
- **Given** the platform maintains multiple Flutter applications
- **When** a full-screen page shell is needed
- **Then** the canonical scaffold abstraction MUST live in `packages/design_system_flutter`
- **And** it MUST standardize the full-screen shell structure around app bar rendering, page body rendering, and the shared footer/status bar
- **And** it MUST NOT require app-specific routing or business logic to be moved into the design system

### Requirement: LAPAN Flutter applications MUST adopt the shared scaffold contract.
The applications `survey-frontend`, `survey-patient`, `survey-builder`, and `clinical-narrative` SHALL use the shared scaffold contract for their full-screen pages.

#### Scenario: User opens a full-screen route in any LAPAN Flutter application
- **Given** the user opens a full-screen route in `survey-frontend`, `survey-patient`, `survey-builder`, or `clinical-narrative`
- **When** the route renders its primary page shell
- **Then** that page MUST render through the shared scaffold contract from `packages/design_system_flutter`
- **And** that shared scaffold contract MUST include the shared footer/status bar as part of the canonical shell
- **And** the application MAY still provide its own route configuration, app-bar widget, and workflow-specific child content

### Requirement: The shared scaffold migration MUST preserve app-specific workflows.
The shared scaffold refactor SHALL standardize layout composition without changing the intended workflow behavior of each application.

#### Scenario: App-specific flows continue to operate after scaffold migration
- **Given** an application-specific flow such as screener navigation, patient screening, survey editing, or clinical conversation
- **When** the page shell is migrated to the shared scaffold contract
- **Then** the flow MUST preserve its existing route structure and app-specific interaction model
- **And** the refactor MUST limit behavior changes to layout-shell standardization unless a separate approved change defines additional UI behavior changes

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
