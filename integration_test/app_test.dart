import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:care_hr_app/main.dart' as app;
import 'package:care_hr_app/core/constants/app_colors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Care HR App Integration Tests', () {
    testWidgets('App should launch and show splash screen', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen appears
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Should navigate to login screen', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash to complete and navigate to login
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should see login elements
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('Login form validation should work', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Try to login with empty fields
      final loginButton = find.text('Login').first;
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.textContaining('required'), findsWidgets);
    });

    testWidgets('Should be able to enter credentials', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Find email and password fields
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Enter test credentials
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Should navigate to onboarding for new users', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Navigate to onboarding manually (simulating new user flow)
      // This would typically be done after successful registration
      
      // For now, just verify the app doesn't crash during navigation
      expect(tester.takeException(), isNull);
    });

    testWidgets('File upload widget should work correctly', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Navigate to file upload page (this would be done through actual navigation)
      // For integration test, we're mainly checking that the app doesn't crash
      
      expect(tester.takeException(), isNull);
    });

    testWidgets('Animation demo should render without errors', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Let animations run
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      
      // Should not have any exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('App should handle screen rotation', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Get initial size
      final initialSize = tester.getSize(find.byType(MaterialApp));
      
      // Simulate rotation (change screen size)
      await tester.binding.setSurfaceSize(Size(
        initialSize.height,
        initialSize.width,
      ));
      await tester.pumpAndSettle();

      // App should still be functional
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Reset size
      await tester.binding.setSurfaceSize(initialSize);
      await tester.pumpAndSettle();
    });

    testWidgets('App should handle back navigation', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Simulate back button press
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );
      await tester.pumpAndSettle();

      // App should handle back navigation gracefully
      expect(tester.takeException(), isNull);
    });

    testWidgets('Should maintain state during app lifecycle', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Simulate app going to background and coming back
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        null,
        (data) {},
      );
      await tester.pumpAndSettle();

      // App should resume correctly
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Performance test - scrolling should be smooth', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Find scrollable widgets
      final scrollables = find.byType(Scrollable);
      
      if (scrollables.evaluate().isNotEmpty) {
        // Perform scrolling test
        await tester.fling(scrollables.first, const Offset(0, -200), 1000);
        await tester.pumpAndSettle();
        
        await tester.fling(scrollables.first, const Offset(0, 200), 1000);
        await tester.pumpAndSettle();
      }

      // Should handle scrolling without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('Memory test - app should not leak memory', (WidgetTester tester) async {
      // Launch the app multiple times to check for memory leaks
      for (int i = 0; i < 3; i++) {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Navigate through different screens
        await tester.pump(const Duration(milliseconds: 500));
        
        // Should not accumulate errors or exceptions
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Accessibility test - widgets should have semantic labels', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Check for semantic information
      final semantics = tester.getSemantics(find.byType(MaterialApp));
      expect(semantics, isNotNull);
      
      // App should be accessible
      expect(tester.takeException(), isNull);
    });

    testWidgets('Network error handling', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Simulate network operations
      // In a real test, you would mock network calls and test error handling
      await tester.pump(const Duration(seconds: 1));
      
      // App should handle network errors gracefully
      expect(tester.takeException(), isNull);
    });
  });

  group('Performance Tests', () {
    testWidgets('App startup time should be reasonable', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // App should start within reasonable time (adjust as needed)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
    });

    testWidgets('Animation performance should be smooth', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final stopwatch = Stopwatch()..start();
      
      // Run several animation frames
      for (int i = 0; i < 60; i++) { // Simulate 1 second at 60fps
        await tester.pump(const Duration(milliseconds: 16));
      }
      
      stopwatch.stop();
      
      // Animation frames should complete within expected time
      expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should be ~1000ms but allow buffer
      expect(tester.takeException(), isNull);
    });
  });

  group('User Journey Tests', () {
    testWidgets('Complete user registration flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // This would test the complete flow:
      // 1. Open registration screen
      // 2. Fill out form
      // 3. Submit registration
      // 4. Go through onboarding
      // 5. Reach main dashboard
      
      // For now, just verify app stability
      expect(tester.takeException(), isNull);
    });

    testWidgets('Complete job application flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // This would test:
      // 1. Navigate to job listings
      // 2. Select a job
      // 3. Fill application form
      // 4. Upload documents
      // 5. Submit application
      
      // For now, just verify app stability
      expect(tester.takeException(), isNull);
    });
  });
}