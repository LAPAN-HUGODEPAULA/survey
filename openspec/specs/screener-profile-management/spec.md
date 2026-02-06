# screener-profile-management Specification

## Purpose
TBD - created by archiving change add-screener-registration. Update Purpose after archive.
## Requirements
### Requirement: Settings Page Without Screener Fields
The `settings_page.dart` in `survey-frontend` MUST NOT include screener name or contact fields.

#### Scenario: View settings page
**Given** a user navigates to the settings page
**When** the page loads
**Then** the fields for screener name and contact MUST NOT be present.

### Requirement: Profile Menu
The top menu in `survey-frontend` MUST include a profile icon with login and settings options.

#### Scenario: View top menu as a logged-out user
**Given** a user is not logged in
**When** the user views the top menu
**Then** a profile icon MUST be displayed, which opens a menu with a "Login" option.

#### Scenario: View top menu as a logged-in user
**Given** a screener is logged in
**When** the screener views the top menu
**Then** a profile icon MUST be displayed, which opens a menu with "Profile" and "Logout" options.

