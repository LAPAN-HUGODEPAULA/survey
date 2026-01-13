# Prompt Editing Runbook (Google Drive)

This runbook describes how clinicians edit Clinical Writer prompts stored in Google Drive.

## Scope
- Prompts are Google Docs referenced by `prompt_key`.
- The Clinical Writer service fetches prompt text via the Google Drive API.
- The service uses the document `modifiedTime` as `prompt_version`.

## Safe Editing Workflow
1) Open the Google Drive folder configured by `GOOGLE_DRIVE_FOLDER_ID` (or the explicit `PROMPT_DOC_MAP_JSON`).
2) Locate the document that matches the desired `prompt_key`.
3) Make edits directly in Google Docs.
4) Keep the output instructions strict: the model must return JSON only (no markdown).
5) Save the document. The service will pick up the updated prompt within the cache TTL.

## Guardrails
- Do not include PHI in prompts. Use placeholders when you need examples.
- Keep section headings and required fields consistent with ReportDocument schema.
- Avoid adding Markdown formatting tokens (e.g., ``` or **). The service expects JSON only.
- If a prompt change causes errors, revert the document to the last good version in Drive.

## Verification
- Use the sample payloads in `samples/clinical-writer/inputs/` to test the new prompt.
- Confirm the response matches the JSON schema in `samples/clinical-writer/outputs/`.
