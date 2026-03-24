## ADDED Requirements
### Requirement: Clinical Entity Extraction
The system SHALL extract and track clinical entities from the conversation in real time.

#### Scenario: Extract entities
- **WHEN** a new message is processed
- **THEN** the system updates the entity list with normalized terms

### Requirement: Consultation Phase Detection
The system SHALL detect and suggest consultation phase transitions based on conversation content.

#### Scenario: Suggest phase transition
- **WHEN** the conversation shifts from history taking to assessment
- **THEN** the system suggests the new phase and updates the UI indicator

### Requirement: Context Summarization
The system SHALL summarize context when message volume exceeds processing limits.

#### Scenario: Summarize context
- **WHEN** the context window exceeds configured limits
- **THEN** the system generates a summary while preserving key clinical facts
