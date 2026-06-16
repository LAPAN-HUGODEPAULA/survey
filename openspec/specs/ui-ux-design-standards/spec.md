# UI/UX Design Standards & Design System Specification

## Purpose
Consolidates all fundamental visual theme, spacing, guidance, validation, feedback, and accessibility rules for LAPAN Flutter web applications.

## Requirements
### Requirement: The platform MUST provide a canonical LAPAN dark Flutter theme
The LAPAN platform SHALL define a canonical Flutter dark theme in `packages/design_system_flutter` that implements the visual system described in `docs/lapan-design/lapan-design.md`, including the amber-driven palette, deep charcoal surfaces, tonal layering, and shared interaction states.

#### Scenario: A Flutter application boots with the platform theme
- **WHEN** `survey-patient`, `survey-frontend`, `clinical-narrative`, or `survey-builder` initializes its root `MaterialApp`
- **THEN** the application MUST use the canonical dark theme exported by `packages/design_system_flutter`
- **AND** the app MUST NOT define a separate app-local theme that overrides the shared palette or base component styling

### Requirement: Shared theme tokens MUST encode the LAPAN visual language
The shared theme SHALL expose reusable tokens or theme extensions for the LAPAN color palette, gradients, surface hierarchy, outlines, and state treatments so shared and app-level widgets can render consistently without hardcoded color values.

#### Scenario: A shared or app-owned widget needs brand styling
- **WHEN** a Flutter widget needs a platform color, gradient, or surface tone
- **THEN** it MUST resolve that value from the shared LAPAN theme contract in `packages/design_system_flutter`
- **AND** it MUST NOT hardcode legacy light-theme colors or standalone brand colors in the consuming app

### Requirement: Shared typography MUST use the platform type system
The Flutter design system SHALL provide the canonical typography for platform apps using Manrope-based text styles and role-appropriate emphasis for display, headline, body, and label usage.

#### Scenario: A screen renders text in a LAPAN Flutter app
- **WHEN** a screen renders titles, metrics, body copy, captions, or labels
- **THEN** it MUST use the shared typography styles from the canonical theme
- **AND** technical labels and metadata MUST remain visually distinct from long-form body content

### Requirement: Shared component styling MUST respect tonal layering and no-line rules
The Flutter design system SHALL express hierarchy through tonal surfaces, spacing, and approved outline treatments rather than opaque section borders or legacy elevated cards.

#### Scenario: A screen renders grouped content or floating UI
- **WHEN** a Flutter screen renders cards, panels, sections, dialogs, popovers, or grouped rows
- **THEN** those surfaces MUST use the shared tonal layering system from the canonical theme
- **AND** the implementation MUST avoid using full-opacity borders as the primary separation mechanism except where an accessibility-specific outline variant is required

### Requirement: The canonical dark theme MUST preserve accessibility expectations
The LAPAN dark theme SHALL preserve readable contrast, visible focus states, and comfortable text/background combinations suitable for the platform accessibility constraints, including the ocular comfort goals described in the design documentation.

#### Scenario: A user navigates an interactive dark-theme screen
- **WHEN** the user focuses, hovers, activates, or validates an interactive control
- **THEN** the control MUST expose a visible shared state treatment defined by the canonical theme
- **AND** the screen MUST avoid pure black-on-white or white-on-black extremes that conflict with the documented accessibility guidance

### Requirement: WCAG 2.1 AA Accessibility
The system SHALL meet WCAG 2.1 AA criteria in `clinical-narrative` screens.

#### Scenario: Contrast and legibility
- **WHEN** the user views text and controls
- **THEN** contrast meets the WCAG 2.1 AA minimum

### Requirement: Keyboard Navigation
The system SHALL allow full use of the interface with keyboard only and visible focus indicators.

#### Scenario: Focus order
- **WHEN** the user navigates with Tab and Shift+Tab
- **THEN** focus follows a logical order without traps and focus is visibly highlighted

### Requirement: Screen Reader
The system SHALL provide labels and announcements for screen readers.

#### Scenario: Dynamic content
- **WHEN** new messages or states are updated
- **THEN** the screen reader is notified appropriately with labeled controls

### Requirement: Emotional Support and Anxiety Reduction
The system SHALL provide proactive emotional support and anxiety reduction tools for clinically sensitive or high cognitive load tasks.

