## ADDED Requirements

### Requirement: Survey-builder MUST provide a shared admin navigation shell
The `survey-builder` application MUST provide a shared administrative shell that contains a stable home context, primary section navigation, and consistent page framing for all admin areas.

#### Scenario: Admin opens the authenticated builder
- **WHEN** an authorized admin enters `survey-builder`
- **THEN** the application MUST render an administrative shell with a visible home or dashboard entry
- **AND** the shell MUST provide navigation to surveys, prompts, persona skills, and future administrative sections

#### Scenario: Admin enters a catalog from the shell
- **WHEN** the admin chooses a section such as surveys or persona skills from the shell navigation
- **THEN** the application MUST load that section inside the same administrative shell
- **AND** the shell MUST preserve a visible route back to the home context
