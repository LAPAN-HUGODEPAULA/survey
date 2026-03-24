# Deployment & Operations

## Environments

- **Local**: Docker Compose from repo root.
- **Production**: Single-host Compose or compatible orchestrator using the same services and environment variables.

## Prerequisites

- Docker and Docker Compose installed.
- `config/runtime/config.private.json` populated from `config/runtime/config.private.example.json`.
- Runtime artifacts rendered before startup with `python3 tools/scripts/render_runtime_config.py`.
- Ports available: 27017 (Mongo), 8000 (API), 8080/8081/8082 (web apps), 9566 (Clinical Writer when enabled).

## Services (root `docker-compose.yml`)

- `mongodb`: MongoDB 6.0 with mounted volume `mongodb_data`.
- `survey-backend`: FastAPI API server.
- `frontend`: Flutter screener app served by NGINX.
- `patient_app`: Flutter patient app served by NGINX.
- `clinical-narrative`: Flutter narrative viewer.
- `survey-worker`: background processor pushing responses to Clinical Writer.
- `clinical-writer-api`: LangGraph/LLM service for AI enrichment.

## Startup

```bash
python3 tools/scripts/render_runtime_config.py
./tools/scripts/compose_local.sh up -d mongodb survey-backend survey-frontend survey-patient clinical-narrative survey-worker
# Optional: enable Clinical Writer when AI enrichment is needed
./tools/scripts/compose_local.sh up -d clinical-writer-api
```

## Verification

- Backend OpenAPI UI: <http://localhost:8000/docs>
- Screener app: <http://localhost:8080>
- Patient app: <http://localhost:8081>
- Clinical narrative app: <http://localhost:8082>
- Clinical Writer (if running): <http://localhost:9566>
- Logs: `docker compose logs -f <service>`

## Rollback / Restart

```bash
./tools/scripts/compose_local.sh down
# then start again if needed
./tools/scripts/compose_local.sh up -d mongodb survey-backend frontend patient_app clinical-narrative survey-worker
```

## Maintenance

- Runtime config source-of-truth: `config/runtime/config.private.json` (gitignored).
- Public and private generated runtime artifacts: `config/runtime/generated/`.
- Refresh SDKs after contract changes: `tools/scripts/generate_clients.sh`.
- Backend compile check: `python -m compileall services/survey-backend/app`.
- Worker config: tune polling and batch env vars to balance load and latency.
