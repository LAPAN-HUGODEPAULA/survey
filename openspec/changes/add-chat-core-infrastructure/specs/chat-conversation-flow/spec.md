## ADDED Requirements
### Requirement: Turn-Based Flow
The system SHALL process conversations in a turn-based flow between clinician input and AI response.

#### Scenario: AI processing
- **WHEN** a clinician sends a message
- **THEN** the system displays a processing state until the AI responds

### Requirement: Context Management
The system SHALL preserve conversation context across the session for AI processing.

#### Scenario: Reference prior messages
- **WHEN** the AI responds to a later message
- **THEN** the response reflects earlier context in the same session

### Requirement: Consultation Phases
The system SHALL support consultation phases to guide AI behavior and UI context.

#### Scenario: Change phase
- **WHEN** the clinician selects a new phase
- **THEN** the system updates the phase and adapts prompts accordingly
