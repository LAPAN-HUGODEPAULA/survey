# screener-survey-access-links Specification

## Purpose
TBD - created by archiving change add-locked-screener-survey-links. Update Purpose after archive.
## Requirements
### Requirement: Generate Screener Questionnaire Access Link
The system MUST allow an operator to generate a reusable opaque access link for a selected screener and selected questionnaire in `survey-frontend`.

#### Scenario: Generate a link after choosing the screener and questionnaire
**Given** an operator has a screener available for use
**And** a questionnaire is selected in `survey-frontend`
**When** the operator requests a questionnaire link
**Then** the system MUST create an opaque reusable link bound to that screener and questionnaire
**And** the system MUST present the generated URL in a copyable format
**And** the system MUST offer exports as plain text and QR code in `PNG` format.

#### Scenario: Support more than one prepared link per screener
**Given** a screener already has a generated access link for one questionnaire
**When** an operator generates a link for the same screener with another questionnaire
**Then** the system MUST allow the new link to be created
**And** each link MUST resolve to its own screener-questionnaire pair.

### Requirement: Launch the App in Locked Assessment Mode
The system MUST open `survey-frontend` in a locked assessment mode when a valid access link is used.

#### Scenario: Open a valid access link
**Given** a reusable access link exists for a screener and questionnaire
**When** a user opens the link
**Then** the application MUST resolve the link before starting the assessment flow
**And** the screener and questionnaire MUST be preselected automatically
**And** the user MUST be taken directly into the assessment flow without needing manual setup
**And** the setup controls for changing the screener or questionnaire MUST be hidden or disabled.

#### Scenario: Preserve locked setup during the session
**Given** a user entered `survey-frontend` through a valid access link
**When** the user navigates through the assessment flow
**Then** the linked screener and questionnaire MUST remain fixed for that session
**And** the interface MUST clearly explain that the session was opened from a prepared link.

### Requirement: Provide Accessible Link Sharing Outputs
The system MUST provide low-friction sharing outputs for non-technical users when a prepared access link is generated.

#### Scenario: Share the generated link
**Given** an access link has been generated successfully
**When** the operator views the generated-link state
**Then** the system MUST provide clear actions to copy the URL, save the URL as text, and save the QR code as `PNG`
**And** each action MUST provide accessible feedback confirming success or failure
**And** the labels and instructions MUST use clear non-technical pt-BR language.

### Requirement: Show an Informational Unavailable Page
The system MUST show an informational unavailable page when a prepared access link can no longer be used.

#### Scenario: Linked screener is no longer available
**Given** an access link points to a screener that is no longer available
**When** a user opens the link
**Then** the application MUST show an informational page instead of a technical error page
**And** the page MUST explain that the screener or questionnaire is no longer available
**And** the page MUST instruct the user to contact the current screener or `lapan.hugodepaula@gmail.com`.

#### Scenario: Linked questionnaire is no longer available
**Given** an access link points to a questionnaire that is no longer available
**When** a user opens the link
**Then** the application MUST show the same informational unavailable experience
**And** the page MUST avoid technical error terminology
**And** the page MUST remain accessible to keyboard and assistive-technology users.

