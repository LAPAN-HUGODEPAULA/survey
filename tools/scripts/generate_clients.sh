#!/usr/bin/env bash
# Regenerate API clients from OpenAPI specs.
# Requires openapi-generator-cli (https://openapi-generator.tech/docs/installation).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTRACTS_DIR="${ROOT_DIR}/packages/contracts"
SPEC="${CONTRACTS_DIR}/survey-backend.openapi.yaml"
OUT_DIR="${CONTRACTS_DIR}/generated/dart"

echo "Generating Dart client from ${SPEC}"
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

openapi-generator-cli generate \
  -i "${SPEC}" \
  -g dart-dio-next \
  -o "${OUT_DIR}" \
  --additional-properties=pubName=survey_backend_api,nullableFields=true

echo "Done. Generated client at ${OUT_DIR}"
