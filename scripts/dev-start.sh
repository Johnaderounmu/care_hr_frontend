#!/bin/bash

# Development startup script for Care HR system

echo "🚀 Starting Care HR Development Environment"

# Start backend in background
echo "📡 Starting backend server..."
cd /Users/johnaderounmu/Git/care_hr_backend
npm start &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 3

# Start Flutter app
echo "📱 Starting Flutter app..."
cd /Users/johnaderounmu/Git/care_hr_frontend
flutter run -d macos &
FLUTTER_PID=$!

echo "✅ Development environment started!"
echo "Backend PID: $BACKEND_PID"
echo "Flutter PID: $FLUTTER_PID"
echo ""
echo "📊 Access points:"
echo "- Backend API: http://localhost:4000"
echo "- GraphQL Playground: http://localhost:4000/graphql"
echo "- Flutter DevTools: (will be shown in Flutter terminal)"
echo ""
echo "To stop both services, run: kill $BACKEND_PID $FLUTTER_PID"

# Keep script running
wait