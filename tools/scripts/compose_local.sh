#!/usr/bin/env bash
set -euo pipefail

# Keep local Compose operations serial to avoid saturating the machine.
exec docker compose --parallel 1 "$@"
