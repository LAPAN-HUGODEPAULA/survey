#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REMOTE_HOST="${SURVEY_VPS_HOST:-root@72.61.60.27}"
REMOTE_DIR="${SURVEY_VPS_DIR:-/root/survey}"
REMOTE_CONTAINER="${SURVEY_MONGO_CONTAINER:-mongodb}"
REMOTE_TMP_BASE="${SURVEY_MONGO_REMOTE_TMP:-/tmp}"
OUTPUT_ROOT="${SURVEY_MONGO_EXPORT_ROOT:-$ROOT_DIR/tools/migrations/survey-backend/exports}"
RSYNC_SSH="sshpass -e ssh"
SCAFFOLD_MIGRATION=0
KEEP_REMOTE=0
COLLECTIONS_CSV=""
MIGRATION_NAME="import_vps_snapshot"

usage() {
  cat <<'EOF'
Usage: ./tools/scripts/export_vps_mongo.sh [options]

Create a safe MongoDB snapshot from the VPS and copy it locally.

By default the script creates:
  - a full gzipped mongodump archive for rollback/restore safety
  - JSON exports for each collection under tools/migrations/survey-backend/exports/<timestamp>/

Options:
  --collections a,b,c       Export only the listed collections as JSON.
                            The raw mongodump archive still contains the full database.
  --scaffold-migration      Generate a new migration script that replays the exported
                            JSON with replace_one(..., upsert=True).
  --migration-name NAME     Suffix used for the generated migration file.
                            Default: import_vps_snapshot
  --output-root PATH        Local snapshot directory root.
  --remote-host HOST        VPS SSH host. Default matches deploy_vps.sh.
  --remote-dir PATH         VPS project directory. Default: /root/survey
  --remote-container NAME   MongoDB container name. Default: mongodb
  --keep-remote             Keep the temporary export directory on the VPS.
  -h, --help                Show this help text.

Requirements:
  - SSH password must be available through sshpass (for example SSHPASS).
  - The VPS stack must already have rendered config/runtime/generated/private/*.env.

Notes:
  - Do not commit the exported snapshot directory. It is intentionally gitignored.
  - The generated migration script is safe by default: it upserts documents and does
    not delete records that are missing from the export.
EOF
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 1
  fi
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//; s/_+/_/g'
}

next_migration_number() {
  local max_number="0"
  local file_name

  while IFS= read -r file_name; do
    local base_name
    local prefix
    base_name="$(basename "$file_name")"
    prefix="${base_name%%_*}"
    if [[ "$prefix" =~ ^[0-9]{3}$ ]] && (( 10#$prefix > 10#$max_number )); then
      max_number="$prefix"
    fi
  done < <(find "$ROOT_DIR/tools/migrations/survey-backend" -maxdepth 1 -type f -name '*.py' | sort)

  printf '%03d' "$((10#$max_number + 1))"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --collections)
      COLLECTIONS_CSV="${2:-}"
      shift 2
      ;;
    --scaffold-migration)
      SCAFFOLD_MIGRATION=1
      shift
      ;;
    --migration-name)
      MIGRATION_NAME="${2:-}"
      shift 2
      ;;
    --output-root)
      OUTPUT_ROOT="${2:-}"
      shift 2
      ;;
    --remote-host)
      REMOTE_HOST="${2:-}"
      shift 2
      ;;
    --remote-dir)
      REMOTE_DIR="${2:-}"
      shift 2
      ;;
    --remote-container)
      REMOTE_CONTAINER="${2:-}"
      shift 2
      ;;
    --keep-remote)
      KEEP_REMOTE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

require_command sshpass
require_command ssh
require_command rsync
require_command find
require_command sed
require_command date

TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"
LOCAL_SNAPSHOT_DIR="$OUTPUT_ROOT/$TIMESTAMP"
LOCAL_EXPORTS_DIR="$LOCAL_SNAPSHOT_DIR/exports"
REMOTE_SNAPSHOT_DIR="$REMOTE_TMP_BASE/survey-mongo-export-$TIMESTAMP"
ARCHIVE_NAME="mongo_dump_$TIMESTAMP.archive.gz"

mkdir -p "$LOCAL_SNAPSHOT_DIR"

echo "Creating VPS MongoDB snapshot: $TIMESTAMP"
echo "Remote host: $REMOTE_HOST"
echo "Local output: $LOCAL_SNAPSHOT_DIR"

sshpass -e ssh "$REMOTE_HOST" "bash -s" -- \
  "$REMOTE_DIR" \
  "$REMOTE_SNAPSHOT_DIR" \
  "$ARCHIVE_NAME" \
  "$COLLECTIONS_CSV" \
  "$REMOTE_CONTAINER" <<'REMOTE_SCRIPT'
set -euo pipefail

REMOTE_DIR="$1"
REMOTE_SNAPSHOT_DIR="$2"
ARCHIVE_NAME="$3"
COLLECTIONS_CSV="$4"
REMOTE_CONTAINER="$5"

cd "$REMOTE_DIR"

set -a
. config/runtime/generated/private/survey-backend.env
. config/runtime/generated/private/mongodb.env
set +a

mkdir -p "$REMOTE_SNAPSHOT_DIR/exports"

docker exec "$REMOTE_CONTAINER" sh -lc "
  mongodump \
    --host localhost \
    --port 27017 \
    --username \"\$MONGO_INITDB_ROOT_USERNAME\" \
    --password \"\$MONGO_INITDB_ROOT_PASSWORD\" \
    --authenticationDatabase admin \
    --db \"$MONGO_DB_NAME\" \
    --archive \
    --gzip
" > "$REMOTE_SNAPSHOT_DIR/$ARCHIVE_NAME"

if [[ -n "$COLLECTIONS_CSV" ]]; then
  IFS=',' read -r -a COLLECTIONS <<< "$COLLECTIONS_CSV"
else
  mapfile -t COLLECTIONS < <(
    docker exec "$REMOTE_CONTAINER" sh -lc "
      mongosh \
        --quiet \
        --username \"\$MONGO_INITDB_ROOT_USERNAME\" \
        --password \"\$MONGO_INITDB_ROOT_PASSWORD\" \
        --authenticationDatabase admin \
        --eval 'db.getSiblingDB(\"$MONGO_DB_NAME\").getCollectionNames().join(\"\\n\")'
    "
  )
fi

printf '%s\n' "${COLLECTIONS[@]}" > "$REMOTE_SNAPSHOT_DIR/exports/collections.txt"

for raw_collection in "${COLLECTIONS[@]}"; do
  collection="$(printf '%s' "$raw_collection" | xargs)"
  if [[ -z "$collection" ]]; then
    continue
  fi

  docker exec "$REMOTE_CONTAINER" sh -lc "
    mongoexport \
      --host localhost \
      --port 27017 \
      --username \"\$MONGO_INITDB_ROOT_USERNAME\" \
      --password \"\$MONGO_INITDB_ROOT_PASSWORD\" \
      --authenticationDatabase admin \
      --db \"$MONGO_DB_NAME\" \
      --collection \"$collection\" \
      --jsonArray \
      --pretty
  " > "$REMOTE_SNAPSHOT_DIR/exports/$collection.json"
done
REMOTE_SCRIPT

rsync -vrupthlgo \
  -e "$RSYNC_SSH" \
  "$REMOTE_HOST:$REMOTE_SNAPSHOT_DIR/" \
  "$LOCAL_SNAPSHOT_DIR/"

if [[ "$KEEP_REMOTE" -eq 0 ]]; then
  sshpass -e ssh "$REMOTE_HOST" "rm -rf '$REMOTE_SNAPSHOT_DIR'"
fi

MIGRATION_FILE=""

if [[ "$SCAFFOLD_MIGRATION" -eq 1 ]]; then
  mkdir -p "$LOCAL_EXPORTS_DIR"

  migration_slug="$(slugify "$MIGRATION_NAME")"
  if [[ -z "$migration_slug" ]]; then
    echo "Migration name must contain at least one alphanumeric character." >&2
    exit 1
  fi

  migration_number="$(next_migration_number)"
  MIGRATION_FILE="$ROOT_DIR/tools/migrations/survey-backend/${migration_number}_${migration_slug}.py"

  cat > "$MIGRATION_FILE" <<EOF
\"\"\"Replay a VPS MongoDB snapshot exported with tools/scripts/export_vps_mongo.sh.

This migration intentionally reads from a gitignored export directory so that raw
MongoDB data does not need to be committed to the repository.
\"\"\"

import os
from pathlib import Path
from urllib.parse import urlparse

from bson import json_util
from dotenv import load_dotenv
from pymongo import MongoClient


load_dotenv()

EXPORT_DIR = (
    Path(__file__).resolve().parents[3]
    / "tools"
    / "migrations"
    / "survey-backend"
    / "exports"
    / "$TIMESTAMP"
    / "exports"
)


def resolve_mongo_uri() -> str:
    mongo_uri = os.getenv("MONGO_URI")
    if not mongo_uri:
        mongo_username = os.getenv("MONGO_USERNAME")
        mongo_password = os.getenv("MONGO_PASSWORD")
        if mongo_username and mongo_password:
            mongo_uri = f"mongodb://{mongo_username}:{mongo_password}@localhost:27017/"
        else:
            mongo_uri = "mongodb://localhost:27017/"
    elif not mongo_uri.startswith(("mongodb://", "mongodb+srv://")):
        mongo_uri = f"mongodb://{mongo_uri}"
    else:
        parsed = urlparse(mongo_uri)
        if parsed.hostname == "mongodb":
            host = "localhost"
            if parsed.port:
                host = f"{host}:{parsed.port}"
            auth = f"{parsed.username}:{parsed.password}@" if parsed.username else ""
            mongo_uri = f"{parsed.scheme}://{auth}{host}{parsed.path or '/'}"
    return mongo_uri


def load_collection_names() -> list[str]:
    collections_file = EXPORT_DIR / "collections.txt"
    if not collections_file.exists():
        raise FileNotFoundError(
            f"Missing collection manifest: {collections_file}. "
            "Run tools/scripts/export_vps_mongo.sh again or restore the export directory."
        )
    return [
        line.strip()
        for line in collections_file.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]


def load_documents(collection_name: str) -> list[dict]:
    export_path = EXPORT_DIR / f"{collection_name}.json"
    if not export_path.exists():
        raise FileNotFoundError(f"Missing export file for collection '{collection_name}': {export_path}")
    payload = export_path.read_text(encoding="utf-8")
    documents = json_util.loads(payload)
    if not isinstance(documents, list):
        raise ValueError(f"Expected a JSON array in {export_path}")
    return documents


def upgrade() -> None:
    client = MongoClient(resolve_mongo_uri(), serverSelectionTimeoutMS=5000)
    db = client[os.getenv("MONGO_DB_NAME", "survey_db")]

    for collection_name in load_collection_names():
        documents = load_documents(collection_name)
        collection = db[collection_name]

        for document in documents:
            if "_id" not in document:
                collection.insert_one(document)
                continue
            collection.replace_one({"_id": document["_id"]}, document, upsert=True)

        print(f"Upserted {len(documents)} documents into '{collection_name}'.")

    client.close()


if __name__ == "__main__":
    upgrade()
EOF
fi

echo
echo "Snapshot complete."
echo "Archive: $LOCAL_SNAPSHOT_DIR/$ARCHIVE_NAME"
echo "Exports: $LOCAL_EXPORTS_DIR"

if [[ -n "$MIGRATION_FILE" ]]; then
  echo "Migration scaffold: $MIGRATION_FILE"
fi

echo "Keep the export directory out of git. It is intended for controlled ops use only."
