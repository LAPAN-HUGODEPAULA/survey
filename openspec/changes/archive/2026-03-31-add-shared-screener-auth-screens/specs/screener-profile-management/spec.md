## MODIFIED Requirements

### Requirement: Profile Menu
The top menu in `survey-frontend` and `clinical-narrative` MUST include a profile icon with shared authentication actions.

#### Scenario: View top menu as a logged-out user
**Given** a user is not logged in
**When** the user views the top menu in `survey-frontend` or `clinical-narrative`
**Then** a profile icon MUST be displayed
**And** opening the menu MUST expose entry points for sign-in and sign-up

#### Scenario: View top menu as a logged-in user
**Given** a screener is logged in
**When** the screener views the top menu in `survey-frontend` or `clinical-narrative`
**Then** a profile icon MUST be displayed
**And** opening the menu MUST expose actions for logout and account switching
