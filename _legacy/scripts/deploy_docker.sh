#!/usr/bin/env bash
set -e

# Usage: ./deploy_docker.sh [local|atlas]

TARGET=${1:-local}

# Load environment variables from .env if it exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

if [ "$TARGET" == "local" ]; then
  echo "Deploying with LOCAL MongoDB container..."
  export COMPOSE_PROFILES=local
  # Fallback to constructed URI if MONGO_URI_LOCAL is not set
  export MONGO_URI=${MONGO_URI_LOCAL:-mongodb://${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}@mongodb:27017}
elif [ "$TARGET" == "atlas" ]; then
  echo "Deploying with ATLAS MongoDB..."
  export COMPOSE_PROFILES=""
  if [ -z "$MONGO_URI_ATLAS" ]; then
    echo "Error: MONGO_URI_ATLAS is not set in .env"
    exit 1
  fi
  export MONGO_URI=$MONGO_URI_ATLAS
else
  echo "Usage: $0 [local|atlas]"
  exit 1
fi

echo "MONGO_URI: $MONGO_URI"
echo "COMPOSE_PROFILES: $COMPOSE_PROFILES"

docker compose up -d --build
