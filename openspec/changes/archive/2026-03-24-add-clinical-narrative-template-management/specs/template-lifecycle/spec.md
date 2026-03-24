## ADDED Requirements
### Requirement: Versioning
The system SHALL maintain version history for templates using semantic versioning.

#### Scenario: Edit template
- **WHEN** an administrator edits a template
- **THEN** the system creates a new version and preserves prior versions

### Requirement: Approval Workflow
The system SHALL require approval before a template becomes active.

#### Scenario: Approve template
- **WHEN** an administrator approves a template draft
- **THEN** the template status changes to active and is visible to clinicians

### Requirement: Archival
The system SHALL allow administrators to archive templates instead of hard deletion.

#### Scenario: Archive template
- **WHEN** an administrator archives a template
- **THEN** the template is hidden from clinician selection but remains stored for audit
