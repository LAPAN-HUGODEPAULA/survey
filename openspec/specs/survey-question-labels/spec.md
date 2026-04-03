# survey-question-labels Specification

## Purpose
TBD - created by archiving change update-assessment-workflow. Update Purpose after archive.
## Requirements
### Requirement: Questions expose optional label metadata
Every question definition in MongoDB SHALL include an optional `label` property that describes how the question should be referenced in visualizations or agent prompts. APIs that return surveys SHALL include the `label` field for each question so clients can display human-readable names instead of numeric IDs. New questions created in `survey-builder` or via API MUST accept a `label` value when provided.

#### Scenario: Persisting a labeled question
- **WHEN** a client submits a `POST /surveys` or `PUT /surveys/{id}` payload that supplies `questions[i].label`
- **THEN** the backend MUST persist that label alongside the question definition
- **AND** the survey retrieval APIs MUST return the saved label to subsequent clients

### Requirement: Legacy surveys receive fallback labels
A migration task SHALL populate `label` for existing questions by deriving a short text from the question prompt (e.g., “Luzes pulsantes”). Downstream consumers SHALL gracefully fall back to ordinal identifiers (`Q1`, `Q2`, etc.) when the label is still null.

#### Scenario: Running the label migration
- **WHEN** the migration executes after the schema change
- **THEN** it MUST inspect each stored question, derive a concise label from the question text, and persist it without requiring manual edits
- **AND** any question without a derived label MUST still render as `Q<number>` in the UI

### Requirement: Builder surfaces and edits question labels
`survey-builder` MUST let administrators provide or edit the label for every question. The label input SHALL appear in the question editor and the question list preview so administrators can confirm how the label will appear in charts or agent prompts.

#### Scenario: Editing a label inside the builder
- **WHEN** an administrator updates a question in `survey-builder` and changes the label field
- **THEN** the application MUST include the new label in the survey payload it sends to the backend
- **AND** the saved survey MUST show the updated label when reopened or previewed

#### Scenario: Previewing a question with a label
- **WHEN** the builder renders the question list or preview tiles
- **THEN** it MUST display the configured label if present
- **AND** it MUST fall back to the numeric question ID when no label exists so the UI never shows blank text

