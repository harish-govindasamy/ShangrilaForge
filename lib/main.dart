import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/network/api_service.dart';
import 'core/services/provider_factory.dart';
import 'core/services/service_provider.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/employee/providers/employee_provider.dart';
import 'features/project/providers/project_provider.dart';
import 'features/timesheet/providers/timesheet_provider.dart';
import 'features/customer/providers/customer_provider.dart';
import 'features/reports/providers/report_provider.dart';
import 'features/dashboard/screens/splash_screen.dart';
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
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              initialRoute: AppRouter.initialRoute,
              onGenerateRoute: AppRouter.generateRoute,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                primaryColor: const Color(0xFF2196F3),
                scaffoldBackgroundColor: Colors.grey[50],
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  centerTitle: true,
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              useMaterial3: true,
              home: const SplashScreen(),
            );
          }
        ),
      ),
    );
  }
}
