## ADDED Requirements

### Requirement: Shared respondent status metadata MUST meet high contrast thresholds
Shared respondent-flow metadata text rendered on tonal surfaces from `packages/design_system_flutter` (including progress and survey-status labels) MUST maintain a minimum contrast ratio of 6:1 between text foreground and background.

#### Scenario: Progress and status metadata render on respondent cards
- **WHEN** a respondent app renders metadata such as `"Progresso (2 de 5)"` or `"Questionário ativo"`
- **THEN** the shared component styles MUST provide at least 6:1 contrast ratio for the metadata text against its background surface
- **AND** the contrast treatment MUST be consistent across `survey-patient` and `survey-frontend`

### Requirement: Shared survey answer buttons MUST keep white-label readability
The shared survey answer option buttons used by `DsSurveyQuestionData` MUST use fill colors that provide a minimum contrast ratio of 6:1 against white text labels.

#### Scenario: Respondent sees survey response options
- **WHEN** the survey answer buttons are rendered with white text
- **THEN** each configured button background color MUST satisfy at least 6:1 contrast ratio against the text color
- **AND** the color mapping MUST remain stable for all four option buttons

### Requirement: Shared section containers MUST support vertical scrolling
Shared respondent section containers in `packages/design_system_flutter` MUST provide vertical scrolling behavior when content height exceeds the viewport on low-resolution devices.

#### Scenario: Section content exceeds available viewport
- **WHEN** a consuming app renders a shared section with content taller than the device viewport
- **THEN** the shared section container MUST allow vertical scrolling without clipping child controls
- **AND** consuming apps MUST NOT need to implement duplicate local scroll wrappers for the same section behavior
