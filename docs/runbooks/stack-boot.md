# Stack Boot Guide

## Prerequisites
- Docker and Docker Compose
- Python 3 (for quick compile checks)
- Flutter SDK (for app builds)
- Environment: `.env` in repo root with `MONGO_URI` (and optional `MONGO_INITDB_ROOT_USERNAME`/`MONGO_INITDB_ROOT_PASSWORD` for local Mongo)

## Start the stack (monorepo layout)
```bash
docker compose up -d mongodb survey-backend survey-frontend survey-patient clinical-narrative
```

Service ports:
- Backend API: http://localhost:8000/api/v1/
- Screener web: http://localhost:8080
- Patient web: http://localhost:8081
- Clinical narrative web: http://localhost:8082

## Health checks
- Backend: `curl http://localhost:8000/docs` or `GET /api/v1/surveys`
- Mongo: `docker compose exec mongodb mongosh --eval 'db.runCommand({ping:1})'`
- Containers: `docker compose ps`

## Common issues
- **Backend import errors**: ensure `docker-compose.yml` uses `./services/survey-backend` build context and `PYTHONPATH` is set by the Dockerfile (already set).
- **Mongo auth failures**: set `MONGO_URI` to include credentials that match Mongo env vars when starting compose.
- **Ports in use**: stop other services using 8000/8080/8081 or override ports in compose.
