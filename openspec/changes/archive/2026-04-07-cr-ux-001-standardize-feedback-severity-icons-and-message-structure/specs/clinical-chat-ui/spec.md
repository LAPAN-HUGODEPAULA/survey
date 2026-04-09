## ADDED Requirements

### Requirement: Clinical chat MUST distinguish typed feedback surfaces
The `clinical-narrative` conversation UI MUST distinguish informational, warning, and error feedback consistently across assistant status, alerts, and insight surfaces.

#### Scenario: Assistant feedback is shown during a clinical conversation
- **WHEN** the conversation UI shows an assistant alert, system status, or typed insight
- **THEN** the interface MUST render it with a defined severity and a consistent iconographic treatment
- **AND** the user MUST be able to understand whether the content is informational, cautionary, or blocking

#### Scenario: Nonblocking conversation feedback is announced accessibly
- **WHEN** a status update appears in the chat screen without moving focus
- **THEN** the update MUST support an accessible status announcement mechanism
- **AND** it MUST remain visually consistent with the shared feedback model
