import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/dashboard/presentation/pages/hr_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/applicant_dashboard_page.dart';
import '../../features/job_application/presentation/pages/application_form_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/documents/presentation/pages/document_upload_page.dart';
import '../../features/documents/presentation/pages/applicant_documents_page.dart';
import '../../features/documents/presentation/pages/hr_document_review_page.dart';
import '../../features/job_application/presentation/pages/job_listing_page.dart';
import '../../features/reports/presentation/pages/reports_dashboard_page.dart';
import '../../features/interviews/presentation/pages/schedule_interview_page.dart';
import '../../core/providers/auth_provider.dart';
// ...existing code... (removed unused import)

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Use the AuthProvider from the widget tree so redirect sees the real state
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final user = authProvider.user;

      // Use state.uri.toString() for location representation
      final location = state.uri.toString();

      // If not authenticated and not on auth pages, redirect to login
      if (!isAuthenticated && !_isAuthRoute(location)) {
        return '/login';
      }

      // If authenticated and on auth pages, redirect to appropriate dashboard
      if (isAuthenticated && _isAuthRoute(location)) {
        if (user?.isHRAdmin == true || user?.isHRManager == true) {
          return '/hr-dashboard';
        } else if (user?.isApplicant == true) {
          return '/applicant-dashboard';
        }
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // HR Dashboard Routes
      GoRoute(
        path: '/hr-dashboard',
        name: 'hr-dashboard',
        builder: (context, state) => const HRDashboardPage(),
      ),

      // Applicant Dashboard Routes
      GoRoute(
        path: '/applicant-dashboard',
        name: 'applicant-dashboard',
        builder: (context, state) => const ApplicantDashboardPage(),
      ),

      // Job Application Routes
      GoRoute(
        path: '/application-form',
        name: 'application-form',
        builder: (context, state) => const ApplicationFormPage(),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      // Settings Routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // Document Routes
      GoRoute(
        path: '/document-upload',
        name: 'document-upload',
        builder: (context, state) => const DocumentUploadPage(),
      ),
      GoRoute(
        path: '/applicant-documents',
        name: 'applicant-documents',
        builder: (context, state) => const ApplicantDocumentsPage(),
      ),
      GoRoute(
        path: '/hr-document-review',
        name: 'hr-document-review',
        builder: (context, state) => const HRDocumentReviewPage(),
      ),

      // Job Application Routes
      GoRoute(
        path: '/job-listing',
        name: 'job-listing',
        builder: (context, state) => const JobListingPage(),
      ),

      // Reports Routes
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsDashboardPage(),
      ),

      // Interview Routes
      GoRoute(
        path: '/schedule-interview',
        name: 'schedule-interview',
        builder: (context, state) => const ScheduleInterviewPage(),
      ),

      // Nested HR Routes
      GoRoute(
        path: '/hr',
        name: 'hr',
        builder: (context, state) => const HRDashboardPage(),
        routes: [
          GoRoute(
            path: 'applicants',
            name: 'hr-applicants',
            builder: (context, state) =>
                const HRDashboardPage(), // TODO: Create ApplicantsPage
          ),
          GoRoute(
            path: 'documents',
            name: 'hr-documents',
            builder: (context, state) => const HRDocumentReviewPage(),
          ),
          GoRoute(
            path: 'reports',
            name: 'hr-reports',
            builder: (context, state) => const ReportsDashboardPage(),
          ),
        ],
      ),

      // Nested Applicant Routes
      GoRoute(
        path: '/applicant',
        name: 'applicant',
        builder: (context, state) => const ApplicantDashboardPage(),
        routes: [
          GoRoute(
            path: 'jobs',
            name: 'applicant-jobs',
            builder: (context, state) => const JobListingPage(),
          ),
          GoRoute(
            path: 'documents',
            name: 'applicant-documents-nested',
            builder: (context, state) => const ApplicantDocumentsPage(),
          ),
          GoRoute(
            path: 'profile',
            name: 'applicant-profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );

  static bool _isAuthRoute(String location) {
    return location == '/login' ||
        location == '/signup' ||
        location == '/forgot-password';
  }
}
