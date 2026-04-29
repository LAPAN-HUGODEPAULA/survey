#!/bin/bash

cmds=(
  "./tools/scripts/compose_local.sh build survey-backend clinical-writer-api"
  "./tools/scripts/compose_local.sh build --no-cache survey-frontend"
  "./tools/scripts/deploy_vps.sh backend-only"
  "./tools/scripts/compose_local.sh build --no-cache survey-builder"
  "./tools/scripts/deploy_vps.sh frontend-only"
  "./tools/scripts/compose_local.sh build --no-cache clinical-narrative"
  "./tools/scripts/deploy_vps.sh builder-only"
  "./tools/scripts/compose_local.sh build --no-cache survey-patient"
  "./tools/scripts/deploy_vps.sh narrative-only"
  "./tools/scripts/compose_local.sh up -d"
  "./tools/scripts/deploy_vps.sh patient-only"
)

for i in "${!cmds[@]}"; do
  echo "${cmds[$i]}" | at now + $((i*10)) minutes
done

