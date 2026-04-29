## ADDED Requirements

### Requirement: Report page MUST provide back navigation to thank-you page
`ReportPage` SHALL include a back button that navigates to the thank-you page (`ThankYouPage`). The `DsScaffold.onBack` MUST pop to the thank-you page route, and `backLabel` MUST read "Voltar".

#### Scenario: User taps back on report page
- **WHEN** a user is on the report page and taps the back button
- **THEN** the system MUST navigate to the thank-you page
- **AND** the back button label MUST read "Voltar"

### Requirement: Report page MUST provide a restart-survey action
`ReportPage` SHALL display a full-width "Iniciar nova avaliação" button at the bottom of the page. This button MUST accept an `onRestartSurvey` callback that resets the assessment flow and navigates to the entry gate, identical to the behavior on `thank_you_page.dart`.

#### Scenario: User restarts survey from report page
- **WHEN** a user taps "Iniciar nova avaliação" on the report page
- **THEN** the system MUST clear the previous response state, agent data, and patient legal-notice acknowledgement
- **AND** the system MUST navigate to the initial notice screen
- **AND** the button styling MUST match the equivalent button on `thank_you_page.dart`
