## ADDED Requirements

### Requirement: Surveys persist question labels
The survey management API SHALL include an optional `label` for each question definition so the patient-facing UI and agent layers can show human-friendly names. Create and update requests MUST accept `questions[i].label`, and fetch responses MUST return the stored label along with the rest of the survey definition.

#### Scenario: Client saves a labeled question
- **WHEN** a client sends `questions[i].label` in a `POST /surveys` or `PUT /surveys/{id}` payload
- **THEN** the backend MUST store the provided label in MongoDB with the question data
- **AND** the subsequent `GET /surveys/{id}` response MUST include that label
