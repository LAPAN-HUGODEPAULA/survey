FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/clinical_writer_agent

ENV PYTHONPATH=/app

EXPOSE 8000

CMD ["uvicorn", "clinical_writer_agent.main:app", "--host", "0.0.0.0", "--port", "8000"]
