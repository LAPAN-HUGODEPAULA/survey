# Clinical Narrative Application

This application is part of the LAPAN Survey Platform. It is a conversational platform for clinical documentation, designed to help healthcare professionals transform clinician-patient interactions into structured medical records.

## Features

- **Conversational Platform**: The application is structured as a conversational platform with sessions, history, and clinical context.
- **Voice Capture**: It has voice capture with hybrid transcription (browser preview + final server processing).
- **Clinical Assistance**: It includes clinical assistance with suggestions and gap detection.
- **Document Generation**: It can generate multiple clinical document types and allow export/printing.
- **Template Management**: It has a centralized template management system with versioning and approvals.

## Tech Stack

- **Frontend**: Flutter for Web
- **Backend**: The application consumes the `survey-backend` API.

## Running the Application

To run the application, you need to have Docker and Docker Compose installed. From the root of the project, run:

```bash
docker compose up -d clinical-narrative
```

The application will be available at `http://localhost:8082`.
