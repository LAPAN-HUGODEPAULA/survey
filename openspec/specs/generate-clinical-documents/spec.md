# generate-clinical-documents Specification

## Purpose
TBD - created by archiving change add-clinical-narrative-overview. Update Purpose after archive.
## Requirements
### Requirement: Document Generation
The system SHALL generate clinical documents from the conversation context and approved templates only after the generated output passes the configured reflection-based safety review. When review fails and a corrective retry is still allowed, the system SHALL revise the draft instead of delivering it immediately.

#### Scenario: Generate visit document after successful review
- **WHEN** the clinician requests document generation
- **THEN** the system produces the document filled with captured data only after the reflection stage approves the generated output

#### Scenario: School document requires rewrite after unsafe recommendation
- **GIVEN** the system generates a school-facing document draft
- **AND** the draft includes a medical prescription or invasive recommendation
- **WHEN** the reflection stage evaluates the draft
- **THEN** the system SHALL return the draft to the writing stage for correction rather than delivering it as final output

### Requirement: Export and Print
The system SHALL allow PDF export and direct print option.

#### Scenario: Export PDF
- **WHEN** the clinician chooses export
- **THEN** the system generates a PDF of the document

