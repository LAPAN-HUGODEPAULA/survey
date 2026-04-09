## ADDED Requirements

### Requirement: Platform effort acknowledgment pattern
The platform SHALL define a standard message pattern for acknowledging user effort and participation.

#### Scenario: User completes a high-cognitive-load task
- **WHEN** the user completes a long survey or complex clinician narrative session
- **THEN** the system MUST display an empathetic acknowledgement (e.g., "Obrigado por sua participação. Suas respostas ajudam...") using a supportive visual tone.

### Requirement: Handoff orientation pattern
The platform SHALL define a message pattern to orient users during multi-step handoff sequences.

#### Scenario: Orientation during analysis wait
- **WHEN** the system transitions from Step 1 (Saved) to Step 2 (Analyzing)
- **THEN** the system MUST clearly communicate the transition (e.g., "Sua avaliação foi salva. Estamos organizando os dados...") and provide clear next-step expectations.
