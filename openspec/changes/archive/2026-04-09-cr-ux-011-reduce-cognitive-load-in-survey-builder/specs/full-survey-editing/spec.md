## MODIFIED Requirements

### Requirement: The system MUST provide an interface for managing survey questions.

This interface MUST allow users to add, edit, and remove questions and their answers. The interface SHALL use clear visual grouping and sectional wayfinding to help administrators manage large numbers of questions within a single survey form.

#### Scenario: User adds a new question to the survey
-   **Given** a user is on the `SurveyFormScreen`
-   **When** they click the "Add Question" button
-   **Then** a new, empty question widget MUST appear in the questions list.
-   **AND** the system SHOULD scroll to and highlight the new question widget.

#### Scenario: User removes a question from the survey
-   **Given** a survey has at least one question
-   **When** the user clicks the "Remove" button on a question widget
-   **Then** the corresponding question widget MUST be removed from the list.

#### Scenario: User adds an answer to a question
-   **Given** a question exists in the survey
-   **When** the user clicks the "Add Answer" button within that question's widget
-   **Then** a new, empty answer field MUST appear in that question's answer list.

#### Scenario: User removes an answer from a question
-   **Given** a question has at least one answer
-   **When** the user clicks the "Remove" button on an answer field
-   **Then** the corresponding answer field MUST be removed from that question's answer list.

#### Scenario: User navigates between questionnaire sections
- **GIVEN** a survey with many questions divided into logical groups or just a long list
- **WHEN** the user uses the sectional navigation component
- **THEN** the question list MUST scroll to the corresponding group or question index
- **AND** the question editor's sticky actions MUST remain accessible for immediate save.
