FROM python:3.13-slim AS builder

RUN pip install --no-cache-dir uv

WORKDIR /workspace

COPY pyproject.toml uv.lock ./
COPY packages/python/lapan-core/pyproject.toml packages/python/lapan-core/
COPY packages/python/lapan-core/lapan_core/ packages/python/lapan-core/lapan_core/
COPY services/survey-worker/pyproject.toml services/survey-worker/

RUN uv sync --frozen --no-dev --package survey-worker

FROM python:3.13-slim

RUN addgroup --system appgroup && adduser --system --ingroup appgroup --home /home/appuser appuser
ENV HOME=/home/appuser

WORKDIR /app

COPY --from=builder /workspace/.venv /app/.venv
COPY --from=builder /workspace/packages/python/lapan-core /app/lapan-core
COPY services/survey-worker/ .

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH=/app

RUN chown -R appuser:appgroup /app

USER appuser

CMD ["python", "-m", "app.main"]