#### Scenario: Support Language in Sensitive Moments
- **WHEN** the user (patient or professional) is performing a stressful task
- **THEN** the system displays support messages that do not pressure for time or perfection (e.g., "Reserve o tempo que precisar para responder")

#### Scenario: Easy Access to Help and Guidance
- **WHEN** the user is in a state of persistent error or doubt
- **THEN** the system offers clear support paths or simplified guidance to regain calm and confidence

### Requirement: The application theme MUST be consistent with the LAPAN Survey Platform.

The application's color scheme, particularly the top app bar, MUST match the established theme of other applications.

#### Scenario: User opens the application
-   **Given** the `survey_builder` application is launched
-   **When** the `SurveyListScreen` is displayed
-   **Then** the top app bar color MUST be orange, consistent with the `design_system_flutter`'s primary color.

### Requirement: Required form fields MUST be clearly indicated.

To improve usability and reduce user error, all mandatory fields in a form MUST be visually distinguished.

#### Scenario: User views the survey creation/editing form
-   **Given** a user is on the `SurveyFormScreen`
-   **When** the form is displayed
-   **Then** the label for each required field (e.g., "Nome de Exibição da Pesquisa") MUST include an asterisk (`*`).

### Requirement: The application MUST provide a clear way to cancel form edits.

To prevent accidental data loss and provide a clear user flow, there MUST be an explicit action to discard changes in a form.

#### Scenario: User discards changes in the survey form
-   **Given** a user has made changes to the survey form
-   **When** they click the "Cancel" button
-   **Then** a confirmation dialog MUST be displayed, asking if they are sure they want to discard the changes.
-   **When** the user confirms the action
-   **Then** the `SurveyFormScreen` MUST be closed, and no changes MUST be saved.

#### Scenario: User cancels without making changes
-   **Given** a user has not made any changes to the survey form
-   **When** they click the "Cancel" button
-   **Then** the `SurveyFormScreen` MUST be closed immediately, without a confirmation dialog.

### Requirement: Personalized Greetings and Feedback
The system SHALL use basic user data (e.g., name, clinical name) to create more empathetic and familiar greetings and feedbacks, provided it does not compromise privacy.

#### Scenario: Patient Greeting
- **WHEN** the patient provides their name in demographics
- **THEN** the system uses their name in progress and waiting messages (e.g., "Olá, [Nome]. Estamos preparando seu relatório")

#### Scenario: Professional Greeting
- **WHEN** the professional accesses the dashboard
- **THEN** the system displays a contextual and professional greeting (e.g., "Bom dia, Dr(a). [Nome]. Você tem 3 atendimentos pendentes")

### Requirement: Waiting State Personalization
Waiting messages SHALL be personalized for the current task context to reduce anxiety.

#### Scenario: Waiting for Narrative AI
- **WHEN** the AI is generating a clinical document
- **THEN** the system displays: "Olá, [Screener]. Estamos analisando os sinais principais do caso para gerar o rascunho. Isso levará apenas alguns instantes"

### Requirement: Perceived Performance
The system SHALL keep UI response times within 250ms for critical interactions.

#### Scenario: Message send
- **WHEN** the clinician sends a message
- **THEN** the message appears in the UI immediately and without noticeable blocking

### Requirement: Voice Button Response Time
The system SHALL enter the recording state within 150ms after user action.

#### Scenario: Start recording
- **WHEN** the clinician activates the voice button
- **THEN** the recording state is shown without noticeable delay

### Requirement: The platform MUST provide a shared Flutter page-shell abstraction.
The LAPAN Survey Platform SHALL provide a shared Flutter scaffold contract in `packages/design_system_flutter` for full-screen application pages.

#### Scenario: Shared scaffold contract is defined
- **Given** the platform maintains multiple Flutter applications
- **When** a full-screen page shell is needed
- **Then** the canonical scaffold abstraction MUST live in `packages/design_system_flutter`
- **And** it MUST standardize the full-screen shell structure around app bar rendering, page body rendering, and the shared footer/status bar
- **And** it MUST NOT require app-specific routing or business logic to be moved into the design system

### Requirement: LAPAN Flutter applications MUST adopt the shared scaffold contract.
The applications `survey-frontend`, `survey-patient`, `survey-builder`, and `clinical-narrative` SHALL use the shared scaffold contract for their full-screen pages.

