# database-migration Specification

## Purpose
TBD - created by archiving change add-screener-registration. Update Purpose after archive.
## Requirements
### Requirement: Create Screeners Collection
A migration script MUST be created to create the `screeners` collection in the database.

#### Scenario: Run migration
**Given** the migration script is executed
**When** the migration completes
**Then** a new collection named `screeners` MUST exist in the database.

### Requirement: Add System Screener
The migration script MUST add the "System Screener" user to the `screeners` collection.

#### Scenario: Run migration
**Given** the migration script is executed
**When** the migration completes
**Then** the "System Screener" user MUST be present in the `screeners` collection.

### Requirement: Add Sample Screener
The migration script MUST add a sample screener user to the `screeners` collection for testing purposes.

#### Scenario: Run migration
**Given** the migration script is executed
**When** the migration completes
**Then** a sample screener user MUST be present in the `screeners` collection.

### Requirement: Migration scripts MUST create the QuestionnairePrompts and PersonaSkills collections.

The migration plan for the split prompt model MUST create MongoDB collections named `QuestionnairePrompts` and `PersonaSkills`.

#### Scenario: Run the prompt-storage migration
- **Given** the migration script is executed against an environment that does not yet use the split prompt model
- **When** the migration completes successfully
- **Then** the database MUST contain `QuestionnairePrompts`
- **And** the database MUST contain `PersonaSkills`

### Requirement: Migration scripts MUST backfill questionnaire prompts and seed persona skills without losing runtime traceability.

The migration MUST backfill questionnaire-specific prompt logic from existing prompt sources and seed persona skill documents for supported output profiles. The migrated data MUST preserve enough metadata to explain which legacy source produced each new document.

#### Scenario: Backfill an existing questionnaire prompt
- **Given** a questionnaire currently depends on a legacy survey prompt or hardcoded survey writer prompt
- **When** the migration runs
- **Then** the system MUST create or map a corresponding `QuestionnairePrompts` document
- **And** it MUST retain traceability to the legacy source used for the backfill

#### Scenario: Seed the school report persona
- **Given** the prompt-storage migration is executed
- **When** persona skills are seeded
- **Then** the system MUST create a `PersonaSkills` document for the school report output profile
- **And** that persona skill MUST be editable independently after migration

