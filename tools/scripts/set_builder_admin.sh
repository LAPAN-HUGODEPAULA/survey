#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  tools/scripts/set_builder_admin.sh (--email <email> | --id <screener_id>) (--enable | --disable)

Examples:
  tools/scripts/set_builder_admin.sh --email admin@example.com --enable
  tools/scripts/set_builder_admin.sh --id 60c728efd4c4a4f8b8c8d0d0 --disable
EOF
}

identifier=""
mode=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --email|--id)
      if [[ $# -lt 2 ]]; then
        usage
        exit 1
      fi
      identifier="$2"
      shift 2
      ;;
    --enable)
      mode="enable"
      shift
      ;;
    --disable)
      mode="disable"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$identifier" || -z "$mode" ]]; then
  usage
  exit 1
fi

enabled="false"
if [[ "$mode" == "enable" ]]; then
  enabled="true"
fi

cd "$ROOT_DIR"

PYTHONPATH="${ROOT_DIR}/services/survey-backend" uv run python - "$identifier" "$enabled" <<'PY'
import sys

from app.persistence.mongo.client import get_db
from app.persistence.repositories.screener_repo import ScreenerRepository


def main() -> int:
    identifier = sys.argv[1]
    enabled = sys.argv[2].lower() == "true"
    repo = ScreenerRepository(get_db())
    updated = repo.set_builder_admin(identifier, enabled)
    if updated is None:
        print(f"Screener not found for identifier: {identifier}", file=sys.stderr)
        return 1

    state = "enabled" if updated.isBuilderAdmin else "disabled"
    print(
        "builder_admin="
        f"{state} id={updated.id} email={updated.email} "
        f"name={updated.firstName} {updated.surname}"
    )
    return 0


raise SystemExit(main())
PY
