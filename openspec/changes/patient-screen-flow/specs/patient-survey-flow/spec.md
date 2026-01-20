# Specification for Patient Survey Flow

## ADDED Requirements

### Requirement: Welcome Screen
The system MUST display a welcome screen with a call-to-action button to start the survey.

#### Scenario: User starts the survey
**Given** a user is on the welcome screen
**When** the user clicks the "Start Survey" button
**Then** the system MUST navigate to the survey screen.

### Requirement: Survey Screen
The system MUST present the survey instructions and survey questions to the user.

#### Scenario: User answers the survey
**Given** a user is on the survey screen
**When** the user answers all the questions
**Then** the system MUST navigate to the thank you screen.

### Requirement: Thank You Screen
The system MUST display a thank you screen with a summary of the user's answers, a radar chart, and an option to provide personal information. Add kind inviting message to encourage users to share their demographic data for better insights.

#### Scenario: User provides personal information
**Given** a user is on the thank you screen
**When** the user clicks the "Add Information" button
**Then** the system MUST navigate to the demographic information screen.

#### Scenario: User continues without providing personal information
**Given** a user is on the thank you screen
**When** the user clicks the "Get Results" button
**Then** a system MUST send the survey response to the AI agent without personal data and navigate to the report page.

### Requirement: Demographic Information Screen
The system MUST allow the user to enter their demographic information.

#### Scenario: User submits demographic information
**Given** a user is on the demographic information screen
**When** the user fills in the form and clicks "Submit"
**Then** the system MUST send the survey response to the AI agent with the user's personal data and navigate to the report page.

### Requirement: Report Page
The system MUST display the AI agent's response on a new report page.

#### Scenario: View report
**Given** a user is on the report page
**When** the user views the report
**Then** the report content MUST be selectable.

#### Scenario: Export report as text
**Given** a user is on the report page
**When** the user clicks the "Save as Text" button
**Then** the system MUST initiate a download of the report as a plain text file.

#### Scenario: Export report as PDF
**Given** a user is on the report page
**When** the user clicks the "Export as PDF" button
**Then** the system MUST initiate a process to save the report as a PDF file.

## MODIFIED Requirements

### Requirement: Survey Response Submission
The backend MUST accept survey responses with or without patient data.

#### Scenario: Submit survey with patient data
**Given** a survey response contains patient data
**When** the response is submitted to the `create_survey_response` endpoint
**Then** the system MUST accept the response and store it.

#### Scenario: Submit survey without patient data
**Given** a survey response does not contain patient data
**When** the response is submitted to the `create_survey_response` endpoint
**Then** the system MUST accept the response and store it with a null value for patient data.