#### Scenario: User opens a full-screen route in any LAPAN Flutter application
- **Given** the user opens a full-screen route in `survey-frontend`, `survey-patient`, `survey-builder`, or `clinical-narrative`
- **When** the route renders its primary page shell
- **Then** that page MUST render through the shared scaffold contract from `packages/design_system_flutter`
- **And** that shared scaffold contract MUST include the shared footer/status bar as part of the canonical shell
- **And** the application MAY still provide its own route configuration, app-bar widget, and workflow-specific child content

### Requirement: The shared scaffold migration MUST preserve app-specific workflows.
The shared scaffold refactor SHALL standardize layout composition without changing the intended workflow behavior of each application.

#### Scenario: App-specific flows continue to operate after scaffold migration
- **Given** an application-specific flow such as screener navigation, patient screening, survey editing, or clinical conversation
- **When** the page shell is migrated to the shared scaffold contract
- **Then** the flow MUST preserve its existing route structure and app-specific interaction model
- **And** the refactor MUST limit behavior changes to layout-shell standardization unless a separate approved change defines additional UI behavior changes

### Requirement: The shared Flutter page shell MUST render the canonical dark structure
The shared scaffold contract in `packages/design_system_flutter` SHALL provide the canonical full-screen dark shell for LAPAN Flutter apps, including platform background treatment, header integration, content spacing, and footer/status-bar placement.

#### Scenario: A full-screen Flutter route renders through the shared shell
- **WHEN** a LAPAN Flutter route renders a primary page
- **THEN** the route MUST render through the shared scaffold contract from `packages/design_system_flutter`
- **AND** that shell MUST apply the canonical dark background and surface hierarchy defined by the shared theme instead of app-local scaffold styling

### Requirement: Shared shell composition MUST support consistent headers across apps
The shared scaffold contract SHALL support reusable header composition for the LAPAN Flutter apps so that navigation chrome stays visually consistent while still allowing route-specific actions and callbacks.

#### Scenario: An app needs a page title, navigation action, or account menu
- **WHEN** `survey-patient`, `survey-frontend`, `clinical-narrative`, or `survey-builder` renders a full-screen page header
- **THEN** the header MUST be composed through the shared shell or a shared header primitive from `packages/design_system_flutter`
- **AND** the consuming app MAY continue to provide its own navigation callbacks, menu items, and route decisions

### Requirement: Every production Flutter screen MUST adopt the shared shell
The production screens in `survey-patient`, `survey-frontend`, `clinical-narrative`, and `survey-builder` SHALL adopt the shared scaffold contract or a shared shell derivative so the platform presents a unified visual frame across all Flutter applications.

#### Scenario: A user navigates between LAPAN Flutter applications
- **WHEN** the user opens any production screen in the LAPAN Flutter apps
- **THEN** the screen MUST inherit the shared shell structure, footer treatment, and baseline spacing behavior from `packages/design_system_flutter`
- **AND** screen-specific workflow content MAY vary without changing the canonical shell styling

### Requirement: Orientation after Redirection
After an automatic redirection between flows or screens, the system MUST provide a brief visual explanation of the new context using the shared feedback model (`cr-ux-001`).

#### Scenario: Redirection after saving questionnaire
- **WHEN** the user clicks "Finish" and is redirected to the report screen
- **THEN** the system SHALL display a transitional banner or title: "Respostas registradas. Relatório em preparo." (Responses recorded. Report in preparation.)
- **AND** the message SHALL use the severity corresponding to success or processing.

### Requirement: Wayfinding in Editors and Long Pages
Pages or editors with multiple sections MUST offer a local summary or sticky headers to assist in orientation.

#### Scenario: Editing in Builder
- **WHEN** the user edits a long questionnaire in `survey-builder`
- **THEN** the system SHALL provide side navigation or a summary that allows jumping to "Details", "Questions", and "Persona" sections.

### Requirement: Hierarchy and Return Context
The user MUST always have a visual return path to the previous context (breadcrumbs or contextual back button) that does not depend exclusively on the browser's navigation.

#### Scenario: Navigate between configuration screens
- **WHEN** the user enters a sub-configuration screen
- **THEN** the system SHALL display a "Back" button or breadcrumbs allowing return to the parent screen.

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

