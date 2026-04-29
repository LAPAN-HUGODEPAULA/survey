## MODIFIED Requirements

### Requirement: Textual and Visual Progress Progress
Progress MUST be communicated through text (e.g., "Step 2 of 5") in conjunction with a visual representation (e.g., progress bar or stepper). Whenever progress text appears on tonal or highlighted surfaces, the text contrast MUST be at least 6:1 against its immediate background.

#### Scenario: Update progress after answering
- **WHEN** the user advances to the next step
- **THEN** the progress text and the visual fill of the progress bar MUST be updated simultaneously

#### Scenario: Progress text remains readable on highlighted surfaces
- **WHEN** the progress indicator is rendered inside colored cards, chips, or status containers
- **THEN** the progress text foreground and background MUST maintain at least a 6:1 contrast ratio
- **AND** readability MUST be preserved in both light and dark tonal variants used by respondent flows
