#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APPS=("survey-frontend" "survey-patient" "survey-builder" "clinical-narrative")

echo "Starting host-side Flutter builds..."

for app in "${APPS[@]}"; do
  echo "------------------------------------------------"
  echo "Building $app..."
  cd "${ROOT_DIR}/apps/$app"
  
  # Ensure dependencies are up to date
  flutter pub get
  
  # Build web
  flutter build web --release --dart-define=FLAVOR="dockerVps" --dart-define=API_BASE_URL="/api/v1"
  
  # Strip source maps to reduce size
  sed -i '/sourceMappingURL=flutter.js.map/d' build/web/flutter.js build/web/flutter_bootstrap.js 2>/dev/null || true
  
  echo "$app build complete."
done

echo "------------------------------------------------"
echo "All frontends built successfully."