### Requirement: Empty State Explanation (DsEmptyState)
All data-driven lists or screens that do not have content SHALL present a standardized explanation through the `DsEmptyState` component in Brazilian Portuguese (pt-BR).

#### Scenario: View empty questionnaire catalog
- **WHEN** the user accesses the catalog and no questionnaires are registered
- **THEN** the system SHALL display a `DsEmptyState` with: "Nenhum questionário encontrado. Crie o primeiro questionário para começar."

### Requirement: Suggested Action in Empty States
Every `DsEmptyState` SHALL include at least one suggested primary action (Wayfinding) so the user can transition out of the "dead end" state.

#### Scenario: Create first item from empty state
- **WHEN** the system displays an empty state for the patient catalog
- **THEN** the system SHALL present a prominent action button labeled "Novo Paciente" (pt-BR).

### Requirement: The platform MUST render a shared status bar in every Flutter application.
The LAPAN Survey Platform SHALL display the same shared status bar in `survey-frontend`, `survey-patient`, `survey-builder`, and `clinical-narrative`.

#### Scenario: User opens any full-screen page in a LAPAN Flutter application
- **Given** the user opens one of the platform applications `survey-frontend`, `survey-patient`, `survey-builder`, or `clinical-narrative`
- **When** any full-screen page or route is displayed, including splash, authentication, workflow, report, thank-you, and unavailable/error pages
- **Then** the UI MUST render a status bar with the exact text `COPYRIGHT © 2026. Laboratório de Pesquisa Aplicada às Neurociências da Visão - Todos os direitos reservados.`
- **And** the status bar MUST be implemented from a shared reusable UI primitive so that the content and styling remain consistent across the four applications.

### Requirement: Survey option buttons MUST use directional gradient fills
Each `SurveyOptionButton` SHALL render its background as a `LinearGradient` from `Alignment.topLeft` to `Alignment.bottomRight`. The top-left color SHALL be the base palette color, and the bottom-right color SHALL be the base color darkened by approximately 12% lightness. This gradient MUST apply across `survey-patient`, `survey-frontend`, and `survey-builder`.

#### Scenario: User views survey option buttons
- **WHEN** a survey presents option buttons via `SurveyOptionButton`
- **THEN** each button MUST display a top-left-to-bottom-right gradient using its assigned palette color
- **AND** all three apps MUST produce visually identical button styling

#### Scenario: User selects an option button
- **WHEN** a user taps an option button and it enters the selected state
- **THEN** the gradient MUST remain visible with the white border overlay
- **AND** the gradient direction and depth MUST NOT change between selected and unselected states

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

### Requirement: Password Visibility Toggle
Every password field (secure entry) MUST offer an optional revealing control using standard visibility icons.

#### Scenario: Toggle password visibility
- **WHEN** the user clicks the visibility icon
- **THEN** the system SHALL reveal or mask the password text accordingly

### Requirement: Assistive Input Support
Authentication forms MUST NOT block assistive input mechanisms, such as text pasting or automatic filling by password managers.

#### Scenario: Paste password into field
- **WHEN** the user attempts to paste a password
- **THEN** the system SHALL allow the pasting and the value SHALL be reflected correctly in the field

### Requirement: Prior Visibility of Password Requirements
Password complexity requirements MUST be visible to the user before they submit the registration or password change form.

#### Scenario: View requirements before typing
- **WHEN** the user focuses or views the password field
- **THEN** the system SHALL display the minimum complexity rules (e.g., length, special characters)

### Requirement: Shared Grouping and Summary Components
Long forms or those distributed across sections MUST reuse standardized shared components for grouping and summary, rather than creating a second parallel family of widgets.

#### Scenario: Render validation summary
- **WHEN** the user attempts to submit a form with multiple errors
- **THEN** the system SHALL display the canonical form summary at the top of the page or section

### Requirement: Shared Input Formatters and Constraints
Fields with structured formats (ID, Phone, ZIP, Date) MUST use shared formatters, constraints, and normalization in the design system.

#### Scenario: Date field input
- **WHEN** a user types in a date field
- **THEN** the system SHALL guide and format the input according to the `DD/MM/YYYY` pattern

