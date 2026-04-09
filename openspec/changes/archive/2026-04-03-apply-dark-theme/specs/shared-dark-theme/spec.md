# shared-dark-theme Specification

## ADDED Requirements

### Requirement: The platform MUST provide a canonical LAPAN dark Flutter theme
The LAPAN platform SHALL define a canonical Flutter dark theme in `packages/design_system_flutter` that implements the visual system described in `docs/lapan-design/lapan-design.md`, including the amber-driven palette, deep charcoal surfaces, tonal layering, and shared interaction states.

#### Scenario: A Flutter application boots with the platform theme
- **WHEN** `survey-patient`, `survey-frontend`, `clinical-narrative`, or `survey-builder` initializes its root `MaterialApp`
- **THEN** the application MUST use the canonical dark theme exported by `packages/design_system_flutter`
- **AND** the app MUST NOT define a separate app-local theme that overrides the shared palette or base component styling

### Requirement: Shared theme tokens MUST encode the LAPAN visual language
The shared theme SHALL expose reusable tokens or theme extensions for the LAPAN color palette, gradients, surface hierarchy, outlines, and state treatments so shared and app-level widgets can render consistently without hardcoded color values.

#### Scenario: A shared or app-owned widget needs brand styling
- **WHEN** a Flutter widget needs a platform color, gradient, or surface tone
- **THEN** it MUST resolve that value from the shared LAPAN theme contract in `packages/design_system_flutter`
- **AND** it MUST NOT hardcode legacy light-theme colors or standalone brand colors in the consuming app

### Requirement: Shared typography MUST use the platform type system
The Flutter design system SHALL provide the canonical typography for platform apps using Manrope-based text styles and role-appropriate emphasis for display, headline, body, and label usage.

#### Scenario: A screen renders text in a LAPAN Flutter app
- **WHEN** a screen renders titles, metrics, body copy, captions, or labels
- **THEN** it MUST use the shared typography styles from the canonical theme
- **AND** technical labels and metadata MUST remain visually distinct from long-form body content

### Requirement: Shared component styling MUST respect tonal layering and no-line rules
The Flutter design system SHALL express hierarchy through tonal surfaces, spacing, and approved outline treatments rather than opaque section borders or legacy elevated cards.

#### Scenario: A screen renders grouped content or floating UI
- **WHEN** a Flutter screen renders cards, panels, sections, dialogs, popovers, or grouped rows
- **THEN** those surfaces MUST use the shared tonal layering system from the canonical theme
- **AND** the implementation MUST avoid using full-opacity borders as the primary separation mechanism except where an accessibility-specific outline variant is required

### Requirement: The canonical dark theme MUST preserve accessibility expectations
The LAPAN dark theme SHALL preserve readable contrast, visible focus states, and comfortable text/background combinations suitable for the platform accessibility constraints, including the ocular comfort goals described in the design documentation.

#### Scenario: A user navigates an interactive dark-theme screen
- **WHEN** the user focuses, hovers, activates, or validates an interactive control
- **THEN** the control MUST expose a visible shared state treatment defined by the canonical theme
- **AND** the screen MUST avoid pure black-on-white or white-on-black extremes that conflict with the documented accessibility guidance
