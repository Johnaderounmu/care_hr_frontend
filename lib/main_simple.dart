import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/services/api_client.dart';
import 'core/constants/app_strings.dart';
import 'core/services/storage_service.dart';
// Hive model imports
import 'features/job_application/domain/models/job_model.dart';
import 'features/job_application/domain/models/job_application_model.dart';
import 'features/documents/domain/models/document_model.dart';
import 'features/notifications/domain/models/notification_model.dart';
import 'features/reports/domain/models/report_model.dart';
import 'core/models/user_model.dart';
import 'core/models/user_role.dart';
import 'features/user_management/domain/models/extended_user_model.dart';
import 'features/user_management/domain/models/user_role_model.dart';
import 'features/documents/data/services/document_service.dart';
import 'features/job_application/data/services/job_service.dart';
import 'features/job_application/data/services/job_application_service.dart';
import 'features/user_management/data/services/user_management_service.dart';
import 'features/reports/data/services/report_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';

// Simple logger class
class SimpleLogger {
  void i(String message) => debugPrint('INFO: $message');
  void w(String message) => debugPrint('WARNING: $message');
  void e(String message) => debugPrint('ERROR: $message');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = SimpleLogger();
  logger.i('Starting Care HR App...');

  // Initialize API client (REST/GraphQL) 
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
    Hive.registerAdapter(JobModelAdapter());
  }

  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(JobApplicationModelAdapter());
  }

  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(NotificationModelAdapter());
  }

  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(ReportModelAdapter());
  }

  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(ExtendedUserModelAdapter());
  }

  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(UserRoleModelAdapter());
  }

  // Initialize storage service
  try {
    await StorageService.init();
    logger.i('StorageService initialized');
  } catch (e) {
    logger.w('StorageService initialization failed: $e');
  }

  // Initialize services that need initialization and seed data
  try {
    await DocumentService.initializeSampleData();
    await JobService.initializeSampleData();
    await JobApplicationService.initializeSampleData();
    await UserManagementService.initializeSampleData();
    await ReportService.initializeSampleData();
    logger.i('Sample data initialized');
  } catch (e) {
    logger.w('Sample data initialization failed: $e');
  }

  logger.i('All initialization complete, starting app...');
  runApp(const CareHRApp());
}

class CareHRApp extends StatelessWidget {
  const CareHRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: AppStrings.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}