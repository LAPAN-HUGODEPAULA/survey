# user-navigation-orientation Specification

## Purpose
TBD - Update Purpose after archive.

## Requirements
### Requirement: Orientation after Redirection
After an automatic redirection between flows or screens, the system MUST provide a brief visual explanation of the new context using the shared feedback model (`cr-ux-001`).

#### Scenario: Redirection after saving questionnaire
- **WHEN** the user clicks "Finish" and is redirected to the report screen
- **THEN** the system SHALL display a transitional banner or title: "Respostas registradas. Relatório em preparo." (Responses recorded. Report in preparation.)
- **AND** the message SHALL use the severity corresponding to success or processing.

### Requirement: Wayfinding in Editors and Long Pages
Pages or editors with multiple sections MUST offer a local summary or sticky headers to assist in orientation.

#### Scenario: Editing in Builder
- **WHEN** the user edits a long questionnaire in `survey-builder`
- **THEN** the system SHALL provide side navigation or a summary that allows jumping to "Details", "Questions", and "Persona" sections.

### Requirement: Hierarchy and Return Context
The user MUST always have a visual return path to the previous context (breadcrumbs or contextual back button) that does not depend exclusively on the browser's navigation.

#### Scenario: Navigate between configuration screens
- **WHEN** the user enters a sub-configuration screen
- **THEN** the system SHALL display a "Back" button or breadcrumbs allowing return to the parent screen.
