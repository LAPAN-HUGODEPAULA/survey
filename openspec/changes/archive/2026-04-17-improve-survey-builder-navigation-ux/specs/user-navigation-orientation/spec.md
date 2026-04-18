## ADDED Requirements

### Requirement: Builder administration flows MUST provide explicit home and parent context
Builder administration flows MUST provide persistent orientation cues such as breadcrumbs, contextual back actions, or section identifiers so administrators always understand where they are and how to return.

#### Scenario: Admin enters a nested editor from a catalog
- **WHEN** an admin opens a survey, prompt, or persona editor from its catalog
- **THEN** the editor MUST display the parent section context
- **AND** it MUST provide a clear action to return to the catalog or home shell

#### Scenario: Admin lands on a deep-linked builder route
- **WHEN** an admin opens a deep-linked builder route directly
- **THEN** the page MUST still render enough orientation cues to explain the active section and available return path
- **AND** it MUST not assume the browser back stack is available
