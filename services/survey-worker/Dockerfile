FROM python:3.11-slim

# Create a non-privileged user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup --home /home/appuser appuser
ENV HOME=/home/appuser

WORKDIR /app

# Install uv as the package manager
RUN pip install --no-cache-dir uv

COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt

COPY . .

# Change ownership of the app directory
RUN chown -R appuser:appgroup /app

# Switch to the non-privileged user
USER appuser

ENV PYTHONPATH=/app

CMD ["uv", "run", "python", "-m", "app.main"]
