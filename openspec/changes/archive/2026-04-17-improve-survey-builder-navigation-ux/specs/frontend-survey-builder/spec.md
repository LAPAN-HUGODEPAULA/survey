## ADDED Requirements

### Requirement: Survey-builder MUST provide a stable administrative home and section entry points
The `survey-builder` application MUST expose a stable home screen or dashboard from which administrators can reach survey, prompt, persona, access-point, and future administrative sections without depending on secondary actions embedded inside other screens.

#### Scenario: Admin returns to the home context from the persona catalog
- **WHEN** the admin is viewing the persona skill catalog or editor
- **THEN** the UI MUST provide an explicit action to return to the administrative home context
- **AND** the return path MUST not depend exclusively on browser navigation

#### Scenario: Builder grows with new admin sections
- **WHEN** a new administrative section such as access-point management is added
- **THEN** the application MUST expose that section from the same stable home and shell navigation model
- **AND** the new section MUST not require users to discover it through an unrelated catalog flow
