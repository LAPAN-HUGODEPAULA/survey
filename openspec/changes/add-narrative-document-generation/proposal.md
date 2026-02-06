# Change: Narrative Document Generation

## Why
Clinicians need reliable document generation from consultation data to produce legally valid medical records. A dedicated generation workflow with previews and multi-format output is required to move beyond raw AI text.

## What Changes
- Define a document generation workflow with template selection and preview.
- Specify output formats (PDF and print) with performance and quality targets.
- Define rendering rules for placeholders, formatting, and medical conventions.
- Capture document metadata for auditability and retrieval.
- Establish compliance requirements for Brazilian medical documentation.

## Impact
- Affected specs: `document-workflow`, `document-output-formats`, `document-rendering`, `document-metadata`, `document-compliance`.
- Affected code: `apps/clinical-narrative/`, `services/clinical-writer-api/`, `services/survey-backend/`, `packages/contracts/`, `packages/design_system_flutter/`.
- Parent change: `add-clinical-narrative-overview`.
