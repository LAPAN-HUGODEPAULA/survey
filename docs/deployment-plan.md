# Deployment & Operations

## Environments
- **Local**: Docker Compose from repo root.
- **Production**: Single-host Compose or compatible orchestrator using the same services and environment variables.

## Prerequisites
- Docker and Docker Compose installed.
- `.env` populated (copy from `.env.example`); at minimum set `MONGO_URI`, `MONGO_INITDB_ROOT_USERNAME`, `MONGO_INITDB_ROOT_PASSWORD`. Optional build args: `DEFAULT_SCREENER_NAME`, `DEFAULT_SCREENER_CONTACT`, `FLAVOR`.
- Ports available: 27017 (Mongo), 8000 (API), 8080/8081/8082 (web apps), 9566 (Clinical Writer when running its compose file).

## Services (root `docker-compose.yml`)
- `mongodb`: MongoDB 6.0 with mounted volume `mongodb_data`.
- `survey-backend`: FastAPI API server.
- `frontend`: Flutter screener app served by NGINX.
- `patient_app`: Flutter patient app served by NGINX.
- `clinical-narrative`: Flutter narrative viewer.
- `survey-worker`: background processor pushing responses to Clinical Writer.

## Optional Service
- `clinical-writer-api`: LangGraph/LLM service. Start separately when AI enrichment is needed:
  ```bash
  docker compose -f services/clinical-writer-api/docker-compose.yml up -d clinical-writer-api
  ```

## Startup
```bash
docker compose up -d mongodb survey-backend frontend patient_app clinical-narrative survey-worker
```

## Verification
- Backend OpenAPI UI: http://localhost:8000/docs
- Screener app: http://localhost:8080
- Patient app: http://localhost:8081
- Clinical narrative app: http://localhost:8082
- Clinical Writer (if running): http://localhost:9566
- Logs: `docker compose logs -f <service>`

## Rollback / Restart
```bash
docker compose down
# then start again if needed
docker compose up -d mongodb survey-backend frontend patient_app clinical-narrative survey-worker
```

## Maintenance
- Refresh SDKs after contract changes: `tools/scripts/generate_clients.sh`.
- Backend compile check: `python -m compileall services/survey-backend/app`.
- Worker config: tune polling and batch env vars to balance load and latency.
