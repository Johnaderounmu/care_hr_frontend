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
import 'core/services/push_notification_service.dart';
import 'features/documents/data/services/document_service.dart';
import 'features/job_application/data/services/job_service.dart';
import 'features/job_application/data/services/job_application_service.dart';
import 'features/user_management/data/services/user_management_service.dart';
import 'features/reports/data/services/report_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/job_data_provider.dart';
import 'core/providers/job_provider.dart';
import 'core/providers/document_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/router/app_router.dart';
// import 'core/debug/debug_route_tester.dart';
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
    logger.i('Environment variables loaded successfully');
  } catch (e) {
    logger.i('.env load skipped or failed: $e - using default values');
  }

  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize services
  await StorageService.init();

  // Initialize API client (REST/GraphQL) after env is loaded
  try {
    ApiClient.init();
    final token = StorageService.getUserToken();
    ApiClient.setAuthToken(token);
    logger.i('ApiClient initialized successfully');
  } catch (e) {
    logger.w('ApiClient initialization warning: $e');
    // Continue execution - the app can work without API client in demo mode
  }

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

  // Initialize critical services (notifications only)
  await NotificationService.init();
  
  // Initialize push notifications (PostgreSQL backend instead of Firebase)
  try {
    await PushNotificationService.initializeStatic();
    logger.i('Push notification service initialized successfully');
  } catch (e) {
    logger.w('Push notification service initialization failed: $e');
    // Continue execution - app can work without push notifications
  }

  // Initialize other services in background to prevent UI blocking
  Future.microtask(() async {
    try {
      await DocumentService.initializeSampleData();
      await JobService.init();
      await JobApplicationService.init();
      await JobService.initializeSampleData();
      await JobApplicationService.initializeSampleData();
      await UserManagementService.init();
      await UserManagementService.initializeSampleData();
      await ReportService.init();
      await ReportService.initializeSampleData();
      logger.i('Background services initialization completed');
    } catch (e) {
      logger.e('Background services initialization failed: $e');
    }
  });

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

class CareHRApp extends StatefulWidget {
  const CareHRApp({super.key});

  @override
  State<CareHRApp> createState() => _CareHRAppState();
}

class _CareHRAppState extends State<CareHRApp> {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    // Initialize auth provider immediately
    _authProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => JobDataService()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.createRouter(_authProvider),
            // In debug mode attach a hidden DebugRouteTester
            builder: (context, widget) {
              return Column(
                children: [
                  const DemoBanner(),
                  Expanded(
                    child: Stack(
                      children: [
                        if (widget != null) widget,
                        // Temporarily disabled for testing job listing
                        // if (kDebugMode) const DebugRouteTester(),
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
