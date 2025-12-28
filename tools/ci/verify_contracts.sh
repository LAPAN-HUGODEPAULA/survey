#!/usr/bin/env bash
# Verify OpenAPI-generated clients are up to date.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

./tools/scripts/generate_clients.sh

if ! git diff --quiet -- packages/contracts/generated/dart; then
  echo "Generated Dart client is out of date. Please run tools/scripts/generate_clients.sh and commit the changes."
  exit 1
fi

echo "Contracts are up to date."
