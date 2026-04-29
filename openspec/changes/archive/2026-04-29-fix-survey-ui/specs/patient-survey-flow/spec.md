## MODIFIED Requirements

### Requirement: Welcome Screen
The system MUST display a welcome screen with a call-to-action button to start the survey and MUST remove motivational subtitle copy that reduces readability focus for this flow.

#### Scenario: User starts the survey
- **Given** a user is on the welcome screen
- **When** the user clicks the "Start Survey" button
- **Then** the system MUST navigate to the survey screen.

#### Scenario: Welcome subtitle text is removed
- **WHEN** the welcome screen is rendered in `survey-patient`
- **THEN** the text `"Olá! Estamos com você em cada etapa."` MUST NOT be displayed
- **AND** the primary welcome heading and start action MUST remain visible

### Requirement: Survey Screen
The system MUST present the survey instructions and survey questions to the user and MUST keep respondent content reachable on low-resolution devices.

#### Scenario: User answers the survey
- **Given** a user is on the survey screen
- **When** the user answers all the questions
- **Then** the system MUST navigate to the thank you screen.

#### Scenario: User accesses full survey content on low-resolution devices
- **WHEN** the survey screen content exceeds the viewport height
- **THEN** the screen MUST allow vertical scrolling of the respondent section content
- **AND** no required instruction or question control may become unreachable due to fixed-height clipping
