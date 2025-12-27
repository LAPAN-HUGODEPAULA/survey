# Clinical Writer AI Multiagent System

This project implements an AI multiagent system using the LangGraph framework to convert clinical conversations and patient data into structured medical record style text.

## Features

* **Input Flexibility:** Accepts plain text conversations or JSON patient data.
* **Content Filtering:** Filters out inappropriate and non-medical content.
* **Intelligent Classification:** Classifies input into conversation, JSON, or other.
* **Medical Record Generation:** Generates structured medical records using Google Gemini Pro.
* **REST API:** Provides a RESTful API for seamless integration with other systems.
* **Dockerized Deployment:** Designed for on-premise deployment using Docker containers.

## Monitoring & Metrics

The LangGraph workflow runs with a shared `CompositeMonitor` that bundles structured logging and in-memory metrics collection. Each request threads this observer through the agent state, so processing, validation, and classification events are captured consistently. The `/metrics` endpoint returns the live metrics snapshot from this shared monitor—no restart or file export required.

## Getting Started

More details on setup and usage will be provided here.

## Project Structure

```plain
.
├── Dockerfile
├── README.md
├── requirements.txt
├── .gitignore
├── src/
│   └── main.py  # Main FastAPI application and LangGraph orchestration
└── tests/
    └── test_main.py # Unit and integration tests
```
