## ADDED Requirements
### Requirement: Legal Fields
The system SHALL enforce inclusion of required legal fields such as clinician identity, CRM, and dates.

#### Scenario: Validate legal fields
- **WHEN** a document is generated
- **THEN** the system blocks generation if required fields are missing

### Requirement: Confidentiality Notice
The system SHALL include a confidentiality notice on clinical documents.

#### Scenario: Add confidentiality notice
- **WHEN** a document is rendered
- **THEN** the output includes a confidentiality notice in the footer
