FROM python:3.11-slim

WORKDIR /app

# Install uv as the package manager
RUN pip install --no-cache-dir uv

COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt

COPY . .

ENV PYTHONPATH=/app

CMD ["uv", "run", "python", "-m", "app.main"]
