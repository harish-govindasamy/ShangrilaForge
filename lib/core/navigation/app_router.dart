import 'package:flutter/material.dart';
import '../../features/dashboard/screens/main_dashboard_screen.dart';
import '../../features/employee/screens/employee_detail_screen.dart';
import '../../features/employee/screens/employee_form_screen.dart';
import '../../features/employee/screens/employee_list_screen_wrapper.dart';
import '../../features/project/screens/project_detail_screen.dart';
import '../../features/project/screens/project_form_screen.dart';
import '../../features/project/screens/project_list_screen_wrapper.dart';
import '../../features/timesheet/screens/timesheet_detail_screen.dart';
import '../../features/timesheet/screens/timesheet_list_screen.dart';
import '../../features/customer/screens/customer_detail_screen.dart';
import '../../features/customer/screens/customer_list_screen.dart';
import '../../features/reports/screens/reports_screen.dart';

// Import newly created screens
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../../features/auth/screens/settings_screen.dart';
import '../../features/auth/screens/company_settings_screen.dart';
import '../../features/auth/screens/password_change_screen.dart';
import '../../features/timesheet/screens/timesheet_form_screen.dart';
import '../../features/customer/screens/customer_form_screen.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';

  // Employee routes
  static const String employeesRoute = '/employees';
  static const String employeeDetailRoute = '/employees/detail';
  static const String employeeAddRoute = '/employees/add';
  static const String employeeEditRoute = '/employees/edit';

  // Project routes
  static const String projectsRoute = '/projects';
  static const String projectDetailRoute = '/projects/detail';
  static const String projectCreateRoute = '/projects/create';
  static const String projectEditRoute = '/projects/edit';
  static const String myProjectsRoute = '/projects/my';

  // Timesheet routes
  static const String timesheetsRoute = '/timesheets';
  static const String timesheetDetailRoute = '/timesheets/detail';
  static const String timesheetAddRoute = '/timesheets/add';
  static const String timesheetEditRoute = '/timesheets/edit';
  static const String timesheetApproveRoute = '/timesheets/approve';
  static const String timesheetHistoryRoute = '/timesheets/history';
  static const String timesheetLogRoute = '/timesheets/log';

  // Customer routes
  static const String customersRoute = '/customers';
  static const String customerDetailRoute = '/customers/detail';
  static const String customerAddRoute = '/customers/add';
  static const String customerEditRoute = '/customers/edit';

  // Report routes
  static const String reportsRoute = '/reports';
  static const String teamReportsRoute = '/reports/team';
  static const String projectReportsRoute = '/reports/projects';
  static const String timesheetReportsRoute = '/reports/timesheets';
  static const String financeReportsRoute = '/reports/finance';

  // User routes
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String companySettingsRoute = '/settings/company';
  static const String passwordChangeRoute = '/settings/password';
  static const String usersRoute = '/users';

  // Other routes
  static const String approvalsRoute = '/approvals';
  static const String teamRoute = '/team';
  static const String hoursRoute = '/hours';
  static const String totalHoursRoute = '/hours/total';
  static const String expensesRoute = '/expenses';
  static const String revenueRoute = '/finance/revenue';
  static const String clientsRoute = '/clients';
  static const String reviewsRoute = '/reviews';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case initialRoute:
      case dashboardRoute:
        return MaterialPageRoute(builder: (_) => const MainDashboardScreen());

      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      // Employee routes
      case employeesRoute:
        return MaterialPageRoute(
            builder: (_) => const EmployeeListScreenWrapper());

      case employeeDetailRoute:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => EmployeeDetailScreen(employeeId: args),
          );
        }
        return _errorRoute();

      case employeeAddRoute:
        return MaterialPageRoute(builder: (_) => const EmployeeFormScreen());

      case employeeEditRoute:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => EmployeeFormScreen(employeeId: args),
          );
        }
        return _errorRoute();

      // Project routes
      case projectsRoute:
      case myProjectsRoute:
        return MaterialPageRoute(
            builder: (_) => const ProjectListScreenWrapper());

      case projectDetailRoute:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectId: args),
          );
        }
        return _errorRoute();

      case projectCreateRoute:
        return MaterialPageRoute(builder: (_) => const ProjectFormScreen());

      case projectEditRoute:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProjectFormScreen(projectId: args),
          );
        }
        return _errorRoute();

      // Timesheet routes
      case timesheetsRoute:
      case timesheetApproveRoute:
      case timesheetHistoryRoute:
      case timesheetLogRoute:
        return MaterialPageRoute(builder: (_) => const TimesheetListScreen());

      case timesheetDetailRoute:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => TimesheetDetailScreen(timesheetId: args),
          );
        }
        return _errorRoute();

      case timesheetAddRoute:
        return MaterialPageRoute(builder: (_) => const TimesheetFormScreen());

      case timesheetEditRoute:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => TimesheetFormScreen(timesheetId: args),
          );
        }
        return _errorRoute();

      // Customer routes
      case customersRoute:
      case clientsRoute:
        return MaterialPageRoute(builder: (_) => const CustomerListScreen());

      case customerDetailRoute:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => CustomerDetailScreen(customerId: args),
          );
        }
        return _errorRoute();

      case customerAddRoute:
        return MaterialPageRoute(builder: (_) => const CustomerFormScreen());

      case customerEditRoute:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => CustomerFormScreen(customerId: args),
          );
        }
        return _errorRoute();

      // Report routes
      case reportsRoute:
      case teamReportsRoute:
      case projectReportsRoute:
      case timesheetReportsRoute:
      case financeReportsRoute:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

      // User routes
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case companySettingsRoute:
        return MaterialPageRoute(builder: (_) => const CompanySettingsScreen());

      case passwordChangeRoute:
        return MaterialPageRoute(builder: (_) => const PasswordChangeScreen());

      // Default - error route
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(
            child: Text('Page not found!'),
          ),
        );
      },
    );
  }
}
