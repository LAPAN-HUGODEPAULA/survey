## MODIFIED Requirements

### Requirement: Radar visualization uses question labels and color
The thank-you radar MUST read from the question-level `label` metadata and render values on a fixed `0..3` range. The response-to-score mapping MUST be: `Quase nunca=0`, `Ocasionalmente=1`, `Frequentemente=2`, `Quase sempre=3`. When a question lacks a label, the radar SHALL fall back to `Q1`, `Q2`, etc., to avoid blank fields. Radar labels MUST include contrast-backed rendering (for example, darker label backgrounds with light text) so axis names remain readable.

#### Scenario: Radar renders mapped labeled data
- **WHEN** a thank-you screen renders survey responses with question labels
- **THEN** each radar axis MUST use the fixed `0..3` range with the defined option-to-score mapping
- **AND** the chart MUST color each spoke distinctly and surface the provided label near the axis or legend
- **AND** the chart SHALL not show raw question IDs such as `Q3` when labels are available

#### Scenario: Radar handles missing labels
- **WHEN** a question definition does not supply a label
- **THEN** the radar MUST render that axis as `Q<number>` (e.g., `Q4`) while still coloring the spoke
- **AND** the UI MAY prompt administrators to add labels in the builder for future deployments

#### Scenario: Radar labels remain readable on chart backgrounds
- **WHEN** radar labels are rendered over multicolor chart regions
- **THEN** label foreground and background treatment MUST provide high contrast readability
- **AND** the same readability treatment MUST be applied in both `survey-patient` and `survey-frontend`
