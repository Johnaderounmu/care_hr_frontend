#!/bin/bash

echo "🚀 Starting Complete Care HR System Setup & Test"
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Frontend directory
FRONTEND_DIR="/Users/johnaderounmu/Git/care_hr_frontend"
BACKEND_DIR="/Users/johnaderounmu/Git/care_hr_backend"

echo -e "${BLUE}Step 1: Backend Setup${NC}"
echo "====================="

cd "$BACKEND_DIR"
echo "Installing backend dependencies..."
npm install

echo "Starting backend server in background..."
npm start &
BACKEND_PID=$!
echo "Backend PID: $BACKEND_PID"

# Wait for backend to start
echo "Waiting for backend to initialize..."
sleep 5

echo -e "${BLUE}Step 2: Flutter Frontend Setup${NC}"
echo "==============================="

cd "$FRONTEND_DIR"

echo "Cleaning Flutter project..."
flutter clean

echo "Getting Flutter dependencies..."
flutter pub get

echo "Generating code (Hive adapters, etc.)..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo -e "${BLUE}Step 3: Flutter Doctor Check${NC}"
echo "============================="
flutter doctor

echo -e "${BLUE}Step 4: Available Devices${NC}"
echo "=========================="
flutter devices

echo -e "${BLUE}Step 5: Android Build Test${NC}"
echo "=========================="
echo "Testing Android debug build..."
flutter build apk --debug

echo -e "${BLUE}Step 6: iOS Build Test${NC}"
echo "======================"
echo "Testing iOS debug build..."
flutter build ios --debug --no-codesign

echo -e "${BLUE}Step 7: Backend Health Check${NC}"
echo "============================"
echo "Testing backend connectivity..."
curl -f http://localhost:4000/health || echo "Backend health check failed"

echo -e "${GREEN}Setup Complete!${NC}"
echo "==============="
echo "Backend PID: $BACKEND_PID"
echo "To stop backend: kill $BACKEND_PID"
echo ""
echo "Available commands:"
echo "- flutter run -d ios                    # Run on iOS"
echo "- flutter run -d android                # Run on Android"
echo "- flutter run -d 'iPhone 17'            # Run on specific iOS device"
echo ""
echo "🎉 System is ready for development!"

# Keep script running to maintain background processes
echo "Press Ctrl+C to stop all services..."
wait