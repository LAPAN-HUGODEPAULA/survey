#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/docs/legal"
TARGET_DIR="${ROOT_DIR}/packages/design_system_flutter/assets/legal"

mkdir -p "${TARGET_DIR}"

cp "${SOURCE_DIR}/Aviso-Inicial-de-Uso-ptbr.md" "${TARGET_DIR}/"
cp "${SOURCE_DIR}/Termo-de-Uso-e-Política-de-Privacidade-ptbr.md" "${TARGET_DIR}/"

echo "Synced legal markdown assets to ${TARGET_DIR}"
