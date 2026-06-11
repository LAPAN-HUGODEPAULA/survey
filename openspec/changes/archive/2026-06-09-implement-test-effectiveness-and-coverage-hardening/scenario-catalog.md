# Scenario Catalog for Uncovered Criteria

## 1. AI Progress API Contract
- **Criterion**: `ai-progress-api-contract: Frontend polls for job status`
  - **Scenario**: Validate that a GET request to `statusUrl` returns correctly formatted progress updates including `status` and `stage`.
- **Criterion**: `ai-progress-api-contract: Delayed and sparse polling for high-latency AI tasks`
  - **Scenario**: Ensure the client implements exponential backoff or respects `Retry-After` headers for long-running AI jobs.

## 2. Shared Flutter Components (Design System)
- **Criterion**: `shared-flutter-component-library: Shared Legal Reader and Acknowledgement Surfaces`
  - **Scenario**: Verify that the `DsLegalReader` component correctly displays terms and handles the acknowledgement checkbox/button state.
- **Criterion**: `shared-flutter-component-library: Shared respondent status metadata MUST meet high contrast thresholds`
  - **Scenario**: Accessibility test to verify WCAG contrast ratios for status indicators on different backgrounds.
- **Criterion**: `shared-flutter-component-library: Shared section containers MUST support vertical scrolling`
  - **Scenario**: Widget test ensuring that `DsSectionContainer` becomes scrollable when content height exceeds viewport.

## 3. Medication Autocomplete
- **Criterion**: `medication-autocomplete-component: User adds a manual medication and leaves the field`
  - **Scenario**: Verify that free-text input for medications is correctly captured when not found in the reference catalog.
- **Criterion**: `medication-autocomplete-component: Autocomplete widget MUST integrate with DsDemographicsFormController`
  - **Scenario**: Integration test ensuring that selecting a medication update the `DsDemographicsFormController` state.

## 4. Survey Respondent Flow
- **Criterion**: `patient-survey-flow: User accesses full survey content on low-resolution devices`
  - **Scenario**: Responsive design test verifying that all survey elements are reachable and visible on small screen sizes.
- **Criterion**: `patient-survey-flow: User views the specialist link on thank-you page`
  - **Scenario**: Verify that the external specialist link is rendered and has the correct `href`.
