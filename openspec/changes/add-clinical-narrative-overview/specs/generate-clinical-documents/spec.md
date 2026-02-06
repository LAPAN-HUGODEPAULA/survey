## ADDED Requirements
### Requirement: Document Generation
The system SHALL generate clinical documents from the conversation context and approved templates.

#### Scenario: Generate visit document
- **WHEN** the clinician requests document generation
- **THEN** the system produces the document filled with captured data

### Requirement: Export and Print
The system SHALL allow PDF export and direct print option.

#### Scenario: Export PDF
- **WHEN** the clinician chooses export
- **THEN** the system generates a PDF of the document
