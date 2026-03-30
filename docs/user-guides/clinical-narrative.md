# Clinical Narrative User Guide

This guide explains how to use the Clinical Narrative application in the LAPAN Survey platform to conduct clinical conversations, capture information, and generate clinical documents.

## Prerequisites

- Required services must be running: `mongodb`, `survey-backend`, and `clinical-narrative`.
- For clinical assistance and document-generation features, `clinical-writer-api` must be available and configured through the backend.
- Use a modern browser with microphone access enabled when voice capture is needed.

## Start the app locally

From the repository root, start the required services:

```bash
./tools/scripts/compose_local.sh up -d mongodb survey-backend clinical-writer-api clinical-narrative
```

The application is available at `http://localhost:8082`.

## Main user flow

1. Open the application and enter the patient information.
2. Continue to the clinical conversation.
3. Record the conversation by typing messages or using voice capture.
4. Review suggestions, alerts, and hypotheses when those features are available.
5. Generate clinical documents from the conversation and narrative.
6. Preview and export the document as PDF or print output.
7. End the consultation to complete the session.

## Voice capture

- Enable voice mode from the message input.
- Select **Start** to begin recording and **Stop** to finish.
- Use the live preview to review captured content.
- Send the captured audio for transcription to insert the resulting text into the chat.

## Document generation

- Select **Generate document**.
- Choose the **document type** and a **template**.
- Adjust the **title** and **content** if needed.
- Use **Preview** to inspect the result.
- Use **Export PDF/Print** to create the final output.

## Important notes

- A session becomes unavailable for editing after it is marked as completed.
- In offline mode, message submission and document generation may be unavailable.
- Voice capture works only in browsers that support the required media APIs and permissions.

## Related references

- For platform context, see [Overview](../overview.md).
- For backend and architecture details, see [Software Design](../software-design.md) and [Technical Specification](../technical-specification.md).