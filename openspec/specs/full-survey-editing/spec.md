# full-survey-editing Specification

## Purpose
TBD - created by archiving change add-question-edit-to-builder. Update Purpose after archive.

## Requirements
### Requirement: The system MUST provide an interface for editing survey instructions.
This interface MUST allow users to edit all fields of the `instructions` object.

#### Scenario: User edits the survey instructions
**Given** a user is on the `SurveyFormScreen`
**When** they modify the text in the `preamble`, `questionText`, or `answers` fields for the instructions
**And** they save the survey
**Then** the updated instructions MUST be persisted to the database.

### Requirement: The system MUST provide an interface for managing survey questions.
This interface MUST allow users to add, edit, and remove questions and their answers.

#### Scenario: User adds a new question to the survey
**Given** a user is on the `SurveyFormScreen`
**When** they click the "Add Question" button
**Then** a new, empty question widget MUST appear in the questions list.

#### Scenario: User removes a question from the survey
**Given** a survey has at least one question
**When** the user clicks the "Remove" button on a question widget
**Then** the corresponding question widget MUST be removed from the list.

#### Scenario: User adds an answer to a question
**Given** a question exists in the survey
**When** the user clicks the "Add Answer" button within that question's widget
**Then** a new, empty answer field MUST appear in that question's answer list.

#### Scenario: User removes an answer from a question
**Given** a question has at least one answer
**When** the user clicks the "Remove" button on an answer field
**Then** the corresponding answer field MUST be removed from that question's answer list.

### Requirement: The system MUST enforce survey validation rules.
The system MUST ensure that a survey meets minimum content requirements before it can be saved.

#### Scenario: User tries to save a survey with no questions
**Given** a user is editing a survey and removes all questions
**When** they attempt to save the survey
**Then** a validation error MUST be displayed, indicating that at least one question is required.
**And** the survey MUST NOT be saved.

#### Scenario: User tries to save a question with no answers
**Given** a user is editing a question and removes all of its answers
**When** they attempt to save the survey
**Then** a validation error MUST be displayed for that question, indicating that at least one answer is required.
**And** the survey MUST NOT be saved.
