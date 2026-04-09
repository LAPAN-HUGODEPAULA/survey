# multi-step-progress-standard Specification

## Purpose
TBD - created by archiving change cr-ux-004-progress-wayfinding. Update Purpose after archive.

## Requirements
### Requirement: Step List and Current Stage Visibility
Every flow with more than two stages MUST display the name of the current stage and the list of flow stages, identifying completion states.

#### Scenario: View stepper in patient flow
- **WHEN** a user starts the assessment
- **THEN** the system SHALL display a stepper showing "Notice" (completed), "Instructions" (current), and "Questions" (future)

### Requirement: Textual and Visual Progress Progress
Progress MUST be communicated through text (e.g., "Step 2 of 5") in conjunction with a visual representation (e.g., progress bar or stepper).

#### Scenario: Update progress after answering
- **WHEN** the user advances to the next step
- **THEN** the progress text and the visual fill of the progress bar MUST be updated simultaneously

### Requirement: Lifecycle State Visibility in Progress Indicators
Progress indicators MUST reflect the submission and draft state of each stage (per `cr-ux-003`).

#### Scenario: Stage with saved draft
- **WHEN** a stage has a saved draft but is not yet submitted
- **THEN** the visual indicator for that stage SHALL show a "draft" or "partially filled" state

#### Scenario: Stage with validation error
- **WHEN** the user attempts to advance but the current stage has errors
- **THEN** the visual indicator for that stage SHALL show an "error" or "attention" state using the shared feedback model (`cr-ux-001`).

### Requirement: Return without Data Loss
The user MUST be able to return to previous flow stages without losing already entered data, except when the flow is transactional and finalized.

#### Scenario: Go back to previous step
- **WHEN** the user clicks "Previous"
- **THEN** the system SHALL display the previous stage with the preserved filled data

### Requirement: Sectional Navigation for Long Single-Page Flows
Long, single-page administrative forms or configuration screens SHALL offer sectional navigation (Table of Contents) that reflects the structure of the document and indicates progress or validation status for each section.

#### Scenario: User views the sectional navigation in a long form
- **WHEN** the user is viewing a long configuration or builder form
- **THEN** a sectional navigation menu MUST be available, listing all major sections of the page
- **AND** the menu MUST show if a section has validation errors or unsaved changes using appropriate status icons from the shared feedback model.
