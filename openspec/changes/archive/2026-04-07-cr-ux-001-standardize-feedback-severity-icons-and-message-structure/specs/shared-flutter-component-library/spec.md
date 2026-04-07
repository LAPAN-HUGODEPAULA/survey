## ADDED Requirements

### Requirement: Shared feedback primitives MUST live in `packages/design_system_flutter`
The canonical Flutter primitives for rendering structured user-facing feedback MUST live in `packages/design_system_flutter` so the LAPAN apps do not maintain parallel message systems.

#### Scenario: More than one app needs the same feedback pattern
- **WHEN** two or more LAPAN Flutter apps need the same inline message, banner, summary, or toast content pattern
- **THEN** the canonical implementation MUST be provided by `packages/design_system_flutter`
- **AND** consuming apps MUST keep ownership of routing, repository calls, and feature-specific side effects through simple callbacks or message data contracts

### Requirement: Shared feedback primitives MUST cover the main message containers
The shared Flutter component library MUST provide canonical primitives for the main feedback containers used by the LAPAN apps.

#### Scenario: An app needs context-appropriate feedback rendering
- **WHEN** a Flutter app needs to render field-level, section-level, page-level, or transient user-facing feedback
- **THEN** the shared package MUST provide reusable primitives for inline messages, persistent banners, validation summaries, and transient toast or snackbar content
- **AND** the app MUST NOT need to invent a second feedback component family for the same responsibilities
