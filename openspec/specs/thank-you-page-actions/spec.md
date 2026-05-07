# thank-you-page-actions Specification

## Purpose
Refine the thank-you page actions by removing redundant text summaries and providing a direct path to report generation.

## Requirements

### Requirement: Thank-you page MUST NOT display text-based answer summary
The thank-you page SHALL remove the "Resumo das respostas" section that renders individual question-answer pairs in `DsFocusFrame` cards. The radar chart and legend chips MUST remain.

#### Scenario: User views thank-you page after survey completion
- **WHEN** a user completes the survey and arrives at the thank-you page
- **THEN** the page MUST display the radar chart and legend chips
- **AND** the page MUST NOT display the "Resumo das respostas" text list with individual answer cards

### Requirement: Thank-you page MUST offer a "Gerar relatório" action
The `DsHandoffFork` on the thank-you page SHALL include a second action titled "Gerar relatório" alongside the existing "Adicionar informações" action. The "Gerar relatório" action MUST navigate to the report page.

#### Scenario: User generates report from thank-you page
- **WHEN** a user is on the thank-you page and taps "Gerar relatório"
- **THEN** the system MUST navigate to the report page with the current survey, answers, and questions
- **AND** both "Adicionar informações" and "Gerar relatório" MUST be visible simultaneously in the handoff fork

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

### Requirement: Screener thank-you page MUST display a preliminary AI assessment
The thank-you page in `survey-frontend` SHALL include a `DsSection` titled "Avaliação preliminar" that displays an AI-generated summary using the access point "Análise automática do questionário profissional" (`survey_frontend.thank_you.auto_analysis`).

#### Scenario: Preliminary assessment loads after survey completion
- **WHEN** the screener completes a survey and arrives at the thank-you page
- **THEN** the system MUST trigger the auto-analysis access point
- **AND** the "Avaliação preliminar" section MUST show a loading state with label "Análise preliminar em preparo"

#### Scenario: Preliminary assessment is displayed
- **WHEN** the AI agent finishes processing the survey
- **THEN** the "Avaliação preliminar" section MUST display the agent's summary text in a clinical content container

### Requirement: Screener thank-you page MUST NOT display colored question labels in radar section
The "Radar das respostas" `DsSection` SHALL display the radar chart and legend chips without colored question labels.

#### Scenario: User views radar without colored labels
- **WHEN** the user completes the survey in survey-frontend
- **THEN** the radar chart MUST be visible
- **AND** question labels MUST NOT be displayed alongside the chart

### Requirement: Screener pages MUST display centered titles in AppBar
Each screener page MUST display a centered title in the AppBar.

#### Scenario: User navigates screener flow
- **WHEN** the user moves between demographics and report pages
- **THEN** each page AppBar MUST show a centered title

