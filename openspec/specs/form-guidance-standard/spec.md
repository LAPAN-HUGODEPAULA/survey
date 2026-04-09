# form-guidance-standard Specification

## Purpose
TBD - created by archiving change cr-ux-003-form-standardization. Update Purpose after archive.

## Requirements
### Requirement: Shared Grouping and Summary Components
Long forms or those distributed across sections MUST reuse standardized shared components for grouping and summary, rather than creating a second parallel family of widgets.

#### Scenario: Render validation summary
- **WHEN** the user attempts to submit a form with multiple errors
- **THEN** the system SHALL display the canonical form summary at the top of the page or section

### Requirement: Shared Input Formatters and Constraints
Fields with structured formats (ID, Phone, ZIP, Date) MUST use shared formatters, constraints, and normalization in the design system.

#### Scenario: Date field input
- **WHEN** a user types in a date field
- **THEN** the system SHALL guide and format the input according to the `DD/MM/YYYY` pattern

#### Scenario: ZIP code normalization
- **WHEN** a user enters a ZIP code
- **THEN** the system SHALL restrict and normalize the input according to the shared helper defined for this type

### Requirement: Brazilian Portuguese Language and Grammar
All textual content presented to the user, including field labels, error messages, help texts, and warnings, MUST be in Brazilian Portuguese following grammatical norms strictly, including the correct use of accentuation (e.g., "atenção", not "atencao").

#### Scenario: Display success message
- **WHEN** the system shows a confirmation message in pt-BR
- **THEN** the text MUST contain all accents and special characters (cedilla, tilde) according to pt-BR formal standards.

### Requirement: Clear Mandatory Marking and Group Headers
Mandatory fields MUST be clearly marked with an asterisk (*) and related field groups MUST have descriptive headers.

### Requirement: Draft State and Progress Restoration
Long administrative forms MUST expose visible draft states and restore progress when it avoids relevant rework.

#### Scenario: Restore draft in Builder
- **WHEN** a user returns to a partially completed questionnaire edit
- **THEN** the system SHALL preserve the draft according to the defined strategy for that flow
