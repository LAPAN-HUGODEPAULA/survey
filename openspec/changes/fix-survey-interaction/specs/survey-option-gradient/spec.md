## ADDED Requirements

### Requirement: Survey option buttons MUST use directional gradient fills
Each `SurveyOptionButton` SHALL render its background as a `LinearGradient` from `Alignment.topLeft` to `Alignment.bottomRight`. The top-left color SHALL be the base palette color, and the bottom-right color SHALL be the base color darkened by approximately 12% lightness. This gradient MUST apply across `survey-patient`, `survey-frontend`, and `survey-builder`.

#### Scenario: User views survey option buttons
- **WHEN** a survey presents option buttons via `SurveyOptionButton`
- **THEN** each button MUST display a top-left-to-bottom-right gradient using its assigned palette color
- **AND** all three apps MUST produce visually identical button styling

#### Scenario: User selects an option button
- **WHEN** a user taps an option button and it enters the selected state
- **THEN** the gradient MUST remain visible with the white border overlay
- **AND** the gradient direction and depth MUST NOT change between selected and unselected states
