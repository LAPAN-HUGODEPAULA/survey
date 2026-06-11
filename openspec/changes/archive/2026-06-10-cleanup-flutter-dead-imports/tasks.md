## 1. Preparation and Audit

- [x] 1.1 Run baseline `flutter analyze` across all apps to confirm the starting state and count of unused imports.

## 2. Clinical Narrative App Cleanup

- [x] 2.1 Navigate to `apps/clinical-narrative` and run `dart fix --apply` to remove unused imports.
- [x] 2.2 Execute `flutter analyze` in `apps/clinical-narrative` and verify zero unused import warnings.

## 3. Survey Builder App Cleanup

- [x] 3.1 Navigate to `apps/survey-builder` and run `dart fix --apply` to remove unused imports.
- [x] 3.2 Execute `flutter analyze` in `apps/survey-builder` and verify zero unused import warnings.

## 4. Survey Frontend App Cleanup

- [x] 4.1 Navigate to `apps/survey-frontend` and run `dart fix --apply` to remove unused imports.
- [x] 4.2 Execute `flutter analyze` in `apps/survey-frontend` and verify zero unused import warnings.

## 5. Survey Patient App Cleanup

- [x] 5.1 Navigate to `apps/survey-patient` and run `dart fix --apply` to remove unused imports.
- [x] 5.2 Execute `flutter analyze` in `apps/survey-patient` and verify zero unused import warnings.

## 6. Final System-Wide Validation

- [x] 6.1 Execute the global validation script to ensure all four apps pass `flutter analyze`.
- [x] 6.2 Perform a quick verification of app functionality to ensure no regressions were introduced.