#### Scenario: ZIP code normalization
- **WHEN** a user enters a ZIP code
- **THEN** the system SHALL restrict and normalize the input according to the shared helper defined for this type

### Requirement: Brazilian Portuguese Language and Grammar
All textual content presented to the user, including field labels, error messages, help texts, and warnings, MUST be in Brazilian Portuguese following grammatical norms strictly, including the correct use of accentuation (e.g., "atenção", not "atencao").

#### Scenario: Display success message
- **WHEN** the system shows a confirmation message in pt-BR
- **THEN** the text MUST contain all accents and special characters (cedilla, tilde) according to pt-BR formal standards.

### Requirement: Clear Mandatory Marking and Group Headers
Mandatory fields MUST be clearly marked with an asterisk (*) and related field groups MUST have descriptive headers.

#### Scenario: Mark mandatory fields with asterisk
- **WHEN** a form with mandatory fields is rendered
- **THEN** the labels of the mandatory fields MUST be appended with an asterisk (*)

### Requirement: Draft State and Progress Restoration
Long administrative forms MUST expose visible draft states and restore progress when it avoids relevant rework.

#### Scenario: Restore draft in Builder
- **WHEN** a user returns to a partially completed questionnaire edit
- **THEN** the system SHALL preserve the draft according to the defined strategy for that flow

### Requirement: Consistent Validation Lifecycle
All migrated structured forms MUST follow the same validation cycle to reduce inconsistency between apps and avoid premature hostile errors.

#### Scenario: First typing in a field
- **WHEN** a user starts typing in a field for the first time
- **THEN** the system MUST NOT display a "required field" or incomplete format error during this initial typing

#### Scenario: Field loses focus (blur)
- **WHEN** the field loses focus (blur)
- **THEN** the system MUST validate this field

#### Scenario: Form submission attempt
- **WHEN** the user clicks "Submit" or "Next"
- **THEN** the system MUST validate all relevant fields at that moment

#### Scenario: Re-editing an invalid field
- **WHEN** the user edits a field that has already been marked as invalid
- **THEN** the system MAY revalidate this field during subsequent edits
- **AND** MUST NOT continuously revalidate fields that are still pristine or have never been exposed as invalid

### Requirement: Clear Field-Level Error Messages
Field-level error messages MUST be clear, objective, and indicate the necessary corrective action.

#### Scenario: Date format error
- **WHEN** the user enters an invalid date
- **THEN** the system SHALL display "Use the format DD/MM/YYYY." instead of "Invalid value."

### Requirement: Form-Level Error Summary for Complex Forms
Complex administrative or multi-step forms MUST provide a visible summary of all validation errors at the top of the form (or in a persistent area) in addition to inline field-level errors.

#### Scenario: User attempts to save a form with multiple invalid fields
- **WHEN** the user clicks "Save" or "Next"
- **AND** there are multiple validation failures across different sections
- **THEN** the system MUST display an error summary component near the top of the form or near the primary action area
- **AND** the summary MUST list the fields that need attention
- **AND** clicking an item in the summary SHOULD scroll the view to the corresponding invalid field.

### Requirement: Centralized Validation Logic
The behaviors for `pristine`, `touched`, `submitted`, and revalidation MUST be centralized in `packages/design_system_flutter` to avoid divergent implementations per application.

#### Scenario: Use standard validator in different apps
- **WHEN** a developer implements a form in `survey-builder` and another in `survey-frontend`
- **THEN** both MUST inherit the same validation timing and error presentation behavior

### Requirement: design_system_flutter MUST provide a shared flow stepper component
`packages/design_system_flutter` SHALL export a `DsFlowStepper` widget that provides a unified visual stepper used by both `survey-frontend` and `survey-patient`. The stepper MUST display stage names, completion states (done, active, todo), and current step highlighting.

#### Scenario: Shared stepper renders in screener flow
- **WHEN** the screener assessment flow is displayed
- **THEN** the `DsFlowStepper` MUST show the screener stages (Dados do paciente, Contexto clínico, Instruções, Questionário, Relatório)
- **AND** the current active step MUST be visually highlighted

#### Scenario: Shared stepper renders in patient flow
- **WHEN** the patient survey flow is displayed
- **THEN** the `DsFlowStepper` MUST show the patient stages (Aviso, Identificação, Boas-vindas, Instruções, Questionário, Relatório)
- **AND** the current active step MUST be visually highlighted

