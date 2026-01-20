# Specification for Patient Survey Flow

## ADDED Requirements

### Requirement: Welcome Screen
The system MUST display a welcome screen with a call-to-action button to start the survey.

#### Scenario: User starts the survey
**Given** a user is on the welcome screen
**When** the user clicks the "Start Survey" button
**Then** the system MUST navigate to the survey screen.

### Requirement: Survey Screen
The system MUST present the survey questions to the user.

#### Scenario: User answers the survey
**Given** a user is on the survey screen
**When** the user answers all the questions
**Then** the system MUST navigate to the thank you screen.

### Requirement: Thank You Screen
The system MUST display a thank you screen with a summary of the user's answers, a radar chart, and an option to provide personal information.

#### Scenario: User provides personal information
**Given** a user is on the thank you screen
**When** the user clicks the "Add Information" button
**Then** the system MUST navigate to the demographic information screen.

#### Scenario: User finishes without providing personal information
**Given** a user is on the thank you screen
**When** the user clicks the "Finish" button
**Then** a system MUST send the survey response to the AI agent without personal data and navigate to the final thank you screen.

### Requirement: Demographic Information Screen
The system MUST allow the user to enter their demographic information.

#### Scenario: User submits demographic information
**Given** a user is on the demographic information screen
**When** the user fills in the form and clicks "Submit"
**Then** the system MUST send the survey response to the AI agent with the user's personal data and navigate to the final thank you screen.
