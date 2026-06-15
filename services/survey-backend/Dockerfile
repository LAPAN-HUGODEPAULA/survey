FROM python:3.13-slim AS builder

RUN pip install --no-cache-dir uv

WORKDIR /workspace

COPY pyproject.toml uv.lock ./
COPY packages/python/lapan-core/pyproject.toml packages/python/lapan-core/
COPY packages/python/lapan-core/lapan_core/ packages/python/lapan-core/lapan_core/
COPY services/survey-backend/pyproject.toml services/survey-backend/

RUN uv sync --frozen --no-dev --package survey-backend

FROM python:3.13-slim

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

COPY --from=builder /workspace/.venv /app/.venv
COPY --from=builder /workspace/packages/python/lapan-core /app/lapan-core
COPY services/survey-backend/ .

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH=/app

RUN chown -R appuser:appgroup /app

USER appuser

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
