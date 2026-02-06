# Survey Builder Application

This application is part of the LAPAN Survey Platform. It is a dedicated application for administrators and researchers to create, view, update, and delete surveys directly within the LAPAN Survey Platform ecosystem.

## Features

- **Full Survey Editing**: It allows editing of all survey fields, including instructions and questions.
- **Validation**: It enforces that a survey must contain at least one question and each question must have at least one answer.
- **Consistent UI/UX**: It leverages the existing design system to ensure UI/UX consistency with other platform applications.

## Tech Stack

- **Frontend**: Flutter for Web
- **Backend**: The application consumes the `survey-backend` API.

## Running the Application

To run the application, you need to have Docker and Docker Compose installed. From the root of the project, run:

```bash
docker compose up -d survey-builder
```

The application will be available at `http://localhost:8083`.