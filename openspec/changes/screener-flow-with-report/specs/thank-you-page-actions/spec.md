## MODIFIED Requirements

### Requirement: Thank-you page MUST offer a "Gerar Relatório" action in survey-frontend
The screener `thank_you_page.dart` SHALL include a secondary action titled "Gerar Relatório" that mirrors the behavior and visual hierarchy used in `survey-patient`.

#### Scenario: Screener sees report generation action
- **WHEN** the screener arrives at the thank-you page after completing a questionnaire
- **THEN** both actions "Adicionar informações" and "Gerar Relatório" MUST be visible
- **AND** the "Gerar Relatório" action MUST use the same interaction pattern as `survey-patient`

#### Scenario: Screener starts report flow
- **WHEN** the screener taps "Gerar Relatório"
- **THEN** the app MUST navigate to `report_page.dart`
- **AND** the report flow MUST carry the completed survey context needed for document generation
