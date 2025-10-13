#!/bin/bash
# Script to run Flutter with Java 17 to avoid Android Gradle Plugin compatibility issues

export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

echo "🔧 Setting JAVA_HOME to Java 17: $JAVA_HOME"
echo "☕ Java version: $($JAVA_HOME/bin/java -version 2>&1 | head -n 1)"
echo "🚀 Running Flutter with Java 17..."
echo "💡 Tip: Run 'export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home' to set Java 17 permanently in your shell"

# Run flutter with any arguments passed to this script
flutter "$@"