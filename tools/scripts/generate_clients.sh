#!/usr/bin/env bash
# Regenerate API clients from OpenAPI specs using the official openapi-generator CLI (Docker).
# Requires Docker available locally.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTRACTS_DIR="${ROOT_DIR}/packages/contracts"
SPEC="${CONTRACTS_DIR}/survey-backend.openapi.yaml"
OUT_DIR="${CONTRACTS_DIR}/generated/dart"

echo "Generating Dart client from ${SPEC}"
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

docker run --rm \
  -v "${ROOT_DIR}:${ROOT_DIR}" \
  -w "${ROOT_DIR}" \
  openapitools/openapi-generator-cli:v7.9.0 generate \
  -i "${SPEC}" \
  -g dart-dio \
  -o "${OUT_DIR}" \
  --additional-properties=pubName=survey_backend_api,nullableFields=true

cd "${OUT_DIR}"
dart pub run build_runner build --delete-conflicting-outputs

echo "Done. Generated client at ${OUT_DIR}"
