# Medications Search & Components Specification

## Purpose
Consolidates reference medication data seeds, autocomplete multi-select dropdowns, and search APIs.

## Requirements
### Requirement: System MUST provide a medication search endpoint
The API SHALL expose `GET /v1/medications/search?q={query}&limit={limit}` that returns matching medications from the `reference_medications` collection.

#### Scenario: User searches for a known medication by substance
- **WHEN** a client sends `GET /v1/medications/search?q=sertralina`
- **THEN** the system MUST return documents where `search_vector` matches the query (case-insensitive substring)
- **AND** the response MUST include `substance`, `category`, and `trade_names` fields
- **AND** the default limit MUST be 10 results

#### Scenario: User searches by trade name
- **WHEN** a client sends `GET /v1/medications/search?q=zoloft`
- **THEN** the system MUST return the document for "Sertralina" because "zoloft" is in its `search_vector`

#### Scenario: Search with fewer than 3 characters
- **WHEN** a client sends a search query with fewer than 3 characters
- **THEN** the system MUST return an empty results list without querying the database

#### Scenario: Search with no matches
- **WHEN** a client sends a search query that matches no medications
- **THEN** the system MUST return an empty results list with HTTP 200

### Requirement: Medication search endpoint MUST NOT require authentication
The `GET /v1/medications/search` endpoint SHALL be publicly accessible since it serves reference data for patient-facing forms.

#### Scenario: Unauthenticated search request
- **WHEN** a client calls the search endpoint without authentication credentials
- **THEN** the system MUST return results with HTTP 200

### Requirement: Shared package MUST provide a multi-select medication autocomplete widget
`packages/design_system_flutter` SHALL export a `DsMedicationAutocompleteField` widget that combines a text input with chip display for selected medications and MUST use in-memory search during typing.

#### Scenario: Widget loads medication catalog once and filters in memory
- **WHEN** the medication field receives focus for the first time
- **THEN** the widget MUST request the complete medication catalog once
- **AND** all subsequent search suggestions during the same session MUST be resolved locally in memory without per-keystroke API calls

#### Scenario: User types to search medications
- **WHEN** the user types in the autocomplete field after the local catalog is loaded
- **THEN** matching results MUST appear from a case-insensitive local filter
- **AND** no additional network request MUST be made for each key typed

#### Scenario: User adds a manual medication and leaves the field
- **WHEN** the user adds a medication that is not present in the catalog
- **THEN** the medication MUST be added to the local in-memory list immediately
- **AND** the UI MUST remain responsive without waiting for server confirmation
- **AND** persistence to the backend MUST be triggered asynchronously when the field loses focus

#### Scenario: Async persistence fails
- **WHEN** async persistence of a new medication fails
- **THEN** the local medication MUST remain available in the current form session
- **AND** the system MUST register a retryable error state for background retry or user feedback

### Requirement: Autocomplete widget MUST integrate with DsDemographicsFormController
The widget SHALL accept a `List<String>` of selected medications and callbacks for add/remove operations, compatible with the form controller's state management.

#### Scenario: Widget receives initial medications
- **WHEN** the widget is rendered with a pre-populated list of medications
- **THEN** all pre-selected medications MUST appear as chips

### Requirement: Backend MUST store a reference medication catalog
The system SHALL maintain a `reference_medications` MongoDB collection with documents containing `substance` (String), `category` (String), `trade_names` (List<String>), and `search_vector` (List<String>).

#### Scenario: Reference medication document structure
- **WHEN** a medication is stored in `reference_medications`
- **THEN** the document MUST contain `substance` as a unique string field
- **AND** the document MUST contain `category` as a string (e.g., "C1 (Antidepressivo)")
- **AND** the document MUST contain `trade_names` as an array of strings
- **AND** the document MUST contain `search_vector` as an array of lowercased strings including the substance name and all trade names

### Requirement: System MUST provide a seed script for reference medications
A management script SHALL read the CSV file at `apps/survey-patient/assets/data/psychiatric_medications_list.csv` and upsert documents into `reference_medications`.

#### Scenario: Seeding from CSV
- **WHEN** the seed script is executed
- **THEN** each CSV row MUST be parsed into a reference document with substance, category, trade_names, and search_vector
- **AND** documents MUST be upserted using the `substance` field as the unique key
- **AND** a text index on `search_vector` MUST be created if it does not exist

#### Scenario: Re-seeding after CSV update
- **WHEN** the seed script is run again with an updated CSV
- **THEN** existing documents MUST be updated and new documents MUST be inserted
- **AND** documents for removed substances MUST remain in the collection until manually pruned
