## ADDED Requirements

### Requirement: Add Screener Initial Notice Agreement Field
Migration scripts MUST add the platform-wide screener legal-notice acknowledgement field without losing existing screener data.

#### Scenario: Run migration on an existing screeners collection
- **WHEN** the migration executes against a database that already contains screener documents
- **THEN** the migration MUST add the nullable `initialNoticeAcceptedAt` field to legacy screener records
- **AND** existing screener data MUST remain intact

#### Scenario: Run migration after some screeners already have an acknowledgement date
- **WHEN** the migration executes against a database that already contains `initialNoticeAcceptedAt` values
- **THEN** the migration MUST preserve the stored acknowledgement dates
- **AND** it MUST remain safe to run without overwriting previously accepted records
