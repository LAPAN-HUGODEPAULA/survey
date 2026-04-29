## Context

The current medication input in the demographics form is a single `TextFormField` bound to `DsDemographicsFormController.medicationNameController`. On submit, it produces a single string in `DsDemographicsSubmission.medication` which gets assigned to `Patient.medication` (already `List<String>`). The backend `Patient` model expects `List[str]`.

The CSV at `apps/survey-patient/assets/data/psychiatric_medications_list.csv` contains 32 rows with columns: `Substance`, `Category`, `Common Trade Names` (semicolon-separated). This data needs to be loaded into a new `reference_medications` MongoDB collection.

Both `survey-patient` and `survey-frontend` use the shared `DsSurveyDemographicsSection` and `DsDemographicsFormController` from `packages/design_system_flutter`, so all changes must live in the shared package.

## Goals / Non-Goals

**Goals:**
- Multi-select medication input with autocomplete against the ANVISA reference list
- Backend search endpoint seeded from CSV data (substance + trade names)
- Shared Flutter component usable by both apps
- Support for manual/custom medication entry not in the reference list
- Proper array-based storage throughout the pipeline

**Non-Goals:**
- Modifying the `Patient` Dart model (already supports `List<String>`)
- Modifying the backend `Patient` Python model (already expects `List[str]`)
- Changing how survey responses are submitted (only demographics medication field changes)
- Adding medication dosage, frequency, or schedule fields
- Offline-first or cached medication search (online API call only)

## Decisions

### D1: Flutter autocomplete approach

Use Flutter's built-in `RawAutocomplete<String>` combined with `InputChip` for selected items. This avoids adding a third-party dependency. The widget will:
1. Show a `TextField` for typing
2. After 3+ characters, call the search API
3. Render matching suggestions in an overlay
4. On selection, add to a `List<String>` and render an `InputChip` below the field
5. Provide an "Adicionar manualmente" option when no results match, allowing free-text entry tagged as unverified

**Alternatives considered:**
- `flutter_typeahead` package: Adds dependency; `RawAutocomplete` covers the same use case
- `Autocomplete` widget: Too limited for chip-based multi-select display
- Full custom overlay: More code, same result as `RawAutocomplete`

### D2: Search API design

Create `GET /v1/medications/search?q={query}&limit={limit}` with server-side substring matching (case-insensitive) against both `substance` and `search_vector` fields. Default limit: 10 results. No authentication required for this endpoint (it's a public reference lookup).

The `search_vector` array in `reference_medications` will contain: the substance name (lowercased), the category string, and all trade names (lowercased, split by semicolons). This enables a simple `$or` query with `$regex` on the array elements.

### D3: Medication data model in reference collection

```json
{
  "_id": ObjectId,
  "substance": "Amitriptilina",
  "category": "C1 (Antidepressivo)",
  "trade_names": ["Amytril", "Tryptanol"],
  "search_vector": ["amitriptilina", "c1 (antidepressivo)", "amytril", "tryptanol"]
}
```

Pre-computing `search_vector` at seed time avoids runtime string splitting. A text index on `search_vector` enables fast queries.

### D4: Manual entry handling

When the user types text that produces no search results and presses Enter, the widget shows a small "Adicionar '{text}' manualmente" action. On confirm, the medication is added with a special `_unverified: true` flag in the submission. On the backend, unverified medications are stored in the same `medication` array with no reference link.

The `DsDemographicsSubmission.medication` changes from `String` to `List<String>`. Unverified entries are indistinguishable in the stored list (the UI chip uses a distinct style during editing only).

### D5: Seeding strategy

Create a management script at `services/survey-backend/tools/seed_reference_medications.py` that:
1. Reads the CSV from `apps/survey-patient/assets/data/psychiatric_medications_list.csv`
2. Parses each row into the reference document format
3. Upserts into MongoDB using `update_one` with `upsert=True` on `substance` field
4. Creates a text index on `search_vector` if not exists

This script is run manually or via CI, not on every app startup.

### D6: DsDemographicsFormController changes

- Remove `medicationNameController` (`TextEditingController`)
- Add `selectedMedications` (`List<String>`) with add/remove methods
- Add `onMedicationChanged` callback for chip-level updates
- `DsDemographicsSubmission.medication` becomes `List<String>`
- Validation: when `usesMedication == 'Sim'`, `selectedMedications` must not be empty

### D7: No PATCH endpoint for this change

The user request mentions `PATCH /v1/patients/{id}/medications`, but the current flow creates a new survey response (POST) rather than updating an existing patient. The medication array is part of the `Patient` model embedded in `SurveyResponse`, not a standalone patient record. Therefore:
- The search endpoint (`GET /v1/medications/search`) is needed for the autocomplete
- The medication list is submitted as part of the existing `POST /v1/patient_responses/` flow
- No separate PATCH endpoint is needed unless a standalone patient management feature is added later

## Risks / Trade-offs

- [CSV data may become stale] → Medication reference list is based on ANVISA Portaria 344; provide a re-seed script that can be run when the list is updated
- [Search latency for large datasets] → 32 medications is tiny; text index ensures sub-millisecond queries even if the list grows to hundreds
- [Unverified medications pollute data quality] → UI clearly distinguishes verified vs unverified during editing; analytics can filter by reference lookup
- [Breaking change to `DsDemographicsSubmission` API] → Both consuming apps must update their demographics pages to pass the new parameters
