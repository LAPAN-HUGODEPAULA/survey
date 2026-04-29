## 1. Backend: Reference Medications Collection & Seed Script

- [x] 1.1 Create seed script `services/survey-backend/tools/seed_reference_medications.py` that reads the CSV from `apps/survey-patient/assets/data/psychiatric_medications_list.csv`, parses each row into `{substance, category, trade_names, search_vector}`, and upserts into MongoDB
- [x] 1.2 Run the seed script against the local MongoDB instance to populate `reference_medications`
- [x] 1.3 Verify text index on `search_vector` is created by the seed script

## 2. Backend: Medication Search API Endpoint

- [x] 2.1 Create domain model `services/survey-backend/app/domain/models/reference_medication_model.py` with fields: `substance`, `category`, `trade_names`, `search_vector`
- [x] 2.2 Create repository `services/survey-backend/app/persistence/repositories/reference_medication_repo.py` with a `search(query, limit)` method using case-insensitive substring matching on `search_vector`
- [x] 2.3 Create route file `services/survey-backend/app/api/routes/medications.py` with `GET /v1/medications/search?q={query}&limit={limit}` (default limit 10, min query length 3)
- [x] 2.4 Register the medications router in the main FastAPI app (ensure it's publicly accessible, no auth required)
- [x] 2.5 Add `get_reference_medication_repo` dependency in `services/survey-backend/app/persistence/deps.py`

## 3. Shared Flutter Component: Medication Autocomplete Widget

- [x] 3.1 Create `packages/design_system_flutter/lib/components/forms/ds_medication_autocomplete_field.dart` using `RawAutocomplete<String>` with chip display (`InputChip`) for selected medications
- [x] 3.2 Implement API call to `GET /v1/medications/search` triggered after 3+ characters, with debouncing (300ms)
- [x] 3.3 Implement "Nenhum medicamento encontrado." empty state with "Adicionar manualmente" action for free-text entry
- [x] 3.4 Visually distinguish unverified (manually entered) chips from verified chips during editing
- [x] 3.5 Export the widget from `packages/design_system_flutter/lib/components/forms/ds_validated_fields.dart` or appropriate barrel file

## 4. Shared Flutter Component: Form Controller & Model Updates

- [x] 4.1 Update `DsDemographicsSubmission` in `respondent_flow_models.dart`: change `medication` from `String` to `List<String>`
- [x] 4.2 Update `DsDemographicsFormController`: remove `medicationNameController`, add `selectedMedications` (`List<String>`), `addMedication(String)`, `removeMedication(String)` methods
- [x] 4.3 Update `DsDemographicsFormController.submit()` to return `medication: selectedMedications` when `usesMedication == 'Sim'`, empty list otherwise
- [x] 4.4 Update validation in `_buildValidationItems()`: when `usesMedication == 'Sim'`, validate that `selectedMedications` is not empty instead of checking `medicationNameController.text`
- [x] 4.5 Update `DsSurveyDemographicsSection`: replace the `DsValidatedTextFormField` medication input with `DsMedicationAutocompleteField`, passing `selectedMedications`, `onMedicationAdded`, and `onMedicationRemoved` callbacks

## 5. App Integration: survey-patient & survey-frontend

- [x] 5.1 Update `apps/survey-patient/lib/features/demographics/pages/demographics_page.dart` to wire the new medication autocomplete callbacks to the demographics controller
- [x] 5.2 Update `apps/survey-frontend/lib/features/demographics/pages/demographics_page.dart` with the same wiring changes
- [x] 5.3 Verify `Patient` model in `apps/survey-patient` (already `List<String>`) receives the list correctly from demographics submission

## 6. Verification

- [x] 6.1 Run backend seed script and verify `reference_medications` collection has 32 documents with correct structure
- [x] 6.2 Test medication search API: query by substance ("sertralina") and by trade name ("zoloft"), verify both return results
- [x] 6.3 Run Flutter tests in `packages/design_system_flutter`
- [x] 6.4 Run Flutter tests in `apps/survey-patient`
- [x] 6.5 Manual smoke test: complete demographics form in survey-patient, add 2+ medications (1 from autocomplete, 1 manual), verify chips render, verify submission contains correct array
