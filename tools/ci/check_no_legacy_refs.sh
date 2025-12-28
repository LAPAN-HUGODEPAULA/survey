#!/usr/bin/env bash
set -euo pipefail

# Guard to ensure runtime code does not reference any _legacy paths.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PATHS=(
  "$ROOT/services"
  "$ROOT/apps"
  "$ROOT/packages"
  "$ROOT/tools/scripts"
)

exit_code=0

for dir in "${PATHS[@]}"; do
  [[ -d "$dir" ]] || continue
  matches="$(
    find "$dir" \
      -path "*/.venv/*" -prune -o \
      -path "*/_legacy/*" -prune -o \
      -path "*/docs/*" -prune -o \
      -type f -print0 |
      xargs -0 -r rg -F "_legacy" --no-heading || true
  )"

  if [[ -n "$matches" ]]; then
    echo "Legacy reference found under ${dir#"$ROOT/"}; please remove imports or paths to _legacy."
    echo "$matches"
    exit_code=1
  fi
done

exit "$exit_code"
