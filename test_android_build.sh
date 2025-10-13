#!/bin/bash
cd /Users/johnaderounmu/Git/care_hr_frontend

echo "Cleaning Flutter project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Checking Flutter doctor..."
flutter doctor

echo "Trying to build Android debug APK..."
flutter build apk --debug --verbose

echo "Build test completed."