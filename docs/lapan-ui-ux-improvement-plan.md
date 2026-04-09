# LAPAN Survey Platform UI/UX Improvement Plan

Review date: 2026-04-06  
Scope: `survey-frontend`, `survey-patient`, `survey-builder`, `clinical-narrative`  
Method: repository inspection, saved-article review, external standards review  
Deliverable type: review-only, pre-OpenSpec planning artifact  

## 1. Executive Summary

The LAPAN Survey Platform already has a strong base for cross-app consistency: a shared Flutter design system, shared survey-flow primitives, and several reusable status components. However, the platform still behaves like four partially aligned products instead of one coherent experience system.

The biggest gaps are not visual polish first. They are interaction quality gaps:

- Password fields are still missing a show/hide affordance in shared auth components.
- Feedback is inconsistent across apps: some screens use bare snackbars, some use custom panels, some use inline status chips, and severity is not standardized.
- Long-running AI actions do not consistently reduce user anxiety. They often show generic "processing" or "saving" states without stage labels, estimated duration, or reassurance.
- Multi-step flows do not always keep users oriented, in control, and able to recover from errors safely.
- Admin flows in `survey-builder` are dense and correct, but cognitively heavy.
- Some backend/API contracts force weak frontend UX because they collapse detailed failures into generic messages and keep AI work synchronous.

This plan recommends creating a platform-level interaction standard around form behavior, severity-based feedback, progress communication, emotional design, and AI waiting states. The work should be organized as a set of focused change requests that can later become OpenSpec proposals and specs.

## 2. Inputs and Review Method

### 2.1 Repository inspection

The review focused on the end-user behavior and interaction design of:

- `apps/survey-patient`
- `apps/survey-frontend`
- `apps/survey-builder`
- `apps/clinical-narrative`
- `packages/design_system_flutter`

Backend files were only reviewed where API behavior directly shapes the end-user experience:

- `services/survey-backend`
- `services/clinical-writer-api`
- `packages/contracts/survey-backend.openapi.yaml`

### 2.2 Saved article review

Reviewed local copies:

- `_legacy/ui/7 Essential Interaction Design Patterns and Techniques.html`
- `_legacy/ui/The Role of Emotions in UX_ A Deep Dive into Influence and Behaviour.html`

### 2.3 External standards and references

The recommendations below are aligned with the following sources:

- UX Playbook, "Essential Interaction Design Patterns and Techniques"  
  https://uxplaybook.org/articles/essential-interaction-design-patterns-and-techniques
- UX Playbook, "The Role of Emotions in UX: A Deep Dive into Influence and Behaviour"  
  https://uxplaybook.org/articles/how-to-use-emotions-in-ux-design
- W3C WCAG 2.2, SC 3.3.8 Accessible Authentication (Minimum)  
  https://www.w3.org/WAI/WCAG22/Understanding/accessible-authentication-minimum.html
- W3C WCAG, SC 3.3.2 Labels or Instructions  
  https://www.w3.org/WAI/WCAG21/Understanding/labels-or-instructions
- W3C WCAG, SC 4.1.3 Status Messages  
  https://www.w3.org/WAI/WCAG21/Understanding/status-messages.html
- Apple Human Interface Guidelines, Loading  
  https://developer.apple.com/design/human-interface-guidelines/loading
- Apple Human Interface Guidelines, Alerts  
  https://developer.apple.com/design/human-interface-guidelines/alerts
- Android Developers, Snackbar guidance  
  https://developer.android.com/develop/ui/views/notifications/snackbar
- Android Developers, Progress indicators  
  https://developer.android.com/develop/ui/compose/components/progress
- Android Developers, Dialogs  
  https://developer.android.com/develop/ui/views/components/dialogs
- GOV.UK Design System, Warning text  
  https://design-system.service.gov.uk/components/warning-text/
- GOV.UK Design System, Error summary  
  https://design-system.service.gov.uk/components/error-summary/
- GOV.UK Design System, Notification banner  
  https://design-system.service.gov.uk/components/notification-banner/
- NN/g, Empathy Mapping  
  https://www.nngroup.com/articles/empathy-mapping/
- NN/g, Error Message Guidelines  
  https://www.nngroup.com/articles/error-message-guidelines/
- NN/g, User Control and Freedom  
  https://www.nngroup.com/articles/user-control-and-freedom/

## 3. Principles Distilled From the Reviewed Articles

### 3.1 From "Essential Interaction Design Patterns and Techniques"

