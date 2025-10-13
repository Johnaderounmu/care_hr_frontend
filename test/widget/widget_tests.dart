import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_hr_app/core/widgets/advanced_file_upload_widget.dart';
import 'package:care_hr_app/core/animations/custom_animations.dart';
import 'package:care_hr_app/core/services/navigation_service.dart';

void main() {
  group('Advanced File Upload Widget Tests', () {
    testWidgets('should display upload area with correct title', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Upload Widget';
      const testSubtitle = 'Select files for testing';
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AdvancedFileUploadWidget(
            title: testTitle,
            subtitle: testSubtitle,
            onFilesSelected: (files) {},
          ),
        ),
      ));

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
    });

    testWidgets('should show selection buttons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AdvancedFileUploadWidget(
            onFilesSelected: (files) {},
          ),
        ),
      ));

      // Assert
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.description), findsOneWidget);
    });

    testWidgets('should display file constraints', (WidgetTester tester) async {
      // Arrange
      const maxFileSize = 5;
      const maxFiles = 3;
      const allowedExtensions = ['pdf', 'jpg'];
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AdvancedFileUploadWidget(
            maxFileSize: maxFileSize,
            maxFiles: maxFiles,
            allowedExtensions: allowedExtensions,
            onFilesSelected: (files) {},
          ),
        ),
      ));

      // Assert
      expect(find.textContaining('PDF, JPG'), findsOneWidget);
      expect(find.textContaining('${maxFileSize}MB'), findsOneWidget);
      expect(find.textContaining('$maxFiles'), findsOneWidget);
    });
  });

  group('Animation Widget Tests', () {
    testWidgets('AnimatedCard should render child correctly', (WidgetTester tester) async {
      // Arrange
      const testText = 'Animated Content';
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedCard(
            child: Text(testText),
          ),
        ),
      ));

      // Wait for animation to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('PulseAnimation should render and animate', (WidgetTester tester) async {
      // Arrange
      const testText = 'Pulsing Widget';
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PulseAnimation(
            child: Text(testText),
          ),
        ),
      ));

      // Wait for animation frames
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.text(testText), findsOneWidget);
      
      // Verify the widget is still there after animation time
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('LoadingAnimation should display correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LoadingAnimation(
            size: 50,
            color: Colors.blue,
          ),
        ),
      ));

      // Wait for initial render
      await tester.pump();

      // Assert - Check that the widget renders without errors
      expect(tester.takeException(), isNull);
      
      // Verify animation continues
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  });

  group('Navigation Animation Tests', () {
    testWidgets('AnimatedButton should respond to tap', (WidgetTester tester) async {
      // Arrange
      bool buttonPressed = false;
      const buttonText = 'Test Button';
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            onPressed: () => buttonPressed = true,
            child: const Text(buttonText),
          ),
        ),
      ));

      // Find and tap the button
      await tester.tap(find.text(buttonText));
      await tester.pump();

      // Assert
      expect(buttonPressed, true);
    });

    testWidgets('AnimatedButton should be disabled when onPressed is null', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Disabled Button';
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            onPressed: null,
            child: const Text(buttonText),
          ),
        ),
      ));

      // Try to tap the disabled button
      await tester.tap(find.text(buttonText));
      await tester.pump();

      // Assert - Should not crash (no exception means test passes)
      expect(tester.takeException(), isNull);
    });
  });

  group('Typewriter Text Tests', () {
    testWidgets('TypewriterText should display text progressively', (WidgetTester tester) async {
      // Arrange
      const testText = 'Hello World!';
      bool completed = false;
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TypewriterText(
            text: testText,
            duration: const Duration(milliseconds: 10), // Fast for testing
            onComplete: () => completed = true,
          ),
        ),
      ));

      // Initial state
      await tester.pump();
      
      // Let some animation happen
      await tester.pump(const Duration(milliseconds: 50));
      
      // Should eventually show the full text
      await tester.pump(const Duration(milliseconds: 200));
      
      // Assert
      expect(find.textContaining('Hello'), findsOneWidget);
      
      // Wait for completion
      await tester.pumpAndSettle();
      expect(completed, true);
      expect(find.text(testText), findsOneWidget);
    });
  });

  group('Staggered Animation Tests', () {
    testWidgets('StaggeredListView should render children', (WidgetTester tester) async {
      // Arrange
      final children = [
        const Text('Item 1'),
        const Text('Item 2'),
        const Text('Item 3'),
      ];
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StaggeredListView(
            children: children,
          ),
        ),
      ));

      // Wait for initial render and animations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });

  group('File Upload Validation Tests', () {
    test('should validate file extensions correctly', () {
      const allowedExtensions = ['pdf', 'doc', 'jpg', 'png'];
      
      expect(_isValidExtension('document.pdf', allowedExtensions), true);
      expect(_isValidExtension('image.JPG', allowedExtensions), true); // Case insensitive
      expect(_isValidExtension('file.txt', allowedExtensions), false);
      expect(_isValidExtension('script.exe', allowedExtensions), false);
    });

    test('should validate file sizes correctly', () {
      const maxSizeMB = 10;
      
      expect(_isValidFileSize(5 * 1024 * 1024, maxSizeMB), true); // 5MB
      expect(_isValidFileSize(10 * 1024 * 1024, maxSizeMB), true); // 10MB exactly
      expect(_isValidFileSize(15 * 1024 * 1024, maxSizeMB), false); // 15MB
    });

    test('should format file sizes correctly', () {
      expect(_formatSize(512), '512 B');
      expect(_formatSize(1536), '1.5 KB');
      expect(_formatSize(2097152), '2.0 MB');
      expect(_formatSize(1073741824), '1.0 GB');
    });
  });
}

// Helper functions for testing
bool _isValidExtension(String fileName, List<String> allowedExtensions) {
  final extension = fileName.split('.').last.toLowerCase();
  return allowedExtensions.contains(extension);
}

bool _isValidFileSize(int bytes, int maxSizeMB) {
  return bytes <= maxSizeMB * 1024 * 1024;
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}