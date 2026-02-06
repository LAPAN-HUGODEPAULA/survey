## ADDED Requirements
### Requirement: Metadata Capture
The system SHALL store document metadata including template version, session ID, author, and creation time.

#### Scenario: Store metadata
- **WHEN** a document is generated
- **THEN** the system records metadata alongside the document record

### Requirement: Metadata Embedding
The system SHALL embed key metadata in PDF outputs when supported.

#### Scenario: Embed metadata in PDF
- **WHEN** a PDF is generated
- **THEN** the file includes document type, author, and creation date