The saved article reinforces seven patterns that are directly relevant to LAPAN:

- Navigation must preserve context, hierarchy, and easy return paths.
- Forms should guide entry, not merely reject wrong input later.
- CTAs should be visually prominent, action-oriented, and supported by persuasive microcopy.
- Feedback systems should acknowledge actions immediately with micro-interactions, loading states, and explicit success or error messages.
- Dialogs should be used sparingly, with clear exits and minimal interruption.
- Search and filtering matter most in admin and content-heavy flows.
- Progress indicators should keep users oriented, motivated, and informed.

The most relevant detailed techniques for LAPAN are:

- Input masks and upfront validation rules.
- Progressive disclosure for long forms.
- Micro-interactions for acknowledgment.
- Honest loading indicators.
- Clear success and error messages.
- Step-by-step progress indicators.
- Visual progress feedback that does not depend only on color.

### 3.2 From "The Role of Emotions in UX"

The saved article adds an emotional lens:

- Functional, reliable, usable, then pleasurable.
- Pleasure: small delight, warmth, reassuring copy, tasteful animation.
- Flow: remove friction, reduce context switching, keep tasks continuous.
- Meaning: connect the product to purpose, care, and trust.
- Empathy maps and feedback loops should shape copy and interaction decisions.
- Storytelling, personalization, and light gamification can increase desirability when used with restraint.

For LAPAN, this means:

- Patient flows should reduce anxiety and uncertainty.
- Professional flows should communicate confidence, competence, and control.
- Admin flows should reduce fatigue and fear of mistakes.
- AI flows must feel trustworthy, transparent, and calm.

## 4. Current-State Findings

### 4.1 Strengths already present

- Shared primitives already exist in `packages/design_system_flutter`, including `DsScaffold`, `DsLoading`, `DsError`, `DsEmpty`, `DsStatusChip`, `DsStatusIndicator`, `DsProfessionalSignInCard`, `DsProfessionalSignUpCard`, and `DsSurveyProgressIndicator`.
- A severity enum already exists in `DsStatusType` (`neutral`, `info`, `success`, `warning`, `error`), which is a good foundation for a broader feedback model.
- Survey flows already use a progress indicator in `DsSurveyQuestionRunner`.
- Several apps already use semantic page headers and structured sections instead of raw layouts.

### 4.2 Main problems observed

### Platform-wide

- Feedback severity is not standardized at the component or content level.
- Raw `SnackBar` usage is widespread and often text-only.
- Form guidance is uneven. Some fields validate inline, some validate only on submit, and some surface generic errors.
- Long-running operations often use generic copy such as "Processando..." or "Carregando..." without stage context.
- Success, warning, and error states do not follow a single visual and language model.
- Undo, retry, and cancel behaviors are inconsistent.

### Shared auth design system

Observed in `packages/design_system_flutter/lib/components/auth/ds_professional_auth.dart`:

- Password fields use `obscureText: true` and have no show/hide eye affordance.
- Auth feedback is handled by `_DsFeedbackBanner`, which supports only "error vs not-error", with no severity taxonomy, no icon, and no structured title/body/action model.
- Password requirements are mostly hidden until validation fails.

### survey-patient

Observed in `apps/survey-patient/lib/features/...`:

- Welcome, instructions, thank-you, and report states are clear but still emotionally flat.
- AI summary generation on the thank-you page uses a small spinner and generic copy.
- Report generation mixes submission success, local fallback, and report-wait messaging in one area with limited user guidance.
- Demographics form uses snackbar-only handling for missing required grouped fields.
- The patient flow could do more to reassure the user about what is happening and what happens next.

### survey-frontend

Observed in `apps/survey-frontend/lib/features/...`:

- Professional login and registration rely on the shared auth widget, so the missing password affordance affects this app directly.
- Access-link validation has a minimal wait state and does not clearly explain failure paths.
- Settings uses bare snackbars for save/copy/success/error messages.
- The final submission page is informative but combines many states in one long page and still relies on generic loaders.

### survey-builder

Observed in `apps/survey-builder/lib/features/survey/...`:

- Long edit forms are functionally strong but visually dense.
- Builder save and error handling depend heavily on snackbars.
- There is no strong sectional wayfinding for long editors.
- The CRUD experience lacks a consistent "saved / unsaved / validating / conflicting" interaction language.

### clinical-narrative

Observed in `apps/clinical-narrative/lib/features/...`:

