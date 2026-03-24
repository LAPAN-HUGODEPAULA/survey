# shared-flutter-scaffold Specification

## ADDED Requirements
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