#### Scenario: Stepper reflects step completion state
- **WHEN** a user advances to the next step
- **THEN** the previous step MUST show a "done" visual state
- **AND** the current step MUST show an "active" visual state
- **AND** future steps MUST show a "todo" visual state

### Requirement: survey-frontend MUST use the shared stepper component
The `AssessmentFlowStepper` in `survey-frontend` SHALL be replaced with `DsFlowStepper` configured with the screener stage list.

#### Scenario: Screener flow uses shared stepper
- **WHEN** the screener navigates through the assessment flow
- **THEN** `DsFlowStepper` MUST be displayed at the top of each page
- **AND** the stepper MUST match the visual design of the patient flow stepper

### Requirement: survey-patient MUST use the shared stepper component
The `PatientJourneyStepper` in `survey-patient` SHALL be replaced with `DsFlowStepper` configured with the patient stage list.

#### Scenario: Patient flow uses shared stepper
- **WHEN** the patient navigates through the survey flow
- **THEN** `DsFlowStepper` MUST be displayed at the top of each page
- **AND** the visual design MUST be consistent with the screener flow stepper

### Requirement: Step List and Current Stage Visibility
Every flow with more than two stages MUST display the name of the current stage and the list of flow stages, identifying completion states.

#### Scenario: View stepper in patient flow
- **WHEN** a user starts the assessment
- **THEN** the system SHALL display a stepper showing "Notice" (completed), "Instructions" (current), and "Questions" (future)

### Requirement: Textual and Visual Progress Progress
Progress MUST be communicated through text (e.g., "Step 2 of 5") in conjunction with a visual representation (e.g., progress bar or stepper). Whenever progress text appears on tonal or highlighted surfaces, the text contrast MUST be at least 6:1 against its immediate background.

#### Scenario: Update progress after answering
- **WHEN** the user advances to the next step
- **THEN** the progress text and the visual fill of the progress bar MUST be updated simultaneously

#### Scenario: Progress text remains readable on highlighted surfaces
- **WHEN** the progress indicator is rendered inside colored cards, chips, or status containers
- **THEN** the progress text foreground and background MUST maintain at least a 6:1 contrast ratio
- **AND** readability MUST be preserved in both light and dark tonal variants used by respondent flows

### Requirement: Lifecycle State Visibility in Progress Indicators
Progress indicators MUST reflect the submission and draft state of each stage (per `cr-ux-003`).

#### Scenario: Stage with saved draft
- **WHEN** a stage has a saved draft but is not yet submitted
- **THEN** the visual indicator for that stage SHALL show a "draft" or "partially filled" state

#### Scenario: Stage with validation error
- **WHEN** the user attempts to advance but the current stage has errors
- **THEN** the visual indicator for that stage SHALL show an "error" or "attention" state using the shared feedback model (`cr-ux-001`).

### Requirement: Return without Data Loss
The user MUST be able to return to previous flow stages without losing already entered data, except when the flow is transactional and finalized.

#### Scenario: Go back to previous step
- **WHEN** the user clicks "Previous"
- **THEN** the system SHALL display the previous stage with the preserved filled data

### Requirement: Sectional Navigation for Long Single-Page Flows
Long, single-page administrative forms or configuration screens SHALL offer sectional navigation (Table of Contents) that reflects the structure of the document and indicates progress or validation status for each section.

#### Scenario: User views the sectional navigation in a long form
- **WHEN** the user is viewing a long configuration or builder form
- **THEN** a sectional navigation menu MUST be available, listing all major sections of the page
- **AND** the menu MUST show if a section has validation errors or unsaved changes using appropriate status icons from the shared feedback model.

### Requirement: Progress indicator MUST support endowment-effect denominator
`DsSurveyProgressIndicator` SHALL accept an optional `includeSuccessPage` parameter (default `false`). When `true`, the denominator MUST be `total + 1` to treat the success page as the final milestone.

#### Scenario: Progress bar with endowment mode enabled
- **WHEN** `includeSuccessPage` is `true` and there are N questions
- **THEN** the denominator MUST be `N + 1`
- **AND** on the first question (index 0) the progress MUST be `1 / (N+1)` (approximately 5% for typical surveys)
- **AND** on the last question (index N-1) the progress MUST be `N / (N+1)` (approximately 90-95%)

