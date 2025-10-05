import 'package:flutter/material.dart';
import '../router/app_router.dart';

/// Debug helper that, when present in debug builds, will attempt to navigate
/// to a set of main routes (with delays) to exercise layout code like headers.
class DebugRouteTester extends StatefulWidget {
  const DebugRouteTester({super.key});

  @override
  State<DebugRouteTester> createState() => _DebugRouteTesterState();
}

class _DebugRouteTesterState extends State<DebugRouteTester> {
  final _routesToTest = <String>[
    '/hr-dashboard',
    '/applicant-dashboard',
    '/applicant-documents',
    '/job-listing',
    '/profile',
    '/reports',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runTests());
  }

  Future<void> _runTests() async {
    // Small delay to allow app to finish initial navigation
    for (final route in _routesToTest) {
      try {
        if (!mounted) return;
        AppRouter.router.push(route);
        debugPrint('DebugRouteTester: navigated to $route');
        // Wait a bit for layouts to settle
        await Future<void>.delayed(const Duration(milliseconds: 700));
      } catch (e) {
        debugPrint('DebugRouteTester: navigation to $route failed: $e');
      }
    }
    // Return to login after a short delay
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      try {
        AppRouter.router.go('/login');
        debugPrint('DebugRouteTester: returned to /login');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
