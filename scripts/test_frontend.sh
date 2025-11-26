#!/usr/bin/env bash
set -e

echo "Running Frontend Tests..."
cd frontend

# Run flutter test with coverage
flutter test --coverage

# Generate coverage report (requires lcov)
# genhtml coverage/lcov.info -o coverage/html
echo "Coverage report generated at frontend/coverage/lcov.info"
