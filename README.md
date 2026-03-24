# LAPAN Survey Platform

Monorepo for the LAPAN healthcare survey and clinical narrative platform. It includes a FastAPI backend, background worker, Flutter web applications, an AI-powered Clinical Writer service, and shared contracts/design system packages.

## Repository Layout
- `services/survey-backend` – FastAPI API for surveys, survey responses, and patient responses (MongoDB persistence via repositories).
- `services/survey-worker` – background processor that enriches responses via the Clinical Writer API.
- `services/clinical-writer-api` – LangGraph/LLM-based clinical narrative service (runs separately when AI enrichment is needed).
- `apps/` – Flutter web apps (`survey-frontend`, `survey-patient`, `clinical-narrative`, `survey-builder`) using the shared design system.
- `packages/` – OpenAPI contract + generated SDKs (`contracts`), Flutter design system, and shared Python utilities.
- `tools/` – scripts for client generation and CI tooling.

## Quick Start
```bash
# 1) Copy config/runtime/config.private.example.json to config/runtime/config.private.json
# 2) Fill in the real values
# 3) Render runtime config artifacts
python3 tools/scripts/render_runtime_config.py
# 4) Start the core stack
./tools/scripts/compose_local.sh up -d mongodb survey-backend survey-frontend survey-patient clinical-narrative survey-builder survey-worker
# 5) Optional: start the Clinical Writer AI service (same compose file)
./tools/scripts/compose_local.sh up -d clinical-writer-api
```

- Backend docs: http://localhost:8000/docs
- Screener app: http://localhost:8080
- Patient app: http://localhost:8081
- Clinical narrative app: http://localhost:8082
- Survey builder app: http://localhost:8083
- Clinical Writer (optional): http://localhost:9566

## Development Notes
- Contract source: `packages/contracts/survey-backend.openapi.yaml`; regenerate SDKs with `tools/scripts/generate_clients.sh`.
- Backend sanity check: `python -m compileall services/survey-backend/app`.
- Runtime config source-of-truth: `config/runtime/config.private.json`; generated artifacts live under `config/runtime/generated/`.
- Flutter apps use the shared `design_system_flutter` theme (seed color `Colors.orange`).
- Full-screen Flutter pages should use the shared `DsScaffold` contract from `packages/design_system_flutter`, which standardizes `appBar + body + mandatory footer/status bar`.
- Clinical Writer `/process` returns JSON-only ReportDocument output; sample payloads live under `samples/clinical-writer/`.
- Prompts are stored in Google Drive and resolved by `prompt_key` via PromptRegistry.

## Documentation
Authoritative docs live in `docs/`:
- Index: `docs/README.md`
- Requirements, technical spec, software design, API docs, deployment plan, release notes, and weekly changelog.
