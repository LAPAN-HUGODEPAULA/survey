## ADDED Requirements
### Requirement: Template Schema
The system SHALL store templates with structured fields for metadata, content, variables, and conditions.

#### Scenario: Persist template schema
- **WHEN** a template is saved
- **THEN** the system validates required fields and stores the structured schema

### Requirement: Placeholders
The system SHALL support placeholders for patient, clinician, and consultation data.

#### Scenario: Render placeholders
- **WHEN** a template is rendered with session data
- **THEN** placeholders are replaced with available values

### Requirement: Conditional Sections
The system SHALL support conditional sections based on clinical context.

#### Scenario: Evaluate conditional section
- **WHEN** a condition evaluates to false
- **THEN** the system omits the conditional section from output