- The chat workflow already has good state richness, but the user-facing presentation of that state is still fragmented.
- AI processing states are visible but not emotionally calming.
- Voice capture, transcription, analysis, and document generation each surface status differently.
- Narrative generation uses a single loading button state and snackbar feedback; it does not explain stages or expected wait.
- Insight panels surface raw labels and severities without a unified information architecture.

### 4.3 Backend/API findings that affect UX

- `services/clinical-writer-api/clinical_writer_agent/main.py` exposes `/process` as a synchronous operation. This makes it hard to provide rich progress, background processing, or resumable long waits.
- `services/survey-backend/app/integrations/clinical_writer/client.py` collapses upstream failures into generic messages such as `Unable to reach AI agent` and `Agent error: upstream clinical writer rejected the request`.
- `services/survey-backend/app/api/routes/screener_routes.py` implements password recovery by rotating the password and emailing a new one. This is workable but high-friction and not aligned with modern trust-building password-reset UX.
- Current contracts do not appear to standardize a frontend-safe error object with fields such as `code`, `severity`, `retryable`, `requestId`, or `stage`.

## 5. Proposed Platform UI Standards

### 5.1 Feedback message model

The platform should define one shared feedback object and one shared visual language.

### Message taxonomy

- `info`: neutral contextual guidance, not urgent.
- `success`: action completed or saved.
- `warning`: caution, degraded state, or meaningful risk that is not fatal.
- `error`: action failed, required user attention, or blocking condition.

### Standard message structure

Every banner, snackbar, toast, inline message, or dialog should be able to render:

- `severity`
- `icon`
- `title`
- `body`
- `primaryAction`
- `secondaryAction` or dismiss
- `announcementMode` for assistive technology
- `persistence` (`transient`, `sticky`, `blocking`)
- `context` (`field`, `section`, `page`, `global`)

### Standard icon mapping

- `info` -> `Icons.info_outline`
- `success` -> `Icons.check_circle_outline`
- `warning` -> `Icons.warning_amber_rounded`
- `error` -> `Icons.error_outline`

### Standard color intent

- `info` -> blue or secondary informative tone
- `success` -> green or approved completion tone
- `warning` -> amber/yellow caution tone
- `error` -> red destructive/blocking tone

Color must never be the only cue. Severity must always be readable from icon and text.

### 5.2 Placement rules

- Use inline field errors for validation issues tied to one input.
- Use an error summary or section summary for forms with multiple invalid fields.
- Use snackbar/toast only for transient confirmations or lightweight undo actions.
- Use page banners for persistent page-level information, warning, or degraded states.
- Use dialogs only for blocking, destructive, or irreversible decisions.
- Do not use toasts for important validation or complex failure explanations.

### 5.3 Loading and progress rules

- Show feedback immediately for waits over roughly 300ms.
- Use determinate progress whenever the system knows actual completion.
- Use indeterminate progress only when actual completion is unknown.
- Add stage labels for long AI work, even if the bar is indeterminate.
- For waits above 10 seconds, give users either meaningful progress detail, useful content, or a safe alternative action.
- Preserve user control: allow back, cancel, retry, or continue elsewhere whenever the task model allows it.

### 5.4 Copywriting rules

- Keep user-facing product language in pt-BR.
- Keep the plan and requirements documentation in English.
- Use plain language. No raw exception text, stack traces, or codes in the primary message.
- Titles should state what happened.
- Body text should state what it means and what the user can do next.
- Actions should use concrete verbs, not generic "OK".

## 6. Change Requests

### CR-UX-001: Standardize Feedback Severity, Icons, and Message Structure

### Why

The current platform mixes snackbars, inline panels, chips, and custom banners without one message grammar. Users should be able to recognize message type instantly across all apps.

### Applies to

- All apps
- `packages/design_system_flutter`

### Problems observed

- `_DsFeedbackBanner` is binary instead of severity-based.
- Many screens use text-only `SnackBar`s.
- Warning and error patterns are not consistently distinguishable.

### Proposed requirements

- The platform shall define a shared feedback component family for `info`, `success`, `warning`, and `error`.
- Every feedback message shall include an icon, a short title, and body text.
- Every message shall support optional action affordances such as `Retry`, `Undo`, `Review`, or `Dismiss`.
- The platform shall define which container to use for each message class: inline, summary, banner, snackbar, or dialog.
- Nonblocking status updates shall be announced accessibly without moving focus.

