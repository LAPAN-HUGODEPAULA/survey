# Clinical Writer AI Multiagent System

## Overview

The Clinical Writer AI is a multi-agent system designed to assist in generating medical reports. It processes either raw text transcripts of doctor-patient conversations or structured JSON objects, and leverages a large language model (LLM) to produce formal medical reports.

## Features

* **Input Handling**: Accepts plain text conversations or structured JSON data.
* **Content Validation**: Sanitizes and filters inappropriate or irrelevant content.
* **Input Classification**: Automatically classifies input as `conversation`, `json`, or `other`.
* **Medical Report Generation**: Utilizes the Google Gemini Pro LLM to generate comprehensive medical reports.
* **Error Handling**: Gracefully handles invalid inputs and API errors.

## System Architecture

The core logic is implemented as a graph of interconnected nodes (agents) using LangGraph. This promotes modularity, scalability, and maintainability. The system exposes a RESTful API via FastAPI.

## Setup and Installation

1. **Clone the repository**:

```bash
git clone https://github.com/LAPAN-HUGODEPAULA/clinical_writer.git
cd clinical_writer
```

2. **Set up the Python virtual environment**:

```bash
python3 -m venv clinical_writer_agent/.venv
source clinical_writer_agent/.venv/bin/activate
pip install -r clinical_writer_agent/requirements.txt
```

3. **Configure API Key**:

Create a `.env` file in the `clinical_writer_agent/` directory and add your Gemini Pro API key:

```plain
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

Replace `YOUR_GEMINI_API_KEY` with your actual API key.

Optional prompt registry settings (for Google Drive-backed prompts):

```plain
PROMPT_PROVIDER=google_drive
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
GOOGLE_DRIVE_FOLDER_ID=your-folder-id
PROMPT_DOC_MAP_JSON={"default":"doc_id","survey7":"doc_id"}
PROMPT_CACHE_TTL_SECONDS=60
```

## Running the Application

To start the FastAPI application, navigate to the project root and run:

```bash
source clinical_writer_agent/venv/bin/activate
uvicorn clinical_writer_agent.src.main:app --reload
```

The application will be accessible at `http://127.0.0.1:8000`.

## Running in Docker

Build the container image from the project root using the provided Dockerfile:

```bash
docker build -t clinical-writer -f clinical_writer_agent/Dockerfile clinical_writer_agent
```

Run the API from the image, supplying your `.env` for the Gemini key and exposing the port:

```bash
docker run --rm -it \
  --env-file clinical_writer_agent/.env \
  -p 9566:8000 \
  clinical-writer
```

> Note: The image defaults to `uvicorn clinical_writer_agent.main:app --host 0.0.0.0 --port 8000`; override the command if you need a different entrypoint.

## Testing from Docker

You can execute the test suite inside the container by overriding the command:

```bash
docker run --rm -it clinical-writer pytest tests -q
```

If your tests require environment variables (for example, `GEMINI_API_KEY`), include the same `--env-file clinical_writer_agent/.env` option used for the run command.

## Running with Docker Compose

Build and start the API with Docker Compose from the repository root:

```bash
docker compose up --build
```

By default the service exposes `http://localhost:9566` (host) mapped to container port 8000. Ensure `clinical_writer_agent/.env` contains your `GEMINI_API_KEY`; it is loaded automatically by the compose service. To run tests in the compose service instead of the API, override the command:

```bash
docker compose run --rm clinical-writer-api pytest tests -q
```

## API Endpoints

* **GET /**: Returns a welcome message.
* **POST /invoke**: Processes clinical data and generates a medical report. Expects a JSON body with an `input_content` field.

## Testing

To run the tests, ensure your virtual environment is activated and run:

```bash
pytest clinical_writer_agent/tests/
```

## Documentation

Refer to the `docs/` directory for detailed documentation on API, architecture, deployment, and more.
