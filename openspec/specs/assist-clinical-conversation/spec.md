# assist-clinical-conversation Specification

## Purpose
TBD - Update Purpose after archive.

## Requirements
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