### Candidate OpenSpec requirements

- Requirement: Feedback messages must expose severity consistently across all apps.
- Requirement: Every feedback message must be recognizable without relying only on color.
- Requirement: Status updates that do not take focus must remain perceivable to assistive technology.

### Suggested shared component work

- `DsMessageBanner`
- `DsInlineMessage`
- `DsToastMessage`
- `DsErrorSummary`
- `DsFeedbackModel`

### Example pt-BR microcopy

- `info`: "Informação" / "Estamos preparando os dados desta tela."
- `success`: "Concluído" / "As configurações foram salvas."
- `warning`: "Atenção" / "Você pode continuar, mas faltam dados opcionais."
- `error`: "Não foi possível concluir" / "Verifique os campos destacados e tente novamente."

### CR-UX-002: Add Secure-Entry Usability Standards for Password Fields

### Why

Password reveal is now an interaction standard, and WCAG explicitly recognizes optional password visibility as a way to reduce cognitive load in authentication.

### Applies to

- `survey-frontend`
- `clinical-narrative`
- shared auth widgets in `packages/design_system_flutter`

### Problems observed

- Login and registration password fields do not expose show/hide.
- Password rules are mostly discovered after error.
- Recovery flow is technically functional but emotionally weak.

### Proposed requirements

- Every password field shall include a show/hide toggle using familiar eye icons.
- The toggle shall preserve cursor position and current input.
- Password fields shall allow paste and browser/autofill/password-manager use.
- Password requirements shall be visible before submission.
- Recovery flows shall favor reset-link UX over sending a new password by email in future backend iterations.

### Candidate OpenSpec requirements

- Requirement: Secure text entry fields must offer an optional reveal control.
- Requirement: Authentication forms must not block assistive entry mechanisms such as paste or password managers.
- Requirement: Password requirements must be visible before the user submits the form.

### Specific design instruction

- Hidden state icon: `Icons.visibility_off_outlined`
- Visible state icon: `Icons.visibility_outlined`
- Minimum hit target: 44x44 logical px
- Accessible label: "Mostrar senha" / "Ocultar senha"

### Example pt-BR microcopy

- Helper text: "Use pelo menos 8 caracteres."
- Recovery success: "Se o e-mail estiver cadastrado, vamos enviar instruções para redefinir sua senha."
- Recovery failure: "Não foi possível iniciar a redefinição agora. Tente novamente em alguns instantes."

### CR-UX-003: Standardize Form Guidance, Validation Timing, and Error Recovery

### Why

LAPAN has many forms: patient demographics, clinician registration, settings, builder forms, document dialogs, and chat-related inputs. Current guidance is uneven.

### Applies to

- All apps
- especially `survey-patient`, `survey-frontend`, `survey-builder`

### Problems observed

- Some errors appear only after submit.
- Some grouped-field failures are shown in a snackbar rather than near the fields.
- Dense forms lack review states and sectional guidance.
- Raw field constraints are not always shown up front.

### Proposed requirements

- Show constraints before failure when they are predictable.
- Prefer validation on blur or on submit for error states; do not flood users with premature hostile errors.
- When a form has multiple invalid fields, show both inline errors and a form-level summary.
- Group related fields and name the groups clearly.
- Use input masks or formatting for date, CPF, CEP, phone, and other structured data.
- Use progressive disclosure for advanced or conditional sections.
- Auto-save or preserve draft state in long admin forms.

### Candidate OpenSpec requirements

- Requirement: Forms must provide clear labels, required markers, and format guidance.
- Requirement: Forms with multiple validation failures must provide a visible summary plus field-level errors.
- Requirement: Long forms must preserve user progress and support recovery after interruption.

### Example pt-BR microcopy

- Date helper: "Use o formato DD/MM/AAAA."
- Missing required group: "Revise os campos obrigatórios desta seção."
- Summary title: "Há campos que precisam de correção."

### CR-UX-004: Establish Cross-App Progress and Wayfinding Standards

### Why

Progress indicators exist in parts of the platform, but they do not yet form one user-control system. Users need orientation, not just a bar.

### Applies to

- `survey-patient`
- `survey-frontend`
- `survey-builder`
- `clinical-narrative`
- shared widgets

### Problems observed

- Survey progress shows count and bar, but supporting transitions and review behavior can be clearer.
- Long builder forms do not expose progress through sections.
- AI waits often show only a spinner.
- Some screens redirect quickly without strong orientation.

