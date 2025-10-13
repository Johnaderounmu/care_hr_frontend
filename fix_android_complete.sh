#!/bin/bash

# Care HR Frontend - Complete Android Fix Script
echo "🔧 Care HR Frontend - Complete Android Fix Script"
echo "================================================="

# Set Java 17 environment
export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

echo "✅ Java Environment:"
echo "   JAVA_HOME: $JAVA_HOME"
java -version

cd /Users/johnaderounmu/Git/care_hr_frontend

echo ""
echo "🧹 Cleaning Flutter project..."
flutter clean

echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "🔨 Generating code (Hive adapters, etc.)..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo ""
echo "🏗️ Building Android debug APK..."
JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home flutter build apk --debug

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS! Android build completed successfully!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-debug.apk"
    
    echo ""
    echo "📋 Available devices:"
    flutter devices
    
    echo ""
    echo "🚀 To run on a device:"
    echo "   flutter run                    # Run on default device"
    echo "   flutter run -d android        # Run on Android"
    echo "   flutter run -d ios           # Run on iOS"
else
    echo ""
    echo "❌ Build failed. Check the error messages above."
    exit 1
fi