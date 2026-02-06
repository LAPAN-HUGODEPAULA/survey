# Survey Backend Service

This service is the main backend for the LAPAN Survey Platform. It is a FastAPI application that provides a RESTful API for managing surveys, survey responses, and patient responses.

## Features

- **Survey Management**: Provides CRUD operations for surveys.
- **Survey Response Management**: Provides CRUD operations for survey responses.
- **Patient Response Management**: Provides CRUD operations for patient responses.
- **Email Integration**: Sends emails with survey responses.
- **Clinical Writer Integration**: Submits survey responses to the Clinical Writer API for enrichment.
- **Authentication and Authorization**: Manages access control for the platform.

## Tech Stack

- **Backend**: Python/FastAPI
- **Database**: MongoDB

## Running the Service

To run the service, you need to have Docker and Docker Compose installed. From the root of the project, run:

```bash
docker compose up -d survey-backend
```

The service will be available at `http://localhost:8000`. The API documentation is available at `http://localhost:8000/docs`.