### Proposed requirements

- Every multi-step flow shall show current, completed, and upcoming state.
- Users shall be able to go back without losing already entered data when the domain allows it.
- Long flows should show named steps, not only percent.
- Visual progress feedback should combine text plus progress visuals.
- Completion moments should include a clear "what just happened" and "what next" state.
- You may want to have a little sycophancy and show messages that encourages the user to complete the task.

### Candidate OpenSpec requirements

- Requirement: Multi-step flows must expose the user's current position in the journey.
- Requirement: Long tasks must communicate either determinate progress or labeled indeterminate stages.
- Requirement: Users must be able to safely return to previous steps when the business flow allows it.

### Example step labels

- Patient flow: "Aviso inicial" -> "Boas-vindas" -> "Instruções" -> "Questionário" -> "Resumo" -> "Dados adicionais" -> "Relatório"
- Professional assessment flow: "Paciente" -> "Contexto clínico" -> "Instruções" -> "Questionário" -> "Envio" -> "Relatório"
- Builder flow: "Detalhes" -> "Instruções" -> "IA" -> "Persona" -> "Perguntas" -> "Revisão"

### CR-UX-005: Redesign AI Waiting States to Reduce Anxiety and Build Trust

### Why

This is the most important emotional-design opportunity in the platform. AI-generated outputs take time. Generic waiting messages create anxiety, uncertainty, and drop-off risk.

### Applies to

- `survey-patient` thank-you and report generation
- `survey-frontend` thank-you and report generation
- `clinical-narrative` chat analysis, transcription, narrative generation, document generation
- backend/API contracts for AI operations

### Problems observed

- Generic copy such as "Processando análise", "Gerando relatório...", and "Processando resposta..." gives no sense of progress quality.
- Users are not told whether the system is validating, drafting, checking consistency, or formatting.
- Long waits do not offer reassurance or safe side actions.

### Proposed requirements

- Long AI operations shall display stage-based waiting states.
- AI waiting copy shall explain what the system is doing in human terms.
- Waiting states shall reassure users that their data was received and work is still progressing.
- When possible, users shall be allowed to keep reading previous content or reviewing answers while waiting.
- AI failure states shall distinguish retryable problems from completed-but-partial outcomes.
- You may want to have a little sycophancy and show messages that tell the user it is worthwhile to wait.

### Candidate OpenSpec requirements

- Requirement: AI-generated content flows must expose stage-level progress in user-facing language.
- Requirement: AI waiting states must reassure users that work is in progress and clarify whether user action is needed.
- Requirement: AI failure messages must provide the safest next action, including retry, fallback, or continue-without-AI where appropriate.

### Recommended AI stage model

- `received`: request accepted
- `validating`: checking content and structure
- `analyzing`: extracting clinically relevant signals
- `drafting`: writing the first draft
- `reviewing`: checking consistency and safety
- `formatting`: assembling the final report
- `ready`: output available

### Recommended pt-BR microcopy

- `received`: "Recebemos suas informações."
- `validating`: "Estamos organizando os dados antes de montar a resposta."
- `analyzing`: "Estamos analisando os sinais principais do caso."
- `drafting`: "Estamos escrevendo a primeira versão do documento."
- `reviewing`: "Estamos revisando o conteúdo para entregar algo mais claro e confiável."
- `formatting`: "Estamos preparando a apresentação final."
- `long wait reassurance`: "Isso pode levar alguns instantes. Não é preciso refazer a ação."
- `background reassurance`: "Você pode continuar revisando esta tela enquanto finalizamos."

### Tone guidance

- Patient-facing waits should feel calm and caring.
- Professional waits should feel competent and trustworthy.
- Never make the AI sound magical or medically absolute.
- Avoid childish delight in clinical moments.

### CR-UX-006: Define Notification, Snackbar, Banner, and Dialog Usage Rules

### Why

The platform currently overuses snackbars for events that deserve inline feedback or summaries. This weakens comprehension and accessibility.

### Applies to

- All apps
- especially settings, auth, report export, and admin CRUD flows

### Proposed requirements

- Snackbars shall be reserved for transient confirmations, undo, and lightweight status.
- Inline validation errors shall never be replaced by snackbars alone.
- Page banners shall be used for persistent contextual information, degraded states, or warnings.
- Dialogs shall be used only for destructive, blocking, or irreversible actions.
- Dialog buttons shall use explicit verbs instead of generic "OK" when confirming an action.

