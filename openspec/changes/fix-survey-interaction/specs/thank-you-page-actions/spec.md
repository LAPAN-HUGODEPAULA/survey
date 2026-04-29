## ADDED Requirements

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
