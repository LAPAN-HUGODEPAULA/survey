#!/bin/bash
set -e

echo "===================================================="
echo "LAPAN SURVEY PLATFORM - TEST COVERAGE SUITE"
echo "===================================================="

# 1. Backend Service
echo "Running Survey Backend Tests..."
cd services/survey-backend
uv run pytest
cd ../..

# 2. Clinical Writer AI Service
echo "Running Clinical Writer AI Tests..."
cd services/clinical-writer-api/clinical_writer_agent
uv run pytest
cd ../../..

# 3. Flutter Apps
for app in apps/survey-patient apps/survey-frontend apps/survey-builder apps/clinical-narrative; do
    echo "Running Tests for $app..."
    cd $app
    flutter test --coverage
    
    # Simple coverage check using lcov (if available)
    if command -v lcov &> /dev/null; then
        COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines......" | cut -d ' ' -f 4 | cut -d '%' -f 1)
        echo "Coverage: $COVERAGE%"
        if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "ERROR: Coverage for $app is below 80% ($COVERAGE%)"
            exit 1
        fi
        genhtml coverage/lcov.info -o coverage/html
    fi
    cd ../..
done

# 4. Flutter Packages
for pkg in packages/design_system_flutter packages/runtime_app_config packages/runtime_api_url; do
    echo "Running Tests for $pkg..."
    cd $pkg
    flutter test --coverage
    cd ../..
done

echo "===================================================="
echo "All tests completed!"
echo "===================================================="