### Candidate OpenSpec requirements

- Requirement: Validation errors must appear inline and, where needed, in a form-level summary.
- Requirement: Destructive or irreversible actions must require explicit confirmation with clear exit options.
- Requirement: Informational content that is not blocking should not interrupt the current task with a dialog.

### Recommended mapping

- Save complete -> snackbar with optional `Undo` if reversible
- Connectivity degraded -> page banner
- Legal/clinical risk -> warning banner or warning text block
- Delete survey/persona/template -> confirmation dialog
- Missing required form inputs -> inline errors plus summary

### CR-UX-007: Improve Empty States, Offline States, and Retry Design

### Why

Users need to understand why there is no content, whether the problem is temporary, and what to do next.

### Applies to

- All apps
- especially survey loading, access-link validation, chat offline mode, builder catalogs

### Problems observed

- Some empty states are technically correct but lack actionability.
- Some degraded states expose exception text or generic failure phrasing.
- Offline and unavailable paths do not always explain the difference between "not found", "not authorized", "temporarily unavailable", and "backend disconnected".

### Proposed requirements

- Empty states shall always include explanation plus next action.
- Retryable failures shall expose a visible `Retry` action.
- Offline states shall explain whether user data is safe and what still works.
- User-facing copy shall never display raw exception strings as the primary message.

### Candidate OpenSpec requirements

- Requirement: Empty states must explain why content is absent and what the user can do next.
- Requirement: Retryable failures must provide a retry control in the same context.
- Requirement: User-facing error copy must abstract raw technical details behind human-readable language.

### Example pt-BR microcopy

- No surveys: "Nenhum questionário está disponível agora. Tente atualizar ou verifique a conexão."
- Access link invalid: "Este link não está mais disponível ou não pode ser validado nesta sessão."
- Offline chat: "Você está sem conexão. As novas análises da IA ficaram indisponíveis até a conexão voltar."

### CR-UX-008: Make Conversational AI States More Visible and More Controllable

### Why

`clinical-narrative` is the most state-rich app in the platform. It should be the benchmark for trust and user control, not just for feature count.

### Applies to

- `clinical-narrative`

### Problems observed

- The app exposes session, voice, analysis, and processing states, but these states are scattered across chips, indicators, text labels, and insight panels.
- The label `Fase da IA` is technically meaningful but not helpful enough.
- Processing and document-generation states do not yet form one continuous narrative of what the system is doing.

### Proposed requirements

- Expose a single "assistant status" area that explains current state and next likely outcome.
- Humanize internal labels like `analysisPhase`.
- Add cancel, retry, or continue-manually options where technically safe.
- Turn insight panels into typed cards with icons, severity, and brief explanatory headers.
- Distinguish clearly between system suggestion, warning, hypothesis, and confirmed document output.

### Candidate OpenSpec requirements

- Requirement: Conversational AI screens must expose the assistant's current operating state in plain language.
- Requirement: AI-generated insight panels must distinguish information type and severity consistently.
- Requirement: Users must retain visible control over recording, transcription, message editing, and session completion actions.

### Recommended label model

- `analysisPhase=intake` -> "Organizando a anamnese"
- `analysisPhase=assessment` -> "Analisando sinais clínicos"
- `analysisPhase=plan` -> "Estruturando o plano"
- `analysisPhase=wrap_up` -> "Preparando o encerramento"

### CR-UX-009: Introduce an Emotional Design Layer Across the Platform

### Why

The platform is already functional and increasingly consistent, but it is not yet especially desirable. Emotional design here should not mean playful everywhere. It should mean reducing stress, increasing confidence, and making the experience feel intentionally caring.

### Applies to

- All apps, with different tone by context

### Proposed requirements

- Patient-facing journeys should sound calm, respectful, and supportive.
- Professional journeys should sound confident, efficient, and clear.
- Admin journeys should sound precise, lightweight, and low-friction.
- Completion states should acknowledge effort, not only data submission.
- Use personalization where helpful, but never in a creepy or overfamiliar way.
- Use delight sparingly in clinical contexts and more visibly in low-risk moments such as successful saves or completed setup.

### Candidate OpenSpec requirements

- Requirement: Each app must define an approved tone profile that matches its user and context.
- Requirement: Completion, waiting, and recovery states must use tone appropriate to the emotional stakes of the task.
- Requirement: Personalization must improve clarity or confidence, not novelty for its own sake.

### Tone matrix

