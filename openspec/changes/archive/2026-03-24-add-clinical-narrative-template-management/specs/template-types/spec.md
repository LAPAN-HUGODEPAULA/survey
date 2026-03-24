## ADDED Requirements
### Requirement: Supported Document Types
The system SHALL support at least six document types for templates: consultation record, prescription, referral, certificate, technical report, and clinical progress.

#### Scenario: List document types
- **WHEN** an administrator creates a new template
- **THEN** the system presents the supported document types

### Requirement: Template Ownership
The system SHALL restrict template creation and management to administrators.

#### Scenario: Clinician attempts to create template
- **WHEN** a clinician attempts to create a template
- **THEN** the system denies the action with an authorization error
