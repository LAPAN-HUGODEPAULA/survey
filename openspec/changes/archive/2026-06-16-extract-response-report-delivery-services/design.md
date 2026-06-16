# Design: extract-response-report-delivery-services

## Context

This change was produced from Skylos Python report v1 triage. The intent is to resolve route-layer tangles and duplicate code by refactoring response creation and report email delivery into clean, testable service boundaries.

## Architecture

We decouple the core database entities and route layers from the email delivery pipeline using the **Command Pattern (DTO-based)** and the **Strategy Pattern** for PDF generation.

```
       ┌──────────────────────────┐       ┌──────────────────────────┐
       │     PatientSubmission    │       │     SurveySubmission     │
       │       Orchestrator       │       │       Orchestrator       │
       └────────────┬─────────────┘       └────────────┬─────────────┘
                    │                                  │
                    │ Builds                           │ Builds
                    └─────────────────┬────────────────┘
                                      ▼
                           ┌─────────────────────┐
                           │  SendReportCommand  │ (DTO)
                           └──────────┬──────────┘
                                      │ Passes to
                                      ▼
                           ┌─────────────────────┐
                           │ReportDeliveryService│
                           └──────────┬──────────┘
                                      │
                   ┌──────────────────┴──────────────────┐
                   │                                     │
                   ▼                                     ▼
       ┌──────────────────────┐              ┌──────────────────────┐
       │     PDFGenerator     │ (Interface)  │     EmailClient      │ (Interface)
       └───────────▲──────────┘              └───────────▲──────────┘
                   │                                     │
                   │ Implements                          │ Implements
       ┌───────────┴──────────┐              ┌───────────┴──────────┐
       │  ReportlabPDFGen     │              │  SmtpEmailClient     │
       └──────────────────────┘              └──────────────────────┘
```

## Decisions

- **Unify on ReportLab**: Completely remove `fpdf` / `fpdf2` dependencies. Both patient and screener responses will generate PDFs via a unified `ReportlabPDFGen` engine.
- **Command Pattern with DTO**: Implement report delivery via `ReportDeliveryService.execute(command: SendReportCommand)`. The service is completely decoupled from DB schemas and models.
- **Specialized Orchestrators**:
  - `PatientSubmissionOrchestrator`: For public, deferred AI-processing.
  - `SurveySubmissionOrchestrator`: For professional, inline AI-processing and email queuing.
- **Shared Clinical Text Resolver**: Move the keys lookup (`agentResponse`, `agentResponses`, `medicalRecord`, `report`) into a single helper `ClinicalTextResolver`.
- **Safe-Path File Containment**: Use `lapan_core` safe-path boundaries to write and clean up temp PDF files during delivery.

## Risks / Trade-offs

- **PDF Layout Parity**: Unifying patient report PDFs under ReportLab might change their layout compared to the old FPDF multi-cell flow. Verify that generated PDFs remain clean and readable.
- **Mocking Strategy**: Since we are moving email delivery to a service, route tests no longer need to monkeypatch SMTP internals; they can mock the `ReportDeliveryService` directly.

## Validation Strategy

- Compile `survey-backend`.
- Ensure all 189 tests pass successfully.
- Verify path containment safety for the generated PDFs.

