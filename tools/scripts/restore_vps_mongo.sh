#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REMOTE_HOST="${SURVEY_VPS_HOST:-root@72.61.60.27}"
REMOTE_DIR="${SURVEY_VPS_DIR:-/root/survey}"
REMOTE_CONTAINER="${SURVEY_MONGO_CONTAINER:-mongodb}"
REMOTE_TMP_BASE="${SURVEY_MONGO_REMOTE_TMP:-/tmp}"
OUTPUT_ROOT="${SURVEY_MONGO_EXPORT_ROOT:-$ROOT_DIR/tools/migrations/survey-backend/exports}"
RSYNC_SSH="sshpass -e ssh"
KEEP_REMOTE=0
FULL_RESTORE=0
COLLECTIONS_CSV=""
SNAPSHOT=""

usage() {
  cat <<'EOF'
Usage: ./tools/scripts/restore_vps_mongo.sh [options]

Push a previously exported snapshot back to the VPS Mongo container.

Options:
  --snapshot NAME          Snapshot directory name under tools/migrations/survey-backend/exports.
                           Defaults to the most recent directory.
  --collections a,b,c      Restrict the JSON imports to the listed collections.
  --full-restore           Restore the mongodump archive with mongorestore (drops db).
  --output-root PATH       Local export root (mirror of export script).
  --remote-host HOST       VPS SSH host.
  --remote-dir PATH        VPS project root.
  --remote-container NAME  MongoDB container name.
  --keep-remote           Keep the temporary release directory on the VPS.
  -h, --help               Show this help text.

Notes:
  * The default behavior only upserts the exported JSON collections to avoid data loss.
  * The snapshots live under tools/migrations/survey-backend/exports/<timestamp>/.
EOF
}

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "Missing required command: $name" >&2
    exit 1
  fi
}

latest_snapshot() {
  find "$OUTPUT_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tail -n 1
}

parse_snapshot_args() {
  if [[ -n "$SNAPSHOT" ]]; then
    SNAPSHOT_DIR="$OUTPUT_ROOT/$SNAPSHOT"
  else
    SNAPSHOT_DIR="$OUTPUT_ROOT/$(latest_snapshot)"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --snapshot)
      SNAPSHOT="${2:-}"
      shift 2
      ;;
    --collections)
      COLLECTIONS_CSV="${2:-}"
      shift 2
      ;;
    --full-restore)
      FULL_RESTORE=1
      shift
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

parse_snapshot_args

if [[ ! -d "$SNAPSHOT_DIR" ]]; then
  echo "Snapshot directory not found: $SNAPSHOT_DIR" >&2
  exit 1
fi

ARCHIVE_FILE="$(find "$SNAPSHOT_DIR" -maxdepth 1 -name 'mongo_dump_*.archive.gz' | head -n 1)"
if [[ -z "$ARCHIVE_FILE" ]]; then
  echo "mongodump archive missing in snapshot: $SNAPSHOT_DIR" >&2
  exit 1
fi

EXPORTS_DIR="$SNAPSHOT_DIR/exports"
if [[ ! -d "$EXPORTS_DIR" ]]; then
  echo "Exports directory missing in snapshot: $EXPORTS_DIR" >&2
  exit 1
fi

TIMESTAMP="$(basename "$SNAPSHOT_DIR")"
REMOTE_SNAPSHOT_DIR="$REMOTE_TMP_BASE/survey-mongo-restore-$TIMESTAMP"
ARCHIVE_NAME="$(basename "$ARCHIVE_FILE")"

echo "Restoring snapshot $TIMESTAMP to $REMOTE_HOST:$REMOTE_CONTAINER"
echo "Snapshot location: $SNAPSHOT_DIR"

mkdir -p "$OUTPUT_ROOT" # ensure root exists

rsync -vrupthlgo -e "$RSYNC_SSH" "$SNAPSHOT_DIR/" "$REMOTE_HOST:$REMOTE_SNAPSHOT_DIR/"

sshpass -e ssh "$REMOTE_HOST" "bash -s" -- \
  "$REMOTE_DIR" \
  "$REMOTE_SNAPSHOT_DIR" \
  "$ARCHIVE_NAME" \
  "$COLLECTIONS_CSV" \
  "$FULL_RESTORE" \
  "$REMOTE_CONTAINER" <<'REMOTE_SCRIPT'
set -euo pipefail

REMOTE_DIR="$1"
REMOTE_SNAPSHOT_DIR="$2"
ARCHIVE_NAME="$3"
COLLECTIONS_CSV="$4"
FULL_RESTORE="$5"
REMOTE_CONTAINER="$6"

cd "$REMOTE_DIR"

set -a
. config/runtime/generated/private/survey-backend.env
. config/runtime/generated/private/mongodb.env
set +a

EXPORTS_DIR="$REMOTE_SNAPSHOT_DIR/exports"

if [[ "$FULL_RESTORE" -eq 1 ]]; then
  docker exec "$REMOTE_CONTAINER" sh -lc "
    mongorestore \
      --host localhost \
      --port 27017 \
      --username \"\$MONGO_INITDB_ROOT_USERNAME\" \
      --password \"\$MONGO_INITDB_ROOT_PASSWORD\" \
      --authenticationDatabase admin \
      --archive \"$REMOTE_SNAPSHOT_DIR/$ARCHIVE_NAME\" \
      --gzip \
      --db \"$MONGO_DB_NAME\" \
      --drop
  "
fi

if [[ -n "$COLLECTIONS_CSV" ]]; then
  IFS=',' read -r -a COLLECTIONS <<< "$COLLECTIONS_CSV"
else
  mapfile -t COLLECTIONS < "$EXPORTS_DIR/collections.txt"
fi

if [[ "${#COLLECTIONS[@]}" -eq 0 ]]; then
  echo "No collections to import." >&2
  exit 1
fi

for raw_collection in "${COLLECTIONS[@]}"; do
  collection="$(printf '%s' "$raw_collection" | xargs)"
  if [[ -z "$collection" ]]; then
    continue
  fi

  export_file="$EXPORTS_DIR/$collection.json"
  if [[ ! -f "$export_file" ]]; then
    echo "Missing export file for '$collection': $export_file" >&2
    exit 1
  fi

  docker cp "$export_file" "$REMOTE_CONTAINER":/tmp/"$collection".json
  docker exec "$REMOTE_CONTAINER" sh -lc "
    mongoimport \
      --host localhost \
      --port 27017 \
      --username \"\$MONGO_INITDB_ROOT_USERNAME\" \
      --password \"\$MONGO_INITDB_ROOT_PASSWORD\" \
      --authenticationDatabase admin \
      --db \"$MONGO_DB_NAME\" \
      --collection \"$collection\" \
      --mode=upsert \
      --jsonArray \
      --file /tmp/$collection.json
    rm -f /tmp/$collection.json
  "
done
REMOTE_SCRIPT

if [[ "$KEEP_REMOTE" -eq 0 ]]; then
  sshpass -e ssh "$REMOTE_HOST" "rm -rf '$REMOTE_SNAPSHOT_DIR'"
fi

echo "Restore complete."
