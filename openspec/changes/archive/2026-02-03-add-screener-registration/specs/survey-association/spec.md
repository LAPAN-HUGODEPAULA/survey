# Specification for Survey Association

## ADDED Requirements

### Requirement: Associate Survey with Screener
The system MUST associate a survey response with the screener who administered it.

#### Scenario: Create a survey response with a logged-in screener
**Given** a screener is logged in
**When** the screener creates a new survey response
**Then** the survey response MUST be associated with the logged-in screener's ID.

#### Scenario: Create a survey response without a logged-in screener (patient app)
**Given** a survey response is created from the `survey-patient` app
**When** the survey response is saved
**Then** the survey response MUST be associated with the "System Screener" user.
