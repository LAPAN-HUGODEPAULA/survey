## ADDED Requirements

### Requirement: Named Step Visualization
Every flow with more than two steps SHALL display the current step name and the list of flow steps, identifying completion states.

#### Scenario: Progress visualization in the questionnaire
- **WHEN** the user is at the "Instruções" step of a questionnaire
- **THEN** the system displays a stepper showing "Aviso" (completed), "Instruções" (current), and "Perguntas" (future)
- **AND** uses the Brazilian Portuguese (pt-BR) language

### Requirement: Textual and Visual Progress Indicator
Progress SHALL be communicated through text (e.g., "Passo 2 de 5") together with a visual representation (e.g., progress bar or stepper).

#### Scenario: Update progress when changing steps
- **WHEN** the user completes the first step and advances
- **THEN** the progress text and visual fill of the progress bar SHALL be updated simultaneously

### Requirement: Integration with Draft and Validation State
Progress indicators SHALL reflect the submission and draft state of each step (according to `cr-ux-003`).

#### Scenario: Step with saved draft
- **WHEN** a step has data saved as a draft in the backend
- **THEN** the visual indicator of that step SHALL show a "rascunho" or "parcialmente preenchido" state

#### Scenario: Step with validation error
- **WHEN** the user attempts to advance and a step has pending errors
- **THEN** the visual indicator of that step SHALL show an "erro" or "atenção" state using the shared feedback model (`cr-ux-001`).

### Requirement: User Control and Return
The user SHALL be able to return to previous steps of the flow without loss of data already entered, except when the flow is transactional and finalized.

#### Scenario: Go back to review response
- **WHEN** the user clicks the "Voltar" button of a step
- **THEN** the system displays the previous step with the filled data preserved
