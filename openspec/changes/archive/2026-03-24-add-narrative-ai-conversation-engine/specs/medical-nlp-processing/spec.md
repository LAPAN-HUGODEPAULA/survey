## ADDED Requirements
### Requirement: Medical Terminology Normalization
The system SHALL recognize and normalize medical terminology in pt-BR.

#### Scenario: Normalize terminology
- **WHEN** medical terms or abbreviations appear in the conversation
- **THEN** the system stores normalized equivalents alongside raw text

### Requirement: Negation Detection
The system SHALL detect negated findings to prevent false positives.

#### Scenario: Detect negation
- **WHEN** a clinician notes an absent symptom
- **THEN** the system records the symptom as negated

### Requirement: Temporal Relationship Extraction
The system SHALL extract temporal relationships for symptoms, treatments, and events.

#### Scenario: Extract temporal data
- **WHEN** timing or duration is mentioned
- **THEN** the system captures temporal relationships in structured form
