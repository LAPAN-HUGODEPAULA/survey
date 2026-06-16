# Conversational Clinical Narrative UI & Chat Engine Specification

## Purpose
Consolidates conversational platform specs, message structure, reliability, chat inputs, session management, and related UI components in the clinical-narrative app.

## Requirements
### Requirement: Conversational Message List
The system SHALL display messages in chronological order with clear author identification, timestamps, and scrollable history that keeps the latest content visible.

#### Scenario: Show history and latest
- **WHEN** an active session is opened
- **THEN** the system presents history in order, labels authors, and scrolls to the newest message

### Requirement: Persistent Input Area
The system SHALL keep the input area visible during the conversation with text, keyboard send, and voice toggle support.

#### Scenario: Send message
- **WHEN** the clinician types and presses Enter or taps Send
- **THEN** the message appears in the list and focus remains on the input

### Requirement: Message Actions
The system SHALL offer message actions such as copy, edit, and delete for clinician-authored messages.

#### Scenario: Edit clinician message
- **WHEN** the clinician selects edit on their own message
- **THEN** the system allows adjusting the content before resending while preserving message history

### Requirement: Clinical chat MUST distinguish typed feedback surfaces
The `clinical-narrative` conversation UI MUST distinguish informational, warning, and error feedback consistently across assistant status, alerts, and insight surfaces.

#### Scenario: Assistant feedback is shown during a clinical conversation
- **WHEN** the conversation UI shows an assistant alert, system status, or typed insight
- **THEN** the interface MUST render it with a defined severity and a consistent iconographic treatment
- **AND** the user MUST be able to understand whether the content is informational, cautionary, or blocking

#### Scenario: Nonblocking conversation feedback is announced accessibly
- **WHEN** a status update appears in the chat screen without moving focus
- **THEN** the update MUST support an accessible status announcement mechanism
- **AND** it MUST remain visually consistent with the shared feedback model

### Requirement: Unified Assistant Status Area
The system SHALL display a unified status area above the input area, informing the current AI phase (e.g., "Analisando sinais clínicos") and offering cancellation or retry controls.

#### Scenario: Interrupt AI analysis
- **WHEN** an analysis is in progress and the user clicks on "Cancelar"
- **THEN** the system interrupts processing and returns the input area to the ready state

### Requirement: Clinical Session Creation
The system SHALL allow starting a new session with or without a patient link.

#### Scenario: Start session without patient
- **WHEN** the clinician chooses to start without a patient
- **THEN** the session is created without identifiable data

#### Scenario: Start session with patient
- **WHEN** the clinician selects a patient
- **THEN** the session is created with loaded context

### Requirement: Session Header
The system SHALL display a header with humanized session status, duration, and primary actions.

#### Scenario: Active session
- **WHEN** the session is active
- **THEN** the header shows "Sessão Ativa", duration, and available actions

#### Scenario: Finished session
- **WHEN** the session is completed
- **THEN** the header shows "Sessão Concluída" and input is disabled

### Requirement: Session Insight Panel
The system SHALL display a side panel or dedicated section to show AI-generated insights in real-time, using standardized cards.

#### Scenario: View new insight during session
- **WHEN** the AI generates a new hypothesis or suggestion
- **THEN** the system adds a card to the insight panel with the appropriate icon and severity.

### Requirement: Turn-Based Flow
The system SHALL process conversations in a turn-based flow between clinician input and AI response.

#### Scenario: AI processing
- **WHEN** a clinician sends a message
- **THEN** the system displays a processing state until the AI responds

### Requirement: Context Management
The system SHALL preserve conversation context across the session for AI processing.

#### Scenario: Reference prior messages
- **WHEN** the AI responds to a later message
- **THEN** the response reflects earlier context in the same session

### Requirement: Consultation Phases
The system SHALL support consultation phases to guide AI behavior and UI context.

#### Scenario: Change phase
- **WHEN** the clinician selects a new phase
- **THEN** the system updates the phase and adapts prompts accordingly

### Requirement: Text Input
The system SHALL provide a text input area for clinician messages.

#### Scenario: Send text message
- **WHEN** the clinician types a message and submits
- **THEN** the system sends the message into the conversation

### Requirement: Voice Mode Toggle
The system SHALL provide a toggle to switch between text and voice input modes.

#### Scenario: Toggle input mode
- **WHEN** the clinician switches input mode
- **THEN** the system updates the input controls to match the selected mode

### Requirement: Quick Actions
The system SHALL provide quick actions for common workflows such as generating documents and ending consultations.

#### Scenario: End consultation action
- **WHEN** the clinician triggers the end consultation action
- **THEN** the system asks for confirmation before completing the session

### Requirement: Message Types
The system SHALL support distinct message types for user input, AI responses, system notices, suggestions, and document previews.

