# LAPAN Survey Platform

Monorepo for the LAPAN healthcare survey and clinical narrative platform. It includes a FastAPI backend, background worker, Flutter web applications, an AI-powered Clinical Writer service, and shared contracts/design system packages.

## Repository Layout
- `services/survey-backend` – FastAPI API for surveys, survey responses, and patient responses (MongoDB persistence via repositories).
- `services/survey-worker` – background processor that enriches responses via the Clinical Writer API.
- `services/clinical-writer-api` – LangGraph/LLM-based clinical narrative service (runs separately when AI enrichment is needed).
- `apps/` – Flutter web apps (`survey-frontend`, `survey-patient`, `clinical-narrative`) using the shared design system.
- `packages/` – OpenAPI contract + generated SDKs (`contracts`), Flutter design system, and shared Python utilities.
- `tools/` – scripts for client generation and CI tooling.

## Quick Start
```bash
# 1) Populate .env with Mongo credentials and service endpoints
# 2) Start the core stack
docker compose up -d mongodb survey-backend survey-frontend survey-patient clinical-narrative survey-worker
# 3) Optional: start the Clinical Writer AI service (same compose file)
docker compose up -d clinical-writer-api
```

- Backend docs: http://localhost:8000/docs
- Screener app: http://localhost:8080
- Patient app: http://localhost:8081
- Clinical narrative app: http://localhost:8082
- Clinical Writer (optional): http://localhost:9566

## Development Notes
- Contract source: `packages/contracts/survey-backend.openapi.yaml`; regenerate SDKs with `tools/scripts/generate_clients.sh`.
- Backend sanity check: `python -m compileall services/survey-backend/app`.
- Flutter apps use the shared `design_system_flutter` theme (seed color `Colors.orange`).
- Clinical Writer `/process` returns JSON-only ReportDocument output; sample payloads live under `samples/clinical-writer/`.
- Prompts are stored in Google Drive and resolved by `prompt_key` via PromptRegistry.

## Documentation
Authoritative docs live in `docs/`:
- Index: `docs/README.md`
- Requirements, technical spec, software design, API docs, deployment plan, release notes, and weekly changelog.
