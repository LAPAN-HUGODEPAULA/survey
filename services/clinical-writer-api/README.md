# Clinical Writer API Service

This service is part of the LAPAN Survey Platform. It is an AI-powered service that generates clinical narratives from survey responses.

## Features

- **Input Handling**: Accepts survey responses from the `survey-backend` service.
- **Content Validation**: Sanitizes and filters inappropriate or irrelevant content.
- **Medical Report Generation**: Utilizes a Large Language Model (LLM) to generate comprehensive medical reports.
- **Error Handling**: Gracefully handles invalid inputs and API errors.

## Tech Stack

- **Backend**: Python/FastAPI/LangGraph
- **AI Model**: Google Gemini Pro

## Running the Service

To run the service, you need to have Docker and Docker Compose installed. From the root of the project, run:

```bash
docker compose up -d clinical-writer-api
```

The service will be available at `http://localhost:9566`.
