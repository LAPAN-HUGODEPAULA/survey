## ADDED Requirements
### Requirement: Template Registration
The system SHALL allow authorized administrators to create and edit templates.

#### Scenario: Create template
- **WHEN** an administrator saves a new template
- **THEN** the system records the template with version metadata

### Requirement: Document Types
The system SHALL support at least six clinical document types.

#### Scenario: List supported types
- **WHEN** the administrator configures a template
- **THEN** the system offers types: visit note, prescription, referral, certificate, report/opinion, and clinical evolution
