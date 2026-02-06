# Specification for Screener Profile Management

## ADDED Requirements

### Requirement: Screener Registration Page
The `survey-frontend` app MUST provide a page for screeners to register.

#### Scenario: View registration page
**Given** a user navigates to the registration page
**When** the page loads
**Then** the user MUST be presented with a form to enter their registration data.

#### Scenario: Successful registration
**Given** a user is on the registration page
**When** the user fills in the form with valid data and submits it
**Then** a new screener account MUST be created and the user MUST be redirected to the login page.

### Requirement: Screener Login Page
The `survey-frontend` app MUST provide a page for screeners to log in.

#### Scenario: View login page
**Given** a user navigates to the login page
**When** the page loads
**Then** the user MUST be presented with a form to enter their email and password.

### Requirement: Screener Profile Page
The `survey-frontend` app MUST provide a page for screeners to view and edit their profile.

#### Scenario: View profile page
**Given** a logged-in screener navigates to their profile page
**When** the page loads
**Then** the screener's profile information MUST be displayed.

## ADDED Requirements

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
