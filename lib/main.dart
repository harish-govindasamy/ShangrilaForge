import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/network/api_service.dart';
import 'core/services/provider_factory.dart';
import 'core/services/service_provider.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/enterprise_theme.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/employee/providers/employee_provider.dart';
import 'features/project/providers/project_provider.dart';
import 'features/timesheet/providers/timesheet_provider.dart';
import 'features/customer/providers/customer_provider.dart';
import 'features/reports/providers/report_provider.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  ApiService().initialize();

  // Load user data from storage
  await AuthService().loadUserDataFromStorage();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ShangrilaEngineersApp());
}

class ShangrilaEngineersApp extends StatelessWidget {
  const ShangrilaEngineersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(
            create: (_) => ProviderFactory.createEnhancedEmployeeProvider()),
        ChangeNotifierProvider(
            create: (_) => ProviderFactory.createEnhancedProjectProvider()),
        ChangeNotifierProvider(create: (_) => TimesheetProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        // Add other providers here as needed
      ],
      child: ServiceProvider.initialize(
        child: Consumer<AuthProvider>(builder: (context, authProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            initialRoute: AppRouter.initialRoute,
            onGenerateRoute: AppRouter.generateRoute,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light, // Force light theme only
          );
        }),
      ),
    );
  }
}