- `survey-patient`: calm, reassuring, simple
- `survey-frontend`: clear, professional, supportive
- `survey-builder`: precise, efficient, low-noise
- `clinical-narrative`: clinically confident, transparent, measured

### Example emotional microcopy

- Patient completion: "Obrigado. Sua participação ajuda a montar uma leitura inicial mais cuidadosa."
- Professional success: "Tudo certo. A avaliação foi registrada com sucesso."
- Builder save: "Alterações salvas. Você pode continuar editando."

### CR-UX-010: Improve Survey Completion, Summary, and Handoff Moments

### Why

The transition from answering questions to receiving guidance or reports is one of the most emotionally charged parts of the platform. It should feel coherent and intentional.

### Applies to

- `survey-patient`
- `survey-frontend`

### Problems observed

- Submission success, AI processing, final notes, and next-step decisions are sometimes mixed in one visual block.
- Users are not always told clearly what is already complete and what is still being prepared.

### Proposed requirements

- Separate "responses saved" from "AI summary being prepared" from "report ready".
- Show a protocol or reference ID only after a plain-language explanation of its meaning.
- Offer a clear fork when additional demographic or clinical enrichment is optional.
- Make final notes visually distinct from system-state messages.

### Candidate OpenSpec requirements

- Requirement: Submission success must be communicated separately from report-generation status.
- Requirement: Optional enrichment steps must clearly explain benefit and non-benefit.
- Requirement: Final notes and system status must use different visual containers.

### Recommended handoff model

- Step 1: "Respostas registradas"
- Step 2: "Análise preliminar em preparo"
- Step 3: "Relatório disponível"

### CR-UX-011: Reduce Cognitive Load in Survey Builder

### Why

`survey-builder` is not developer UX, but it is still a serious productivity surface for end users in the administrative role. It currently asks for sustained attention across long, dense forms.

### Applies to

- `survey-builder`

### Problems observed

- Long forms have many inputs and editors without strong internal navigation.
- Save state is not persistent enough in the interface.
- Snackbar-only errors interrupt but do not guide.
- CRUD list actions are serviceable but not yet optimized for confidence.

### Proposed requirements

- Add sectional navigation or a local table of contents in long builder forms.
- Keep a sticky save/cancel area visible while editing.
- Show unsaved-changes state persistently, not only in a cancel dialog.
- Use inline errors, conflict banners, and save-status indicators.
- Add clearer empty-state and list-filter affordances for prompts and personas.

### Candidate OpenSpec requirements

- Requirement: Long administrative editors must expose section-level wayfinding.
- Requirement: Save state must remain continuously visible while editing.
- Requirement: Administrative errors must be shown in context, not only in transient snackbars.

### Example pt-BR microcopy

- Unsaved: "Há alterações não salvas."
- Saving: "Salvando rascunho..."
- Saved: "Alterações salvas há poucos segundos."
- Conflict: "Este item foi alterado em outro lugar. Revise antes de substituir."

### CR-UX-012: Add UX-Supporting API Contracts for Errors, Progress, and Recovery

### Why

Some UX improvements cannot be completed in Flutter alone because the API does not yet provide the state richness needed for a trustworthy interface.

### Applies to

- `services/survey-backend`
- `services/clinical-writer-api`
- `packages/contracts`

### Problems observed

- AI generation is synchronous.
- Error messages are flattened too early.
- Frontend cannot distinguish retryable, permanent, auth-related, or validation-related AI failures.
- Password recovery still depends on sending a replacement password.

### Proposed requirements

- Define a frontend-safe error contract:
  - `code`
  - `userMessage`
  - `severity`
  - `retryable`
  - `requestId`
  - `operation`
  - `stage`
  - `supportMessage` or `debugMessage` only for logs/support contexts
- Add asynchronous job semantics or streaming progress for AI report creation.
- Expose stage updates for long AI operations.
- Replace password-replacement email flow with tokenized reset-link flow in a future security/UX change.
- Distinguish empty data, unauthorized access, expired link, and backend unavailable in contracts.

### Candidate OpenSpec requirements

- Requirement: AI-facing APIs must return structured, frontend-safe failure states.
- Requirement: Long-running AI operations must expose observable progress or stage changes.
- Requirement: Recovery flows must prioritize secure, low-friction reset behavior over replacement credentials.

## 7. Suggested Microcopy Library

This section provides seed copy for later localization and design-system integration. The document is in English, but the live product copy below is intentionally in pt-BR because that is the current user-facing language.