#### Scenario: Render message types
- **WHEN** messages are displayed in the conversation
- **THEN** each type is rendered with a distinct visual treatment

### Requirement: Message Structure
The system SHALL store messages with identifiers, session linkage, content, timestamps, and optional metadata.

#### Scenario: Persist message
- **WHEN** a message is sent
- **THEN** it is stored with a unique ID and server timestamp

### Requirement: Message Actions
The system SHALL allow edit, regenerate, copy, and soft delete actions for messages when applicable.

#### Scenario: Edit user message
- **WHEN** a clinician edits a message before AI response
- **THEN** the system updates the message and preserves edit history

### Requirement: Data Integrity
The system SHALL ensure messages are not lost during transmission and are persisted in order.

#### Scenario: Retry on failure
- **WHEN** a message send fails due to a transient error
- **THEN** the system retries and preserves ordering

### Requirement: Session Recovery
The system SHALL recover active sessions after temporary connectivity loss.

#### Scenario: Reconnect after network loss
- **WHEN** the connection is restored
- **THEN** the system restores session state and pending messages

### Requirement: Availability Feedback
The system SHALL inform the clinician when connectivity is degraded.

#### Scenario: Offline indicator
- **WHEN** the client loses connection
- **THEN** the UI displays an offline indicator and disables send until recovery

### Requirement: Session Lifecycle
The system SHALL manage consultation sessions using explicit lifecycle states.

#### Scenario: Create session
- **WHEN** a clinician starts a new consultation
- **THEN** the system creates a session with an initial state and timestamps

#### Scenario: Complete session
- **WHEN** a clinician finishes the consultation
- **THEN** the system marks the session as completed and records completion time

### Requirement: Session Persistence
The system SHALL persist session metadata and transcript references for the duration of the consultation.

#### Scenario: Refresh browser
- **WHEN** the clinician refreshes the page during an active session
- **THEN** the system restores the session state and message history

### Requirement: Realtime session admission checks
The system SHALL validate websocket session subscriptions before broadcasting
realtime chat events.

#### Scenario: Subscribe to a missing session
- **WHEN** a websocket client tries to join a session that does not exist
- **THEN** the backend rejects the connection

#### Scenario: Subscribe from an untrusted browser origin
- **WHEN** a browser websocket request originates from outside the configured
  allowlist
- **THEN** the backend rejects the connection before accepting the session
  stream

### Requirement: Optional Patient Linkage
The system SHALL allow sessions to be created with or without a linked patient.

#### Scenario: Create standalone session
- **WHEN** the clinician chooses to proceed without a patient
- **THEN** the system creates a session without patient linkage

### Requirement: Session History Maintenance
The system SHALL maintain conversational sessions with message history and basic metadata (date, author, origin).

#### Scenario: Create a new session
- **WHEN** a user starts a new conversation
- **THEN** the system SHALL create an empty session and register the minimum context

### Requirement: Session History Retrieval
The system SHALL allow retrieving the history of a session for continuity of care.

#### Scenario: Load session history
- **WHEN** the user reopens a previous session
- **THEN** the system SHALL return the message history in chronological order

### Requirement: Conversational Interface
The system SHALL provide a clear conversational interface with history and multimodal input.

#### Scenario: View chat history
- **WHEN** the user opens a session
- **THEN** the system SHALL show the history in order and allow new interaction

### Requirement: Shared Design System
The system SHALL follow the shared design system across all apps.

#### Scenario: Apply theme components
- **WHEN** a screen is rendered
- **THEN** the system SHALL apply colors and components from `design_system_flutter`

### Requirement: Unified Assistant Status Area
The system SHALL expose a single status area ("Status do Assistente") that consolidates all AI processing states (voice, transcription, analysis).

#### Scenario: View status during conversation
- **WHEN** the AI is processing the clinician's voice input
- **THEN** the system displays a unified status indicator with the current phase and a discrete activity animation
- **AND** uses Brazilian Portuguese (pt-BR)

### Requirement: Humanization of Technical Phases
The system SHALL translate internal technical phases (`analysisPhase`) into humanized clinical terms in pt-BR.

#### Scenario: Translation of internal phases
- **WHEN** the internal phase is `intake` -> **THEN** the system displays "Organizando a anamnese"
- **WHEN** the internal phase is `assessment` -> **THEN** the system displays "Analisando sinais clínicos"
- **WHEN** the internal phase is `plan` -> **THEN** the system displays "Estruturando o plano"
- **WHEN** the internal phase is `wrap_up` -> **THEN** the system displays "Preparando o encerramento"

### Requirement: User Control over AI Processing
The system SHALL provide visible controls so that the user can intervene in AI processing when there are delays or failures.

#### Scenario: Cancel analysis in progress
- **WHEN** an AI analysis is being generated
- **THEN** the system displays a "Cancelar" or "Continuar manualmente" button visible in the status area
