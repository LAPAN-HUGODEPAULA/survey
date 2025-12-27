#!/usr/bin/env bash
set -e

echo "Running Backend Tests..."
cd backend
# Install test dependencies if needed (assuming they are in requirements.txt or installed manually)
# pip install pytest pytest-cov httpx

# Run pytest with coverage
pytest --cov=. --cov-report=term-missing
