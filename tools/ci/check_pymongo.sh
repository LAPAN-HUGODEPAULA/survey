#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

ALLOWED_DIR="services/survey-backend/app/persistence"
VIOLATIONS=$(rg --files-with-matches "from pymongo|import pymongo" services/survey-backend 2>/dev/null \
  | grep -v "^${ALLOWED_DIR}" \
  | grep -v "services/survey-backend/_legacy" || true)

if [[ -n "${VIOLATIONS}" ]]; then
  echo "pymongo import outside ${ALLOWED_DIR}:"
  echo "${VIOLATIONS}"
  exit 1
fi

echo "pymongo usage limited to ${ALLOWED_DIR}"
