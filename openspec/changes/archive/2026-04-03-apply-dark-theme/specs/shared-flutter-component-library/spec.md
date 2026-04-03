# shared-flutter-component-library Specification

## ADDED Requirements

### Requirement: Shared visual primitives MUST live in `packages/design_system_flutter`
The LAPAN platform SHALL provide the canonical visual primitives for the shared dark design language in `packages/design_system_flutter`, including reusable navigation bars, section containers, tonal panels, focus frames, action groups, form-field chrome, and standardized empty, loading, and error states.

#### Scenario: Multiple Flutter apps need the same visual structure
- **WHEN** the same page region, panel pattern, or visual state appears in more than one LAPAN Flutter app
- **THEN** the canonical implementation MUST live in `packages/design_system_flutter`
- **AND** consuming apps MAY keep only thin wrappers for routing, providers, repository calls, and app-specific callbacks

### Requirement: Common app-local visual wrappers MUST be replaced by shared components
The Flutter applications `survey-patient`, `survey-frontend`, `clinical-narrative`, and `survey-builder` SHALL replace duplicated local visual wrappers with shared components when the behavior is presentation-only and already covered by the shared package.

#### Scenario: An app owns a duplicated presentation wrapper
- **WHEN** an application contains a duplicated page wrapper, navigation app bar, or shared-state widget whose responsibility is visual composition
- **THEN** that wrapper MUST be migrated to the canonical shared component library or removed in favor of an existing shared primitive
- **AND** app-specific business logic MUST remain outside the shared package

### Requirement: Shared primitives MUST support specialized app surfaces without forking the theme
The shared component library SHALL provide reusable variants or slots for specialized surfaces such as respondent flows, professional auth, clinical chat, reports, and administrative CRUD screens so apps can stay visually consistent without defining parallel component systems.

#### Scenario: A feature screen has specialized content but shared visual rules
- **WHEN** a Flutter app renders a domain-specific screen such as a chat surface, report panel, survey step, or admin editor
- **THEN** the screen MUST compose from shared primitives or approved shared feature components in `packages/design_system_flutter`
- **AND** the app MUST NOT introduce a second visual language that bypasses the shared dark-theme primitives
