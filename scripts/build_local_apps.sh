#!/usr/bin/env bash
set -e

echo "Building frontend app with dockerVps flavor..."
./frontend/build_survey.sh dockerVps

echo "Building patient_app app with dockerVps flavor..."
./patient_app/build_survey.sh dockerVps

echo "Done."
