## Why

The psychiatric medication input is currently a single-line `TextFormField` that stores one free-text string. Patients on multiple prescriptions cannot enter all their medications, and free-text input produces unstandardized data that hampers clinical analysis. The platform already has a curated ANVISA Portaria 344 medication reference list in CSV format but doesn't use it. Transitioning to a multi-select autocomplete with chips will standardize data, support multiple prescriptions, and improve UX across both `survey-patient` and `survey-frontend`.

## What Changes

- **New shared Flutter component**: Replace the single `TextFormField` with a multi-select autocomplete widget (`DsMedicationAutocompleteField`) in `packages/design_system_flutter` that queries a backend search endpoint and renders selected medications as removable chips
- **New backend collection `reference_medications`**: Import the CSV data (substance, category, trade names) and expose a search API endpoint
- **New API endpoint `GET /v1/medications/search`**: Fuzzy search against substance names and common trade names
- **New API endpoint `PATCH /v1/patients/{id}/medications`**: Update medication array with `$addToSet`/`$pull` operations
- **Update `DsDemographicsFormController`**: Change `medication` from `String` to `List<String>`, replace `medicationNameController` (single `TextEditingController`) with a `List<String>` of selected medications
- **Update `DsDemographicsSubmission`**: Change `medication` field from `String` to `List<String>`
- **Update `DsSurveyDemographicsSection`**: Replace the medication `TextFormField` with the new autocomplete component
- **Support manual entry**: Allow users to add custom medication names not in the reference list, tagged as "unverified"
- **Seed script**: Import CSV data into the `reference_medications` MongoDB collection

## Capabilities

### New Capabilities
- `medication-reference-data`: Backend storage and seeding of the ANVISA medication reference list with search API
- `medication-autocomplete-component`: Shared Flutter multi-select autocomplete widget with chip display and manual entry support
- `medication-api-endpoints`: REST endpoints for medication search and patient medication array updates

### Modified Capabilities
- `shared-flutter-component-library`: `DsDemographicsFormController`, `DsDemographicsSubmission`, and `DsSurveyDemographicsSection` medication handling changes from single-string to multi-selection
- `patient-survey-flow`: Demographics form now uses multi-select medication input instead of free-text

## Impact

- **packages/design_system_flutter**: `respondent_flow_models.dart`, `ds_demographics_form_controller.dart`, `ds_survey_demographics_section.dart`, new widget file for autocomplete
- **apps/survey-patient**: `demographics_page.dart` (minor wiring changes), `patient.dart` model already supports `List<String>`
- **apps/survey-frontend**: `demographics_page.dart` (same minor wiring changes)
- **services/survey-backend**: New route file, new repository, new seed script, new collection index
- **Database**: New `reference_medications` collection; existing `patient_responses` medication field already stores `List[str]`
- **OpenAPI contracts**: New medication search and patient medication update endpoints
