#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-full-build}"
REMOTE_HOST="root@72.61.60.27"
REMOTE_DIR="/root/survey"
RSYNC_SSH="sshpass -e ssh"

usage() {
  cat <<'EOF'
Usage: ./tools/scripts/deploy_vps.sh [mode]

Modes:
  config-only   Render runtime config and recreate config-sensitive services only
  frontend-only Rebuild and restart survey-frontend only
  patient-only  Rebuild and restart survey-patient only
  builder-only  Rebuild and restart survey-builder only
  narrative-only Rebuild and restart clinical-narrative only
  backend-only  Rebuild and restart survey-backend and survey-worker
  full-build    Rebuild and restart the full stack
EOF
}

case "$MODE" in
  help|-h|--help)
    usage
    exit 0
    ;;
  config-only)
    REMOTE_DEPLOY_CMD="python3 tools/scripts/render_runtime_config.py && docker compose up -d --no-build --force-recreate traefik mongodb survey-backend survey-worker"
    ;;
  frontend-only)
    REMOTE_DEPLOY_CMD="python3 tools/scripts/render_runtime_config.py && docker compose --parallel 1 build survey-frontend && docker compose up -d --no-deps survey-frontend"
    ;;
  patient-only)
    REMOTE_DEPLOY_CMD="python3 tools/scripts/render_runtime_config.py && docker compose --parallel 1 build survey-patient && docker compose up -d --no-deps survey-patient"
    ;;
  builder-only)
    REMOTE_DEPLOY_CMD="python3 tools/scripts/render_runtime_config.py && docker compose --parallel 1 build survey-builder && docker compose up -d --no-deps survey-builder"
    ;;
  narrative-only)
    REMOTE_DEPLOY_CMD="python3 tools/scripts/render_runtime_config.py && docker compose --parallel 1 build clinical-narrative && docker compose up -d --no-deps clinical-narrative"
    ;;
  backend-only)
    REMOTE_DEPLOY_CMD="python3 tools/scripts/render_runtime_config.py && docker compose --parallel 1 build survey-backend survey-worker && docker compose up -d survey-backend survey-worker"
    ;;
  full-build)
    REMOTE_DEPLOY_CMD="python3 tools/scripts/render_runtime_config.py && docker compose --parallel 1 up -d --build"
    ;;
  *)
    usage
    exit 1
    ;;
esac

rsync -vrupthlgo --delete --no-whole-file --bwlimit=150 \
  --exclude='venv/' \
  --exclude='.venv/' \
  --exclude='android/' \
  --exclude='build/' \
  --exclude='__pycache__' \
  -e "$RSYNC_SSH" \
  /home/hugo/Documents/LAPAN/dev/survey/* \
  "$REMOTE_HOST:$REMOTE_DIR/"

rsync -vrupthlgo \
  -e "$RSYNC_SSH" \
  /home/hugo/Documents/LAPAN/dev/survey/config/runtime/config.private.json \
  "$REMOTE_HOST:$REMOTE_DIR/config/runtime/config.private.json"

sshpass -e ssh "$REMOTE_HOST" \
  "cp $REMOTE_DIR/docker-compose.vps.yml $REMOTE_DIR/docker-compose.yml && cd $REMOTE_DIR && $REMOTE_DEPLOY_CMD"
