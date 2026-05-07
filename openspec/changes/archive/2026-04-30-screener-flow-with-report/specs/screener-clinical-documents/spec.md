## ADDED Requirements

### Requirement: System MUST expose screener preliminary analysis access point defaults
The access point "Análise automática do questionário profissional" (key `survey_frontend.thank_you.auto_analysis`) SHALL remain available for screener flows and MUST default to prompt `triagem de pacientes` and persona `patient_condition_overview`.

#### Scenario: Preliminary analysis access point defaults are resolved
- **WHEN** the screener thank-you page requests automatic preliminary analysis
- **THEN** the system MUST resolve the configured access point for `survey_frontend.thank_you.auto_analysis`
- **AND** if no custom override exists, the default prompt MUST be `triagem de pacientes`
- **AND** if no custom override exists, the default persona MUST be `patient_condition_overview`

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens access point management in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `survey_frontend.thank_you.auto_analysis` for configuration
- **AND** admin updates MUST persist without requiring backend code changes

### Requirement: System MUST provide a detailed report access point for survey-frontend
The backend SHALL seed an access point with key `screener.report.detailed_analysis` that uses the `full_intake` prompt and `clinical_diagnostic_report` persona. This access point is used by the "Gerar Relatório" button on the screener thank-you page.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "screener.report.detailed_analysis"`
- **AND** `promptKey` MUST be `"full_intake"`
- **AND** `personaSkillKey` MUST be `"clinical_diagnostic_report"`
- **AND** `outputProfile` MUST be `"clinical_diagnostic_report"`

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `screener.report.detailed_analysis` as a configurable entry
- **AND** the admin MUST be able to select it from the injection point dropdown

### Requirement: System MUST provide a clinical referral letter access point
The backend SHALL seed an access point with key `screener.document.clinical_referral` for generating clinical referral letters.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "screener.document.clinical_referral"`
- **AND** the access point MUST be bound to an appropriate prompt and persona for clinical referral letter generation

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `screener.document.clinical_referral` as a configurable entry

### Requirement: System MUST provide a school referral letter access point
The backend SHALL seed an access point with key `screener.document.school_referral` for generating school referral letters.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "screener.document.school_referral"`
- **AND** the access point MUST be bound to an appropriate prompt and persona for school referral letter generation

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `screener.document.school_referral` as a configurable entry

### Requirement: System MUST provide a parent orientation letter access point
The backend SHALL seed an access point with key `screener.document.parent_orientation` for generating parent orientation letters.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "screener.document.parent_orientation"`
- **AND** the access point MUST be bound to an appropriate prompt and persona for parent orientation letter generation

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `screener.document.parent_orientation` as a configurable entry

### Requirement: survey-builder MUST handle new screener access points gracefully
When an admin configures the new screener access points, the survey-builder SHALL support both create and update modes.

#### Scenario: Admin creates a new screener access point
- **WHEN** an admin selects a screener injection point that does not yet exist in the database
- **THEN** the survey-builder MUST use POST to create the access point

#### Scenario: Admin updates an existing screener access point
- **WHEN** an admin selects a screener injection point that already exists
- **THEN** the survey-builder MUST detect the existing record
- **AND** the survey-builder MUST use PUT to update instead of POST
- **AND** the form MUST NOT show a 409 error
