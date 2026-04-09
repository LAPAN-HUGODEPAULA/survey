# screener-profile-management Specification

## Purpose
Define how screener account actions are exposed in the professional application shell.
## Requirements
### Requirement: Settings Page Without Screener Fields
The `settings_page.dart` in `survey-frontend` MUST NOT include screener name or contact fields.

#### Scenario: View settings page
**Given** a user navigates to the settings page
**When** the page loads
**Then** the fields for screener name and contact MUST NOT be present.

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
