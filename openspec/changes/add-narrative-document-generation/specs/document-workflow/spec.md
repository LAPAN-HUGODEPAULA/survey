## ADDED Requirements
### Requirement: Document Generation Flow
The system SHALL provide a guided workflow to select templates, preview output, and confirm document generation.

#### Scenario: Generate document
- **WHEN** a clinician selects "Generate Document"
- **THEN** the system shows template suggestions, a preview, and a confirmation step

### Requirement: Data Mapping
The system SHALL map consultation data and extracted entities to template variables before rendering.

#### Scenario: Map consultation data
- **WHEN** a document preview is requested
- **THEN** the system maps transcript, entities, and patient data into template variables
