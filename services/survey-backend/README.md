# Survey Backend Service

This service is the main backend for the LAPAN Survey Platform. It is a FastAPI application that provides a RESTful API for managing surveys, survey responses, and patient responses.

## Features

- **Survey Management**: Provides CRUD operations for surveys.
- **Survey Response Management**: Provides CRUD operations for survey responses.
- **Patient Response Management**: Provides CRUD operations for patient responses.
- **Email Integration**: Sends emails with survey and patient responses.
- **Screener Authentication**: Supports screener registration, login, profile lookup, and password recovery.
- **Clinical Writer Integration**: Submits survey responses to the Clinical Writer API for enrichment.
- **Authentication and Authorization**: Manages access control for the platform.

## Screener Auth Notes

- Passwords are stored as bcrypt hashes in the `screeners` collection.
- `POST /api/v1/screeners/recover-password` uses the same SMTP/FastMail configuration as response email delivery.
- Fresh local migrations from `tools/migrations/survey-backend/002_consolidated_migration.py` seed:
  - `lapan.hugodepaula@gmail.com` with `SystemPassword123!`
  - `maria.vale@holhos.com` with `SamplePassword123!`
- Those seed passwords stop working as soon as the account password is manually reset or recovered through the API.

## Tech Stack

- **Backend**: Python/FastAPI
- **Database**: MongoDB

## Running the Service

To run the service, you need to have Docker and Docker Compose installed. From the root of the project, run:

```bash
docker compose up -d survey-backend
```

The service will be available at `http://localhost:8000`. The API documentation is available at `http://localhost:8000/docs`.

## Operational helpers

- `tools/scripts/export_vps_mongo.sh` captures a VPS snapshot by running `mongodump`/`mongoexport` inside the `mongodb` container and copying both the archive and per-collection JSON to `tools/migrations/survey-backend/exports/<timestamp>/`.
- `tools/scripts/restore_vps_mongo.sh` replays a snapshot on the VPS. By default it upserts the JSON exports to avoid data loss, but you can pass `--full-restore` to run `mongorestore --drop` against the archive when a full replacement is required.
