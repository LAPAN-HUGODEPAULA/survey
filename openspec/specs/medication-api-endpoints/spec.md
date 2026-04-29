# medication-api-endpoints Specification

## Purpose
Define the medication reference search API for the LAPAN Survey Platform.

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
