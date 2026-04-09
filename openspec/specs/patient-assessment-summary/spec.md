# patient-assessment-summary Specification

## Purpose
TBD - created by archiving change update-assessment-workflow. Update Purpose after archive.
## Requirements
### Requirement: Avaliação preliminar card surfaces agent findings inline
The thank-you screen SHALL render a card titled **Avaliação preliminar** that displays the latest agent response directly. It SHALL follow a three-step handoff model:
1. **Respostas registradas**: Confirming data persistence.
2. **Análise em preparo**: Showing a loading indicator while the agent reply is pending.
3. **Relatório disponível**: Displaying the agent findings.
The card SHALL visually separate system status messages (e.g., "Processando...") from the clinical content once available. It SHALL include the “Adicionar informações” action that navigates to the demographic/report workflow.

#### Scenario: Agent result is available (Handoff Step 3)
- **WHEN** the thank-you screen reaches the final handoff stage and the agent response finishes successfully
- **THEN** the **Avaliação preliminar** card MUST display the agent text (e.g., a summary paragraph, insights, or flags) in a distinct clinical content container
- **AND** the “Adicionar informações” button MUST remain visible below the agent text

#### Scenario: Agent result is still running (Handoff Step 2)
- **WHEN** the thank-you screen loads and the responses are already registered but the agent response is pending
- **THEN** the **Avaliação preliminar** card MUST show a spinner and the stage label "Análise preliminar em preparo" in a functional status container
- **AND** it MUST prevent the agent text from being shown until the request completes

#### Scenario: Agent request fails
- **WHEN** the agent request returns an error or times out during Step 2
- **THEN** the **Avaliação preliminar** card MUST show an inline error banner (e.g., “Não foi possível obter a avaliação preliminar.”)
- **AND** the “Adicionar informações” action MUST still be available so the patient can continue

### Requirement: Radar visualization uses question labels and color
The thank-you radar MUST read from the question-level `label` metadata and color each spoke with a palette that makes the chart visually modern and legible. When a question lacks a label, the radar SHALL fall back to `Q1`, `Q2`, etc., to avoid blank fields. The chart SHALL also display the label text inside tooltips, legends, or directly on the spokes so patients understand what each axis represents.

#### Scenario: Radar renders labeled data
- **WHEN** the survey includes question labels
- **THEN** the radar MUST color each spoke distinctly and surface the provided label near the axis or legend
- **AND** the chart SHALL not show raw question IDs such as “Q3”

#### Scenario: Radar handles missing labels
- **WHEN** a question definition does not supply a label
- **THEN** the radar MUST render that axis as `Q<number>` (e.g., `Q4`) while still coloring the spoke
- **AND** the UI MAY prompt administrators to add labels in the builder for future deployments

### Requirement: “Iniciar nova avaliação” resets the session
The thank-you screen SHALL offer an “Iniciar nova avaliação” button that clears the patient app’s in-memory survey and response state, including any temporary tokens, and navigates back to the public welcome screen so a new respondent can start fresh without reloading the browser.

#### Scenario: Patient starts another assessment
- **WHEN** the user taps “Iniciar nova avaliação”
- **THEN** the app MUST clear stored answers, agent response state, and navigation history related to the completed survey
- **AND** it MUST navigate to the patient welcome page so a new token or link can be entered

