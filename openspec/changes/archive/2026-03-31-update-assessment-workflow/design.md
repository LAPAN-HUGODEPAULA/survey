## Context

The current `survey-patient` thank-you screen shows a static three-cell grid with a separate “Ver resultados” button that loads agent output on demand. The radar visualization uses numeric question IDs (Q1, Q2, …), which are meaningless to patients, and there is no fast way to kickoff a fresh questionnaire for another respondent. Behind the scenes each question definition lacks any label metadata, so the UI can only enumerate by ordinal. The survey builder and backend therefore have no concept of question labels either.

## Goals / Non-Goals

**Goals:**  
- Provide a self-contained assessment summary in `survey-patient` that: (1) highlights the agent’s findings directly inside the thank-you card with loading and error states, (2) upgrades the radar chart with colors and question labels, (3) lets the patient restart the flow via “Iniciar nova avaliação”, and (4) retains the existing “Adicionar informações” pathway.  
- Add an optional `label` to each question, persist it in MongoDB, expose it through the API, and surface it in the builder so the radar and lists render human-friendly labels.  
- Modernize the radar chart legend/axis so labels (and colors) match the newly stored metadata without breaking legacy responses (fallback to Q#).  
- Ensure the new “Avaliação preliminar” card mirrors the content that was previously hidden behind “Ver resultados”, so the button can be removed without losing functionality.

**Non-Goals:**  
- Replacing the patient report flow or generating a new PDF; the “Adicionar informações” button continues to open the same detailed report workflow.  
- Adding a full-on survey builder redesign—only the question label fields and listing previews need updates.

## Decisions

1. **Inline agent results + new card** → We will render the agent response text directly in the “Avaliação preliminar” cell with its own loading indicator and a fallback error banner. This avoids the “Ver resultados” modal and keeps the prior start experience by calling the existing agent request as soon as the thank-you screen appears.
2. **Radar modernization** → The radar widget will be rebuilt (can reuse shared charting helpers) to support color gradients and overlay text/tooltip showing the question label. The chart will read from the new `label` metadata and, when absent, render `Q1`, etc., maintaining backwards compatibility.
3. **Question label metadata storage** → Each question definition in MongoDB will gain an optional `label` property. Migration scripts will populate legacy questions by heuristically summarizing their text (“Luzes pulsantes”, “Atenção a pulso”, etc.) and saving it, while new questions default to the builder-provided label. The `/surveys` API will accept/return the new field so all clients can render it.
4. **Builder UX updates** → The `survey-builder` question editor will expose a label input with the same validations as other text fields and show the label in listings/previews so administrators understand how the radar will render the question. The builder will also send the label to the backend when saving.
5. **“Iniciar nova avaliação” state reset** → The patient app will clear in-memory survey/response state (and any session tokens) and navigate back to the welcome screen, enabling multiple respondents to use the same device without refreshing the browser.

## Risks / Trade-offs

- [Risk] Auto-generating labels for legacy questions could produce awkward text. → Mitigation: use a simple NLP heuristic that extracts key nouns from the question prompt, but allow future builder edits to override without re-running migration; log heuristics for manual review.
- [Risk] Rendering the agent output inline might load slowly and block the new card. → Mitigation: show a spinner + “Processando” message while awaiting the agent response and degrade to an error message only if the request fails; keep the “Adicionar informações” action separate so users can continue even if the agent is slow.
- [Risk] The new radar styling might conflict with existing responsive layout. → Mitigation: base the redesign on the shared `DsGridCard` and reuse existing scaffolding so the layout remains flexible on mobile/desktop.

## Migration Plan

1. Introduce the `label` field in the MongoDB survey schema and expose it through the `/surveys/{id}` API responses.
2. Write a migration that iterates existing questions, uses simple heuristics to derive a label from the question text (e.g., take the first few words or notable nouns), and saves it without requiring manual edits.
3. Update `survey-builder` to allow editing the label before this migration runs—existing questions will still show the derived label once the script completes.
4. Deploy backend changes before rolling out the patient UI so the radar can read the new field; the patient build should be feature-flagged or detect missing fields gracefully via the fallback numbering.

## Open Questions

- Should the migration also backfill labels for question copies in drafts, or only the canonical published surveys?  
- Do we need telemetry on how often “Iniciar nova avaliação” is used so we can monitor repeated sessions?
