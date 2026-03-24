## ADDED Requirements
### Requirement: Placeholder Rendering
The system SHALL replace template placeholders with actual data, applying formatting rules.

#### Scenario: Render placeholders
- **WHEN** a template is rendered
- **THEN** placeholders are replaced with values or configured fallbacks

### Requirement: Medical Formatting
The system SHALL apply medical document conventions (sections, signatures, units, and dates).

#### Scenario: Apply medical formatting
- **WHEN** a document is rendered
- **THEN** the output follows Brazilian medical document conventions
