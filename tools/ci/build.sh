#!/usr/bin/env bash
set -euo pipefail

# Regenerate API clients
echo "Regenerating API clients..."
./tools/scripts/generate_clients.sh

# Build the docker images
echo "Building Docker images..."
./tools/scripts/compose_local.sh down
./tools/scripts/compose_local.sh build survey-backend clinical-writer-api survey-worker
./tools/scripts/compose_local.sh build survey-frontend
./tools/scripts/compose_local.sh build survey-patient

# Start the services
echo "Starting services..."
./tools/scripts/compose_local.sh up -d
echo "All services are up and running."
