import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// removed unused go_router import
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/api_client.dart';
// Removed Firebase - using PostgreSQL backend instead
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/services/storage_service.dart';
// Hive model imports (register adapters, generated parts are included via `part` in these files)
import 'features/job_application/domain/models/job_model.dart';
import 'features/job_application/domain/models/job_application_model.dart';
import 'features/documents/domain/models/document_model.dart';
import 'features/notifications/domain/models/notification_model.dart';
import 'features/reports/domain/models/report_model.dart';
import 'core/models/user_model.dart';
import 'core/models/user_role.dart';
import 'features/user_management/domain/models/extended_user_model.dart';
import 'features/user_management/domain/models/user_role_model.dart';
// removed unused auth_service import
import 'core/services/notification_service.dart';
import 'features/documents/data/services/document_service.dart';
import 'features/job_application/data/services/job_service.dart';
import 'features/job_application/data/services/job_application_service.dart';
import 'features/user_management/data/services/user_management_service.dart';
import 'features/reports/data/services/report_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/job_data_provider.dart';
import 'core/router/app_router.dart';
import 'core/debug/debug_route_tester.dart';
import 'core/widgets/demo_banner.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();

  // Using PostgreSQL backend instead of Firebase
  logger.i('Initializing CareHR app with PostgreSQL backend');

  // Load environment variables if a .env file exists (optional local dev)
  try {
    await dotenv.load();
    logger.i('Loaded .env (if present)');
  } catch (e) {
    logger.i('.env load skipped or failed: $e');
  }

  // Initialize API client (REST/GraphQL) after env is loaded
  try {
    ApiClient.init();
    logger.i('ApiClient initialized');
  } catch (e) {
    logger.w('ApiClient initialization warning: $e');
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Register generated Hive TypeAdapters (required before opening boxes / writing objects)
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserModelAdapter());
  if (!Hive.isAdapterRegistered(36)) Hive.registerAdapter(UserRoleAdapter());

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(DocumentModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(DocumentStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(DocumentTypeAdapter());

  if (!Hive.isAdapterRegistered(26)) Hive.registerAdapter(JobModelAdapter());
  if (!Hive.isAdapterRegistered(27)) Hive.registerAdapter(JobStatusAdapter());

  if (!Hive.isAdapterRegistered(30)) {
    Hive.registerAdapter(JobApplicationModelAdapter());
  }
  if (!Hive.isAdapterRegistered(32)) {
    Hive.registerAdapter(ApplicationScoreAdapter());
  }
  if (!Hive.isAdapterRegistered(33)) {
    Hive.registerAdapter(InterviewModelAdapter());
  }
  if (!Hive.isAdapterRegistered(31)) {
    Hive.registerAdapter(ApplicationStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(34)) {
    Hive.registerAdapter(InterviewTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(35)) {
    Hive.registerAdapter(InterviewStatusAdapter());
  }

  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(NotificationModelAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(NotificationTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(NotificationPriorityAdapter());
  }

  Hive.registerAdapter(ReportModelAdapter());
  Hive.registerAdapter(AnalyticsDataModelAdapter());
  Hive.registerAdapter(ChartDataModelAdapter());
  Hive.registerAdapter(ChartDataPointAdapter());
  Hive.registerAdapter(ReportTypeAdapter());
  Hive.registerAdapter(ReportCategoryAdapter());
  Hive.registerAdapter(ReportStatusAdapter());
  Hive.registerAdapter(AnalyticsMetricTypeAdapter());
  Hive.registerAdapter(ChartTypeAdapter());

  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(UserRoleModelAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(PermissionAdapter());
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(ExtendedUserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) {
    Hive.registerAdapter(UserAuditLogModelAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) Hive.registerAdapter(UserStatusAdapter());
  if (!Hive.isAdapterRegistered(16)) {
    Hive.registerAdapter(AuditLogLevelAdapter());
  }

  // Simple verification logs for critical adapters
  final checks = {
    0: 'UserModel',
    1: 'DocumentModel',
    3: 'JobModel',
    4: 'JobStatus',
    5: 'JobApplicationModel',
  };
  for (final entry in checks.entries) {
    final registered = Hive.isAdapterRegistered(entry.key);
    logger.i(
        'Hive adapter for ${entry.value} (typeId=${entry.key}) registered: $registered');
  }

  // Initialize services
  await StorageService.init();
  await NotificationService.init();
  await DocumentService.initializeSampleData();
  await JobService.init();
  await JobApplicationService.init();
  await JobService.initializeSampleData();
  await JobApplicationService.initializeSampleData();
  await UserManagementService.init();
  await UserManagementService.initializeSampleData();
  await ReportService.init();
  await ReportService.initializeSampleData();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.backgroundLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CareHRApp());
}

class CareHRApp extends StatelessWidget {
  const CareHRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobDataService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
            // In debug mode attach a hidden DebugRouteTester
            builder: (context, widget) {
              return Column(
                children: [
                  const DemoBanner(),
                  Expanded(
                    child: Stack(
                      children: [
                        if (widget != null) widget,
                        if (kDebugMode) const DebugRouteTester(),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
