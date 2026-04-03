## ADDED Requirements

### Requirement: Builder exposes question label controls
The `survey-builder` questionnaire editor SHALL present a label input for each question and include that label in all question preview/listing rows so administrators understand how the patient radar will render the axis.

#### Scenario: Administrator edits a question label
- **WHEN** the user edits a question in `survey-builder` and supplies a new label
- **THEN** the application MUST include the label in the payload sent to the backend
- **AND** the label MUST appear in the question list or preview immediately after saving
