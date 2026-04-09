# Survey Worker

Background worker that enriches survey responses by submitting them to the Clinical Writer agent and storing the resulting medical narrative and classification back into MongoDB.

## Configuration

Environment variables:
- `MONGO_URI` (default: `mongodb://localhost:27017`)
- `MONGO_DB_NAME` (default: `survey_db`)
- `CLINICAL_WRITER_URL` (default: `http://clinical_writer_agent:8000/process`)
- `CLINICAL_WRITER_API_TOKEN` (optional bearer token)
- `POLL_INTERVAL_SECONDS` (default: `10`) – delay between polling cycles
- `BATCH_SIZE` (default: `10`) – number of survey responses processed per cycle
- `PROCESSING_STALE_AFTER_SECONDS` (default: `60`) – retry a response left in `processing` beyond this age
- `HTTP_TIMEOUT_SECONDS` (default: `15`)

## Development

Install dependencies with `uv`:
```bash
uv pip install -r requirements.txt
```

Run the worker locally:
```bash
uv run python -m app.main
```

## Behavior

The worker scans the `survey_responses` collection for documents without an `agentResponse`, with status `pending`/`failed`, or with a stale `processing` status, sends them to the Clinical Writer agent, and updates the document with:
- `agentResponse`: agent payload (`ok`, `input_type`, `prompt_version`, `questionnaire_prompt_version`, `persona_skill_version`, `model_version`, `report`, `warnings`, `classification`, `medicalRecord`, `errorMessage`)
- `agentResponseStatus`: `processing` → `succeeded`/`failed`
- `agentResponseUpdatedAt`: timestamp of the last attempt

Only `survey_responses` are enriched by this worker. `patient_responses` are persisted by the backend but are not currently processed by the background job.
