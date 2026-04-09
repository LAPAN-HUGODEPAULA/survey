# ai-insight-panel-standard Specification

## Purpose
TBD - created by archiving change cr-ux-008-conversational-ai-visibility. Update Purpose after archive.
## Requirements
### Requirement: Typed Insight Panels
Every AI-generated insight SHALL be presented in a card that clearly identifies its severity and type (suggestion, warning, hypothesis).

#### Scenario: View AI suggestion
- **WHEN** the AI generates a clinical conduct suggestion
- **THEN** the system displays a card with `severity=info`, icon `lightbulb_outline`, and title "Sugestão do Assistente"
- **AND** uses Brazilian Portuguese (pt-BR)

### Requirement: Visual Severity of Insights
Insight cards SHALL use colors and icons consistent with the platform's feedback taxonomy (`info`, `success`, `warning`, `error`).

#### Scenario: View clinical alert
- **WHEN** the AI detects a clinical inconsistency or risk (e.g., warning sign)
- **THEN** the system displays a card with `severity=warning`, icon `warning_amber_rounded`, and title "Alerta Clínico"