### 7.1 Authentication

- Login helper: "Entre com seu e-mail profissional e sua senha."
- Password helper: "Use a senha cadastrada para esta conta."
- Password reveal semantics: "Mostrar senha" / "Ocultar senha"
- Invalid credentials: "E-mail ou senha incorretos. Revise os dados e tente novamente."
- Recovery sent: "Se o e-mail estiver cadastrado, vamos enviar as instruções para redefinir a senha."

### 7.2 Long-running AI tasks

- Initial state: "Recebemos sua solicitação."
- Active stage: "Estamos analisando as informações para montar uma resposta mais clara."
- Reassurance: "Isso pode levar alguns instantes. Não é preciso repetir a ação."
- Background option: "Você pode continuar revisando esta tela enquanto finalizamos."
- Delay message: "Ainda estamos trabalhando no resultado. Obrigado por aguardar."
- Retryable error: "Não foi possível concluir agora. Tente novamente em alguns instantes."

### 7.3 Save and export

- Saved: "Alterações salvas."
- Saved locally: "Não conseguimos enviar ao servidor, mas seus dados foram salvos neste dispositivo."
- Export started: "O download foi iniciado."
- Export unavailable: "Esta exportação não está disponível neste ambiente."

### 7.4 Form completion

- Section complete: "Seção concluída."
- Missing required fields: "Revise os campos obrigatórios destacados."
- Review prompt: "Antes de continuar, confirme se as informações estão corretas."

## 8. Suggested Change Grouping for Future OpenSpec Work

These change requests can be grouped into future proposals without becoming one oversized monolith.

### Suggested proposal group A: shared interaction standards

- CR-UX-001
- CR-UX-003
- CR-UX-004
- CR-UX-006

Possible capabilities:

- `shared-feedback-messaging`
- `shared-form-validation-ux`
- `shared-progress-and-status-ux`
- `shared-dialog-and-notification-rules`

### Suggested proposal group B: authentication and trust

- CR-UX-002
- CR-UX-012

Possible capabilities:

- `auth-interaction-usability`
- `auth-recovery-experience`
- `frontend-safe-error-contracts`

### Suggested proposal group C: AI experience quality

- CR-UX-005
- CR-UX-008
- part of CR-UX-012

Possible capabilities:

- `ai-wait-experience`
- `clinical-chat-state-visibility`
- `ai-progress-contracts`

### Suggested proposal group D: app-specific flow polish

- CR-UX-009
- CR-UX-010
- CR-UX-011

Possible capabilities:

- `patient-journey-emotional-design`
- `assessment-handoff-ux`
- `builder-productivity-ux`

## 9. Suggested Delivery Order

### Phase 1: urgent interaction standards

- Add password reveal to shared auth fields.
- Establish severity model and shared feedback components.
- Replace bare snackbar usage for validation-critical moments.
- Standardize loading and status-message semantics.

### Phase 2: long-task and AI trust

- Redesign waiting states in survey and clinical AI flows.
- Add staged copy and consistent retry/fallback behavior.
- Introduce backend progress/error contracts.

### Phase 3: flow quality and desirability

- Improve completion moments and report handoffs.
- Add stronger app-specific tone and emotional design.
- Reduce builder cognitive load and improve admin confidence states.

## 10. High-Priority Opportunities by App

### survey-patient

- Strengthen AI wait reassurance and report handoff.
- Improve grouped-field validation and review cues.
- Make completion moments feel more supportive and less mechanical.

### survey-frontend

- Fix auth secure-entry standards through shared widgets.
- Improve access-link validation states and settings feedback.
- Separate submission success from report-generation status more clearly.

### survey-builder

- Add long-form wayfinding, persistent save state, and in-context errors.
- Improve list empty states, filterability, and success/conflict handling.

### clinical-narrative

- Unify assistant state communication.
- Humanize AI phase naming and long-task microcopy.
- Standardize insight panels and document-generation feedback.

## 11. Final Recommendation

Do not treat this work as a visual refresh. Treat it as a platform interaction standardization effort with a strong emotional-design layer.

The best starting move is not a big redesign. It is a focused shared-component and message-model upgrade:

- password reveal and secure-entry usability
- standardized feedback severity and icons
- better progress and waiting states
- AI trust and anti-anxiety microcopy

Those four improvements will produce the highest user-perceived quality gain across all four apps while creating a strong base for later OpenSpec proposals.
