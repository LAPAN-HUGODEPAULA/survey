#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

ALLOWED_APP="services/survey-backend/app/persistence"
ALLOWED_TOOLS="tools"

VIOLATIONS=$(rg --files-with-matches "from pymongo|import pymongo" services/survey-backend tools 2>/dev/null \
  | grep -v "^${ALLOWED_APP}" \
  | grep -v "^${ALLOWED_TOOLS}" || true)

if [[ -n "${VIOLATIONS}" ]]; then
  echo "pymongo import outside allowed directories (${ALLOWED_APP}, ${ALLOWED_TOOLS}):"
  echo "${VIOLATIONS}"
  exit 1
fi

echo "pymongo usage limited to ${ALLOWED_APP} and ${ALLOWED_TOOLS}"
