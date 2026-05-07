#!/bin/bash
set -euo pipefail

# Ensure scripts are executable
chmod +x tools/scripts/*.sh

echo "===================================================="
echo "LAPAN SURVEY PLATFORM - OPTIMIZED DEPLOYMENT"
echo "===================================================="

echo "Step 1: Host-side Flutter builds (Sequential)"
./tools/scripts/build_all_frontends.sh

echo "Step 2: Local Docker stack build (Sequential)"
./tools/scripts/compose_local.sh --parallel 1 build  

echo "Step 3: Local Docker stack up"
./tools/scripts/compose_local.sh up -d

echo "Step 4: VPS Deployment (Sequential)"
./tools/scripts/deploy_vps.sh full-build

echo "===================================================="
echo "Deployment Complete!"
echo "===================================================="
