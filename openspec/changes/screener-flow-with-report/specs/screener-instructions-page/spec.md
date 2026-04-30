## ADDED Requirements

### Requirement: survey-frontend MUST use a shared instructions section component
The "Instruções" page in `survey-frontend` SHALL reuse the same shared instructions section implementation already used in `survey-patient`, instead of maintaining duplicated page-specific logic.

#### Scenario: Screener instructions page reuses shared implementation
- **WHEN** the screener opens the "Instruções" page
- **THEN** the instructions content MUST be rendered through the shared component from `packages/design_system_flutter`
- **AND** behavioral parity with `survey-patient` MUST be maintained

### Requirement: Instructions confirmation section MUST be vertically scrollable
The "Confirme as instruções" section SHALL always remain reachable on small screens through vertical scrolling.

#### Scenario: Instructions exceed viewport height
- **WHEN** the content height of the instructions screen exceeds the viewport height
- **THEN** the page MUST allow vertical scrolling
- **AND** all controls in the "Confirme as instruções" section MUST remain accessible
- **AND** no fixed-height clipping may prevent progression
