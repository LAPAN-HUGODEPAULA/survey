FROM python:3.13-slim AS builder

RUN pip install --no-cache-dir uv

WORKDIR /workspace

COPY pyproject.toml uv.lock ./
COPY packages/python/lapan-core/pyproject.toml packages/python/lapan-core/
COPY packages/python/lapan-core/lapan_core/ packages/python/lapan-core/lapan_core/
COPY services/clinical-writer-api/clinical_writer_agent/pyproject.toml services/clinical-writer-api/clinical_writer_agent/

RUN uv sync --frozen --no-dev --package clinical-writer-agent

FROM python:3.13-slim

WORKDIR /app

COPY --from=builder /workspace/.venv /app/.venv
COPY --from=builder /workspace/packages/python/lapan-core /app/lapan-core
COPY services/clinical-writer-api/clinical_writer_agent/ .

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH=/app

EXPOSE 8000

CMD ["uvicorn", "clinical_writer_agent.main:app", "--host", "0.0.0.0", "--port", "8000"]