#### Scenario: Progress bar reaches 100% only on success
- **WHEN** the user completes the last question and the flow transitions to the success/thank-you page
- **THEN** the progress indicator MUST display 100%
- **AND** the progress MUST NOT reach 100% while the user is still answering questions

#### Scenario: Backward compatibility when flag is not set
- **WHEN** `includeSuccessPage` is `false` or not provided
- **THEN** the progress indicator MUST use the original formula `(currentIndex + 1) / total`

### Requirement: Progress indicator MUST enforce a minimum visible progress
When `includeSuccessPage` is `true`, the progress value MUST be clamped to a minimum of `0.02` (2%) to ensure the bar is always visible, even on the first question.

#### Scenario: Minimum progress on first question
- **WHEN** a survey has many questions and `includeSuccessPage` is `true`
- **THEN** the progress bar on the first question MUST show at least 2% fill
- **AND** the bar MUST NOT appear empty at any point during the survey

### Requirement: Transient Confirmation Toasts
The system SHALL use `DsToast` exclusively for confirmation of successfully completed actions and lightweight "undo" actions. These messages SHALL be transient and auto-dismiss after a short period (max 4s).

#### Scenario: Save confirmation
- **WHEN** the user saves a configuration
- **THEN** the system SHALL display a `DsToast` with success severity: "Alterações salvas."

### Requirement: Persistent Contextual Banners
The system SHALL use `DsMessageBanner` for providing persistent contextual information, degraded state warnings, or clinical/legal risks that do not interrupt the current flow.

#### Scenario: Offline mode warning
- **WHEN** connection to the server is lost
- **THEN** the system SHALL display a `DsMessageBanner` at the top of the relevant section: "Você está offline. Algumas funções podem estar limitadas."

### Requirement: Blocking Decision Dialogs
The system SHALL use `DsDialog` only for actions that require an explicit user decision before proceeding, especially for destructive or irreversible actions. These dialogs SHALL support severity styling (CR-UX-001).

#### Scenario: Confirm questionnaire deletion
- **WHEN** the user clicks "Excluir Questionário"
- **THEN** the system SHALL open a `DsDialog` with `Warning` severity
- **AND** include explicit verbs: "Excluir" (destructive) and "Cancelar".

### Requirement: Contextual Inline Validation
Form validation failures SHALL be presented contextually through `DsInlineMessage` (near the relevant input) or in a validation summary, and SHALL NEVER be presented exclusively via `DsToast` or a global banner.

#### Scenario: Attempt to submit form with errors
- **WHEN** the user attempts to submit a form with missing required fields
- **THEN** the system SHALL highlight the fields with `DsInlineMessage` and prevent submission.

### Requirement: Offline Status Banner
The system SHALL display a persistent `DsMessageBanner` when server connectivity is lost, explaining the current status and ensuring data safety.

#### Scenario: Connection loss during active use
- **WHEN** server connectivity is interrupted
- **THEN** the system SHALL display a `DsMessageBanner` with `warning` severity at the top: "Você está offline. Suas alterações serão salvas localmente até a conexão voltar."
- **AND** use the Brazilian Portuguese (pt-BR) language for the message content.

### Requirement: Global Retry Control
Recoverable network or loading failures SHALL offer a visible and consistent "Retry" (Tentar Novamente) control within the error container.

#### Scenario: Questionnaire loading failure
- **WHEN** a questionnaire fails to load due to a network error
- **THEN** the system SHALL display a `DsFeedbackMessage` with `error` severity
- **AND** include a primary action button labeled "Tentar Novamente".

### Requirement: Tone of Voice Profiles per Application
The system SHALL apply differentiated tone of voice profiles according to the context and the end user to reduce stress and increase trust.

#### Scenario: Tone for Patients (survey-patient)
- **WHEN** the user is performing a public screening
- **THEN** the system uses a calm, welcoming, and simple tone (e.g., "Estamos aqui para ajudar a entender melhor sua visão")
- **AND** avoids excessive technical or clinical terms

#### Scenario: Tone for Professionals (survey-frontend / clinical-narrative)
- **WHEN** the professional is performing an appointment
- **THEN** the system uses a clear, professional, and supportive tone (e.g., "Tudo pronto para iniciar a narrativa clínica")
- **AND** focuses on competence and efficiency

