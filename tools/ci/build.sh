#!/usr/bin/env bash
set -euo pipefail

# Regenerate API clients
echo "Regenerating API clients..."
./tools/scripts/generate_clients.sh

# Build the docker images
echo "Building Docker images..."
docker compose down
docker compose build survey-backend clinical-writer-api survey-worker
docker compose build survey-frontend
docker compose build survey-patient

# Start the services
echo "Starting services..."
docker compose up -d
echo "All services are up and running."