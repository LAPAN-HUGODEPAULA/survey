## ADDED Requirements
### Requirement: Encryption at Rest
The system MUST encrypt sensitive personal and health data when stored.

#### Scenario: Store patient data
- **WHEN** sensitive patient data is persisted
- **THEN** the stored data MUST be encrypted at rest

### Requirement: Encryption in Transit
The system MUST encrypt all data transmissions between clients and services.

#### Scenario: Submit data to an API
- **WHEN** a client submits data to an API endpoint
- **THEN** the connection MUST use transport encryption

### Requirement: Key Management
The system MUST manage encryption keys separately from stored data and support key rotation procedures.

#### Scenario: Rotate encryption keys
- **WHEN** a key rotation event is initiated
- **THEN** the system MUST rotate keys without exposing plaintext data
