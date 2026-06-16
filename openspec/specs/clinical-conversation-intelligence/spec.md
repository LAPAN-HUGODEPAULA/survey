# Clinical Conversation Intelligence & Context Extraction Specification

## Purpose
Consolidates requirements for entity extraction, consultation phase detection, follow-up suggestions, clinical warnings/alerts, and knowledge base lookups.

## Requirements
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

### Requirement: Follow-up Question Suggestions
The system SHALL suggest follow-up questions based on the conversation context.

#### Scenario: Suggest questions for incomplete records
- **WHEN** the conversation lacks specific clinical details
- **THEN** the system SHALL suggest questions to complete the record

### Requirement: ICD-10 Code Suggestions
The system SHALL suggest relevant ICD-10 codes when appropriate.

#### Scenario: Identify candidate ICD-10 codes
- **WHEN** clinical signs or symptoms are discussed
- **THEN** the system SHALL suggest candidate ICD-10 codes

### Requirement: Code Suggestions
The system SHALL suggest diagnostic codes (CID-10 and ICD-11) when applicable.

#### Scenario: Suggest codes
- **WHEN** a diagnostic hypothesis is proposed
- **THEN** the system provides related CID-10 and ICD-11 codes

### Requirement: Knowledge Lookups
The system SHALL support integration with medical knowledge sources for terminology and safety checks.

#### Scenario: Lookup interaction
- **WHEN** medications are mentioned together
- **THEN** the system checks for known interactions and surfaces results

### Requirement: Clinical Alert Generation
The system SHALL generate alerts for safety-relevant issues such as interactions, contraindications, and red flags.

#### Scenario: Generate alert
- **WHEN** risky combinations or red flag symptoms are detected
- **THEN** the system presents a clinical alert with severity level

### Requirement: Alert Acknowledgment
The system SHALL require explicit acknowledgment for critical alerts.

#### Scenario: Acknowledge critical alert
- **WHEN** a critical alert is shown
- **THEN** the clinician must acknowledge it before proceeding

### Requirement: Typed Insight Panels
Every AI-generated insight SHALL be presented in a card that clearly identifies its severity and type (suggestion, warning, hypothesis).

#### Scenario: View AI suggestion
- **WHEN** the AI generates a clinical conduct suggestion
- **THEN** the system displays a card with `severity=info`, icon `lightbulb_outline`, and title "Sugestão do Assistente"
- **AND** uses Brazilian Portuguese (pt-BR)

### Requirement: Visual Severity of Insights
Insight cards SHALL use colors and icons consistent with the platform's feedback taxonomy (`info`, `success`, `warning`, `error`).

#### Scenario: View clinical alert
- **WHEN** the AI detects a clinical inconsistency or risk (e.g., warning sign)
- **THEN** the system displays a card with `severity=warning`, icon `warning_amber_rounded`, and title "Alerta Clínico"
