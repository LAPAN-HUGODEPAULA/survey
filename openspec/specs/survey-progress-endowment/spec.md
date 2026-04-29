# survey-progress-endowment Specification

## Purpose
Enhance the survey progress indicator with an endowment effect to increase completion rates and ensure visibility throughout the assessment.

## Requirements

### Requirement: Progress indicator MUST support endowment-effect denominator
`DsSurveyProgressIndicator` SHALL accept an optional `includeSuccessPage` parameter (default `false`). When `true`, the denominator MUST be `total + 1` to treat the success page as the final milestone.

#### Scenario: Progress bar with endowment mode enabled
- **WHEN** `includeSuccessPage` is `true` and there are N questions
- **THEN** the denominator MUST be `N + 1`
- **AND** on the first question (index 0) the progress MUST be `1 / (N+1)` (approximately 5% for typical surveys)
- **AND** on the last question (index N-1) the progress MUST be `N / (N+1)` (approximately 90-95%)

#### Scenario: Progress bar reaches 100% only on success
- **WHEN** the user completes the last question and the flow transitions to the success/thank-you page
- **THEN** the progress indicator MUST display 100%
- **AND** the progress MUST NOT reach 100% while the user is still answering questions

#### Scenario: Backward compatibility when flag is not set
- **WHEN** `includeSuccessPage` is `false` or not provided
- **THEN** the progress indicator MUST use the original formula `(currentIndex + 1) / total`

### Requirement: Progress indicator MUST enforce a minimum visible progress
When `includeSuccessPage` is `true`, the progress value MUST be clamped to a minimum of `0.02` (2%) to ensure the bar is always visible, even on the first question.

#### Scenario: Minimum progress on first question
- **WHEN** a survey has many questions and `includeSuccessPage` is `true`
- **THEN** the progress bar on the first question MUST show at least 2% fill
- **AND** the bar MUST NOT appear empty at any point during the survey
