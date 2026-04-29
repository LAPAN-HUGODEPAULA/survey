#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

MONGO_CONTAINER="${SURVEY_MONGO_CONTAINER:-mongodb}"
BACKEND_SERVICE="${SURVEY_BACKEND_SERVICE:-survey-backend}"

echo "==> 1/8 Backup current MongoDB snapshot"
./tools/scripts/export_vps_mongo.sh

echo "==> 2/8 Ensure runtime config and MongoDB are available"
docker compose up -d "$MONGO_CONTAINER"

echo "==> 3/8 Load runtime env"
set -a
. config/runtime/generated/private/survey-backend.env
. config/runtime/generated/private/mongodb.env
set +a

echo "==> 4/8 Activate survey-backend virtualenv"
source services/survey-backend/.venv/bin/activate

echo "==> 5/8 Resolve host-reachable MongoDB URI"
MONGO_CONTAINER_IP="$(
  docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$MONGO_CONTAINER"
)"

if [[ -z "$MONGO_CONTAINER_IP" ]]; then
  echo "Could not resolve IP for container '$MONGO_CONTAINER'." >&2
  exit 1
fi

export MONGO_CONTAINER_IP
export MONGO_URI="mongodb://${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}@${MONGO_CONTAINER_IP}:27017/?authSource=admin"

echo "==> 6/8 Drop application database"
docker exec "$MONGO_CONTAINER" mongosh \
  --username "$MONGO_INITDB_ROOT_USERNAME" \
  --password "$MONGO_INITDB_ROOT_PASSWORD" \
  --authenticationDatabase admin \
  --eval "db.getSiblingDB('$MONGO_DB_NAME').dropDatabase()"

echo "==> 7/8 Rebuild schema and seed data"
uv run python tools/migrations/survey-backend/003_populate_new_schema.py
uv run python tools/migrations/survey-backend/007_add_screener_initial_notice_agreement.py
uv run python tools/migrations/survey-backend/008_seed_starter_prompt_catalog.py
uv run python tools/migrations/survey-backend/009_seed_default_agent_access_points.py

echo "==> 8/8 Restart backend services"
docker compose restart "$BACKEND_SERVICE" survey-worker

echo "==> MongoDB reset complete"
