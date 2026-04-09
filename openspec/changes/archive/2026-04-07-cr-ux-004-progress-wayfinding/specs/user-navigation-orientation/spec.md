## ADDED Requirements

### Requirement: Orientation after Redirection
After an automatic redirection between flows or screens, the system SHALL provide a brief visual explanation of the new context using the shared feedback model (`cr-ux-001`).

#### Scenario: Redirection after saving questionnaire
- **WHEN** the user clicks "Finalizar" and is redirected to the report screen
- **THEN** the system displays a banner or transitional title: "Respostas registradas. Relatório em preparo."
- **AND** the message must use the severity corresponding to success or processing.

### Requirement: Wayfinding in Editors and Long Pages
Pages or editors with multiple sections SHALL offer a local summary or sticky headers that help in orientation.

#### Scenario: Editing in the Builder
- **WHEN** the user edits a long questionnaire in the `survey-builder`
- **THEN** the system provides a lateral navigation or summary that allows skipping to the "Detalhes", "Perguntas", and "Persona" sections.

### Requirement: Hierarchy and Return Context
The user SHALL always have a visual path to return to the previous context (breadcrumbs or contextual back button) that does not depend exclusively on browser navigation.

#### Scenario: Navigating between configuration screens
- **WHEN** the user enters a sub-configuration screen
- **THEN** the system displays a "Voltar" button or breadcrumbs allowing return to the parent screen.
