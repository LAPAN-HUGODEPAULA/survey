#!/bin/bash

# Set trap to kill all background jobs on exit
trap 'kill $(jobs -p)' EXIT

# Function to launch a command in a new terminal window
# This is a placeholder, as the behavior can be OS-dependent.
# For now, we will run them as background jobs in the same terminal.
# To use separate terminals, you can use something like:
# gnome-terminal -- bash -c "..." or xterm -e "..."

# Launch Backend
echo "Starting survey-backend..."
(
  cd services/survey-backend
  source .venv/bin/activate
  uvicorn app.main:app --reload
) &

# Launch Frontend Applications
# echo "Starting survey-frontend..."
# (
#   cd apps/survey-frontend
#   flutter run -d chrome --web-port 8181 --dart-define=API_BASE_URL=http://localhost:8000/api/v1/
# ) &
# ) &

# Uncomment the following blocks to launch other frontend apps

# echo "Starting survey-patient..."
# (
#   cd apps/survey-patient
#   flutter run -d chrome --web-port 8182 --dart-define=API_BASE_URL=http://localhost:8000/api/v1/
# ) &

# echo "Starting clinical-narrative..."
# (
#   cd apps/clinical-narrative
#   flutter run -d chrome --web-port 8183 --dart-define=API_BASE_URL=http://localhost:8000/api/v1/
# ) &

echo "Starting survey-builder..."
(
  cd apps/survey-builder
  flutter run -d chrome --web-port 8184 --dart-define=API_BASE_URL=http://localhost:8000/api/v1/
) &


wait
