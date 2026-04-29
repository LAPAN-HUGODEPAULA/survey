## ADDED Requirements

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
