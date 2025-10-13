#!/bin/bash

# Care HR App Test Runner
# This script runs all tests: unit, widget, and integration tests

echo "🧪 Starting Care HR App Test Suite..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results tracking
UNIT_TESTS_PASSED=false
WIDGET_TESTS_PASSED=false
INTEGRATION_TESTS_PASSED=false

# Function to print section headers
print_section() {
    echo ""
    echo -e "${BLUE}=================================="
    echo -e "$1"
    echo -e "==================================${NC}"
}

# Function to print success message
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print warning message
print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Ensure we're in the project directory
cd "$(dirname "$0")"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_success "Flutter detected: $(flutter --version | head -n 1)"

# Get dependencies
print_section "📦 Getting Dependencies"
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Dependencies updated successfully"
else
    print_error "Failed to get dependencies"
    exit 1
fi

# Run code generation if needed
print_section "🔧 Running Code Generation"
if [ -d "lib" ] && grep -r "@HiveType\|@HiveField\|@JsonSerializable" lib/ >/dev/null 2>&1; then
    print_warning "Running build_runner for code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    if [ $? -eq 0 ]; then
        print_success "Code generation completed"
    else
        print_warning "Code generation had issues, but continuing..."
    fi
else
    print_success "No code generation needed"
fi

# Run unit tests
print_section "🔬 Running Unit Tests"
if [ -d "test/unit" ]; then
    flutter test test/unit/ --coverage
    if [ $? -eq 0 ]; then
        print_success "Unit tests passed"
        UNIT_TESTS_PASSED=true
    else
        print_error "Unit tests failed"
    fi
else
    print_warning "No unit tests directory found"
fi

# Run widget tests
print_section "🎨 Running Widget Tests"
if [ -d "test/widget" ]; then
    flutter test test/widget/
    if [ $? -eq 0 ]; then
        print_success "Widget tests passed"
        WIDGET_TESTS_PASSED=true
    else
        print_error "Widget tests failed"
    fi
else
    print_warning "No widget tests directory found"
fi

# Run all other tests in test directory
print_section "📋 Running All Flutter Tests"
flutter test --coverage
if [ $? -eq 0 ]; then
    print_success "All Flutter tests passed"
else
    print_error "Some Flutter tests failed"
fi

# Run integration tests (if available and device/emulator is connected)
print_section "🚀 Running Integration Tests"
if [ -d "integration_test" ]; then
    # Check if a device is available
    DEVICES=$(flutter devices)
    if echo "$DEVICES" | grep -q "No devices"; then
        print_warning "No devices available for integration tests"
        print_warning "Please connect a device or start an emulator to run integration tests"
    else
        print_success "Device found, running integration tests..."
        flutter test integration_test/
        if [ $? -eq 0 ]; then
            print_success "Integration tests passed"
            INTEGRATION_TESTS_PASSED=true
        else
            print_error "Integration tests failed"
        fi
    fi
else
    print_warning "No integration tests directory found"
fi

# Run static analysis
print_section "🔍 Running Static Analysis"
flutter analyze
if [ $? -eq 0 ]; then
    print_success "Static analysis passed"
else
    print_warning "Static analysis found issues"
fi

# Check code formatting
print_section "✨ Checking Code Formatting"
flutter format --set-exit-if-changed --dry-run .
if [ $? -eq 0 ]; then
    print_success "Code formatting is correct"
else
    print_warning "Code formatting issues found. Run 'flutter format .' to fix."
fi

# Generate coverage report if lcov is available
print_section "📊 Generating Coverage Report"
if [ -f "coverage/lcov.info" ] && command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    print_success "Coverage report generated in coverage/html/index.html"
elif [ -f "coverage/lcov.info" ]; then
    print_warning "Coverage data available but genhtml not installed"
    print_warning "Install lcov to generate HTML coverage reports"
else
    print_warning "No coverage data available"
fi

# Security check (if available)
print_section "🔒 Security Analysis"
if command -v flutter_security_analyzer &> /dev/null; then
    flutter_security_analyzer
    if [ $? -eq 0 ]; then
        print_success "Security analysis passed"
    else
        print_warning "Security issues found"
    fi
else
    print_warning "flutter_security_analyzer not available"
fi

# Summary
print_section "📈 Test Summary"
echo ""
echo "Test Results:"
echo "============"

if [ "$UNIT_TESTS_PASSED" = true ]; then
    print_success "Unit Tests: PASSED"
else
    print_error "Unit Tests: FAILED"
fi

if [ "$WIDGET_TESTS_PASSED" = true ]; then
    print_success "Widget Tests: PASSED"
else
    print_error "Widget Tests: FAILED"
fi

if [ "$INTEGRATION_TESTS_PASSED" = true ]; then
    print_success "Integration Tests: PASSED"
else
    print_warning "Integration Tests: SKIPPED OR FAILED"
fi

echo ""
echo "Next Steps:"
echo "==========="
echo "1. Review any failed tests and fix issues"
echo "2. Check coverage report for areas needing more tests"
echo "3. Run 'flutter format .' to fix formatting issues"
echo "4. Connect a device/emulator and run integration tests"
echo "5. Consider adding more test cases for critical functionality"

echo ""
print_success "Test suite completed!"
echo ""

# Exit with error code if any critical tests failed
if [ "$UNIT_TESTS_PASSED" = false ] || [ "$WIDGET_TESTS_PASSED" = false ]; then
    exit 1
else
    exit 0
fi