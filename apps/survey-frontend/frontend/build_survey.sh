#!/usr/bin/env bash
# build_survey.sh – build the Flutter survey web bundle for the chosen target
# usage: ./build_survey.sh <dockerVps|firebase>

set -euo pipefail

# ---- 1. sanity check --------------------------------------------------------
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <dockerVps|firebase>"
  exit 1
fi

FLAVOR="$1"
case "$FLAVOR" in
  dockerVps|firebase ) ;;
  * )
    echo "Error: unknown flavor '$FLAVOR'. Allowed: dockerVps  firebase"
    exit 1
esac

# ---- 2. optional: clean previous build -------------------------------------
# echo "Cleaning previous build outputs…"
# flutter clean

# ---- 3. get dependencies -----------------------------------------------------
# echo "Getting dependencies…"
# flutter pub get

# ---- 4. build ----------------------------------------------------------------
echo "Building Flutter web for flavor: $FLAVOR"
flutter build web --dart-define=FLAVOR="$FLAVOR"

# ---- 5. tell the caller where the bundle is ---------------------------------
OUTPUT_DIR="build/web"
echo "Build complete. Bundle ready in: $OUTPUT_DIR"
