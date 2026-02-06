## ADDED Requirements
### Requirement: Template Discovery
The system SHALL allow clinicians to browse, filter, and search active templates.

#### Scenario: Filter by document type
- **WHEN** a clinician filters templates by type
- **THEN** only matching active templates are shown

### Requirement: Template Preview
The system SHALL allow clinicians to preview templates before selection.

#### Scenario: Preview template
- **WHEN** a clinician requests a preview
- **THEN** the system renders the template using available session data

### Requirement: Recommendations
The system SHALL suggest relevant templates based on consultation context when available.

#### Scenario: Suggest template
- **WHEN** consultation context indicates a likely document type
- **THEN** the system presents recommended templates ranked by relevance
