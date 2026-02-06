# Proposal: Add Screener Registration

Introduces a full user management system for Screeners, including registration, login, and profile management. This change refactors the screener from a simple name/email pair to a dedicated user entity in the database, enhancing security and traceability.

## Why
Current screener handling lacks authentication and auditability, limiting security and traceability across survey workflows.

## What Changes
- Add screener registration, login, and profile UX in `survey-frontend`.
- Persist screeners as first-class users with authentication flows and recovery.
- Associate survey responses with registered screeners and create a default system screener.

## Deltas

- **screener-user-model**: Defines the new `Screener` user model in the database.
- **screener-authentication**: Defines the authentication mechanism for screeners (login, password encryption, password recovery).
- **survey-association**: Updates the `SurveyResponse` model to be associated with a registered `Screener` user.
- **screener-profile-management**: Defines the UI and API for screener profile creation and management in `survey-frontend`.
- **system-screener**: Defines the default "System Screener" and how it's used.
- **database-migration**: Defines the migration script to create the new `screeners` collection and the "System Screener" user.
