# shared-status-bar Specification

## Purpose
TBD - created by archiving change add-shared-app-status-bar. Update Purpose after archive.
## Requirements
### Requirement: The platform MUST render a shared status bar in every Flutter application.
The LAPAN Survey Platform SHALL display the same shared status bar in `survey-frontend`, `survey-patient`, `survey-builder`, and `clinical-narrative`.

#### Scenario: User opens any full-screen page in a LAPAN Flutter application
- **Given** the user opens one of the platform applications `survey-frontend`, `survey-patient`, `survey-builder`, or `clinical-narrative`
- **When** any full-screen page or route is displayed, including splash, authentication, workflow, report, thank-you, and unavailable/error pages
- **Then** the UI MUST render a status bar with the exact text `COPYRIGHT © 2026. Laboratório de Pesquisa Aplicada às Neurociências da Visão - Todos os direitos reservados.`
- **And** the status bar MUST be implemented from a shared reusable UI primitive so that the content and styling remain consistent across the four applications.

