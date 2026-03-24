## ADDED Requirements
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