#### Scenario: Tone for Administrators (survey-builder)
- **WHEN** the administrator is editing a questionnaire
- **THEN** the system uses a precise, light, and low-noise tone (e.g., "Alterações salvas. O questionário está pronto para uso")

### Requirement: Effort Recognition in Completion Messages
Flow completion messages SHALL recognize the user's effort and the purpose of the task, instead of just confirming data receipt.

#### Scenario: Patient Completion
- **WHEN** the patient finishes the questionnaire
- **THEN** the system displays: "Obrigado por sua colaboração. Suas respostas ajudam a construir um olhar mais cuidadoso para sua saúde"

#### Scenario: Professional Completion
- **WHEN** the professional finishes a session
- **THEN** the system displays: "Sessão concluída com sucesso. O registro clínico foi gerado e está pronto para sua revisão"

### Requirement: Platform feedback severity taxonomy
The LAPAN Flutter apps MUST classify user-facing feedback with a canonical shared severity taxonomy of `info`, `success`, `warning`, and `error`, with severity meaning preserved consistently across applications.

#### Scenario: Render the same severity in different apps
- **WHEN** `survey-patient`, `survey-frontend`, `survey-builder`, or `clinical-narrative` presents a user-facing feedback message
- **THEN** the message MUST declare one canonical severity from the shared taxonomy
- **AND** that severity MUST map to a consistent visual and semantic meaning in every app

### Requirement: Structured feedback message content
The platform MUST represent user-facing feedback through a structured message contract that supports a severity, icon, title, body text, and optional user actions.

#### Scenario: Present a recoverable user-facing error
- **WHEN** a screen needs to tell the user that an action failed but can be retried
- **THEN** the message MUST include an error severity, a visible icon, a short title, and body text that explains what happened
- **AND** the message MUST be able to expose at least one action such as retry, review, undo, or dismiss when the flow supports it

### Requirement: Feedback placement MUST match message purpose
The platform MUST use different feedback containers for different user needs instead of routing every status through the same presentation surface.

#### Scenario: Present validation and page-level feedback in the same flow
- **WHEN** a user triggers a field-level validation error and a page-level informational state in the same screen
- **THEN** the validation error MUST be presented inline or in a validation summary near the relevant inputs
- **AND** the page-level informational state MUST be presented through a non-inline container such as a banner, page state, or other persistent contextual surface
- **AND** transient snackbars or toasts MUST NOT be the only surface for important validation guidance

### Requirement: Feedback MUST remain perceivable without color alone
The platform MUST communicate feedback severity through iconography, text, and semantics in addition to color.

#### Scenario: User perceives a warning state without relying on color
- **WHEN** a warning or error message is shown in a Flutter app
- **THEN** the message MUST include visible text and a visible status icon in addition to its tonal color treatment
- **AND** the meaning of the message MUST remain understandable for users who cannot reliably distinguish color

### Requirement: Nonblocking status updates MUST support assistive technologies
The platform MUST support accessible announcement behavior for status messages that do not move focus.

#### Scenario: A nonblocking status update appears after a user action
- **WHEN** a screen shows a success, warning, info, or error update without opening a dialog or moving focus
- **THEN** the feedback surface MUST support status-message semantics or live-region behavior so assistive technologies can announce the update
- **AND** the screen MUST NOT require the user to discover the update only by visual scanning

### Requirement: Platform effort acknowledgment pattern
The platform SHALL define a standard message pattern for acknowledging user effort and participation.

#### Scenario: User completes a high-cognitive-load task
- **WHEN** the user completes a long survey or complex clinician narrative session
- **THEN** the system MUST display an empathetic acknowledgement (e.g., "Obrigado por sua participação. Suas respostas ajudam...") using a supportive visual tone.

### Requirement: Handoff orientation pattern
The platform SHALL define a message pattern to orient users during multi-step handoff sequences.

#### Scenario: Orientation during analysis wait
- **WHEN** the system transitions from Step 1 (Saved) to Step 2 (Analyzing)
- **THEN** the system MUST clearly communicate the transition (e.g., "Sua avaliação foi salva. Estamos organizando os dados...") and provide clear next-step expectations.
