## ADDED Requirements
### Requirement: Missing Information Suggestions
The system SHALL analyze conversation context and suggest missing clinical information as follow-up questions.

#### Scenario: Suggest missing information
- **WHEN** a consultation message lacks required clinical details
- **THEN** the system provides suggested questions ranked by priority

### Requirement: Follow-up Question Generation
The system SHALL generate contextually relevant follow-up questions based on symptoms, history, and risk signals.

#### Scenario: Generate follow-up questions
- **WHEN** a clinician submits a symptom description
- **THEN** the system suggests relevant follow-up questions for clarification

### Requirement: Diagnostic Hypothesis Suggestions
The system SHALL propose diagnostic hypotheses with evidence and confidence scores.

#### Scenario: Provide hypotheses
- **WHEN** sufficient clinical data is present in the conversation
- **THEN** the system returns ranked hypotheses with supporting evidence
