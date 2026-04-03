#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/docs/legal"
TARGET_DIR="${ROOT_DIR}/packages/design_system_flutter/assets/legal"
MODE="${1:-sync}"

check_file_sync() {
  local source_file="$1"
  local target_file="$2"

  if ! cmp -s "${source_file}" "${target_file}"; then
    echo "Legal asset drift detected:"
    echo "  source: ${source_file}"
    echo "  target: ${target_file}"
    return 1
  fi
}

mkdir -p "${TARGET_DIR}"

NOTICE_SOURCE="${SOURCE_DIR}/Aviso-Inicial-de-Uso-ptbr.md"
NOTICE_TARGET="${TARGET_DIR}/Aviso-Inicial-de-Uso-ptbr.md"
TERMS_SOURCE="${SOURCE_DIR}/Termo-de-Uso-e-Política-de-Privacidade-ptbr.md"
TERMS_TARGET="${TARGET_DIR}/Termo-de-Uso-e-Política-de-Privacidade-ptbr.md"

case "${MODE}" in
  sync)
    cp "${NOTICE_SOURCE}" "${NOTICE_TARGET}"
    cp "${TERMS_SOURCE}" "${TERMS_TARGET}"
    echo "Synced legal markdown assets to ${TARGET_DIR}"
    ;;
  --check)
    check_file_sync "${NOTICE_SOURCE}" "${NOTICE_TARGET}"
    check_file_sync "${TERMS_SOURCE}" "${TERMS_TARGET}"
    echo "Legal markdown assets are in sync."
    ;;
  *)
    echo "Usage: $0 [sync|--check]" >&2
    exit 1
    ;;
esac
