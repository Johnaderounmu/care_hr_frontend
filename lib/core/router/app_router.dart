import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/dashboard/presentation/pages/enhanced_hr_dashboard_page.dart';
import '../../features/job_application/presentation/pages/enhanced_job_listing_page.dart';
import '../../features/dashboard/presentation/pages/applicant_dashboard_page.dart';
import '../../features/job_application/presentation/pages/application_form_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/documents/presentation/pages/document_upload_page.dart';
import '../../features/documents/presentation/pages/applicant_documents_page.dart';
import '../../features/documents/presentation/pages/hr_document_review_page.dart';
import '../../features/documents/presentation/pages/file_upload_page.dart';
import '../../features/reports/presentation/pages/reports_dashboard_page.dart';
import '../../features/reports/presentation/pages/generate_report_page.dart';
import '../../features/reports/presentation/pages/all_reports_page.dart';
import '../../features/interviews/presentation/pages/schedule_interview_page.dart';
import '../../features/applications/presentation/pages/applications_management_page.dart';
import '../../features/job_management/presentation/pages/create_job_page.dart';
import '../../features/hr/presentation/pages/hr_applicants_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/dashboard/presentation/pages/animated_dashboard_demo.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/analytics/presentation/pages/analytics_dashboard.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/splash_screen.dart';
// ...existing code... (removed unused import)

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: authProvider,  // Listen for auth state changes
      redirect: (context, state) {
      // Use state.uri.toString() for location representation
      final location = state.uri.toString();

      // Helper function to check if current route is an auth route
      bool isAuthRoute(String location) {
        return location == '/login' ||
            location == '/signup' ||
            location == '/forgot-password';
      }

      // Skip redirect for splash screen
      if (location == '/splash') {
        return null;
      }

      // Use the AuthProvider from the widget tree so redirect sees the real state
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final user = authProvider.user;

      // Debug logging
      print('🔄 Router redirect - Location: $location');
      print('🔄 Router redirect - IsAuthenticated: $isAuthenticated');
      print('🔄 Router redirect - User: ${user?.email} (${user?.role})');
      print('🔄 Router redirect - IsHRAdmin: ${user?.isHRAdmin}');
      print('🔄 Router redirect - IsLoading: ${authProvider.isLoading}');

      // If still loading, stay on current route
      if (authProvider.isLoading) {
        print('🔄 Router redirect - Still loading, staying on current route');
        return null;
      }

      // If not authenticated and not on auth pages, redirect to login
      if (!isAuthenticated && !isAuthRoute(location)) {
        print('🔄 Router redirect - Not authenticated, redirecting to /login');
        return '/login';
      }

      // If authenticated and on auth pages, redirect to appropriate dashboard
      if (isAuthenticated && isAuthRoute(location)) {
        if (user?.isHRAdmin == true || user?.isHRManager == true) {
          print('🔄 Router redirect - HR user authenticated, redirecting to /hr-dashboard');
          return '/hr-dashboard';
        } else if (user?.isApplicant == true) {
          print('🔄 Router redirect - Applicant authenticated, redirecting to /applicant-dashboard');
          return '/applicant-dashboard';
        }
      }

      print('🔄 Router redirect - No redirect needed');
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => SplashScreen(
          onComplete: () {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.isAuthenticated) {
              final user = authProvider.user;
              if (user?.isHRAdmin == true || user?.isHRManager == true) {
                context.go('/hr-dashboard');
              } else {
                context.go('/applicant-dashboard');
              }
            } else {
              context.go('/login');
            }
          },
        ),
      ),

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
        builder: (context, state) => const EnhancedHRDashboardPage(),
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
        path: '/file-upload',
        name: 'file-upload',
        builder: (context, state) => const FileUploadPage(),
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
        builder: (context, state) => const EnhancedJobListingPage(),
      ),

      // Reports Routes
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsDashboardPage(),
        routes: [
          GoRoute(
            path: 'generate-report',
            name: 'generate-report',
            builder: (context, state) => const GenerateReportPage(),
          ),
          GoRoute(
            path: 'all-reports',
            name: 'all-reports',
            builder: (context, state) => const AllReportsPage(),
          ),
        ],
      ),

      // Interview Routes
      GoRoute(
        path: '/schedule-interview',
        name: 'schedule-interview',
        builder: (context, state) => const ScheduleInterviewPage(),
      ),

      // Animation Demo Routes
      GoRoute(
        path: '/animation-demo',
        name: 'animation-demo',
        builder: (context, state) => const AnimatedDashboardDemo(),
      ),

      // Onboarding Routes
      GoRoute(
        path: '/onboarding/:userType',
        name: 'onboarding',
        builder: (context, state) {
          final userType = state.pathParameters['userType'] ?? 'applicant';
          return OnboardingScreen(userType: userType);
        },
      ),

      // New Feature Routes
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      
      GoRoute(
        path: '/applications',
        name: 'applications',
        builder: (context, state) => const ApplicationsManagementPage(),
      ),
      
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsDashboard(),
      ),
      
      GoRoute(
        path: '/create-job',
        name: 'create-job',
        builder: (context, state) => const CreateJobPage(),
      ),

      // Nested HR Routes
      GoRoute(
        path: '/hr',
        name: 'hr',
        builder: (context, state) => const EnhancedHRDashboardPage(),
        routes: [
          GoRoute(
            path: 'applicants',
            name: 'hr-applicants',
            builder: (context, state) => const HRApplicantsPage(),
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
            builder: (context, state) => const EnhancedJobListingPage(),
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
  }
}
