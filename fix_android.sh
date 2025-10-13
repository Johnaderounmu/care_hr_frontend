#!/bin/bash

echo "🔧 Android Configuration Fix & Test"
echo "==================================="

cd /Users/johnaderounmu/Git/care_hr_frontend

# Clean everything first
echo "1. Cleaning project..."
flutter clean
rm -rf build/
rm -rf android/.gradle/
rm -rf android/app/build/

# Get dependencies
echo "2. Getting dependencies..."
flutter pub get

# Generate required files
echo "3. Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Test Android build
echo "4. Testing Android debug build..."
flutter build apk --debug --verbose

if [ $? -eq 0 ]; then
    echo "✅ Android build successful!"
    echo "5. Testing app installation..."
    flutter install --debug
else
    echo "❌ Android build failed. Checking configuration..."
fi

echo "Build test completed."