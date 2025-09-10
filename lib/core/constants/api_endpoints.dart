import '../config/environment_config.dart';

class ApiEndpoints {
  // Base URL - Automatically configured based on environment
  static String get baseUrl => EnvironmentConfig.baseUrl;
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String validateCredentials = '/auth/validate-credentials';
  
  // Employee endpoints
  static const String employees = '/employees';
  static String employeeById(String id) => '/employees/$id';
  static const String createEmployee = '/employees';
  static String updateEmployee(String id) => '/employees/$id';
  static String deleteEmployee(String id) => '/employees/$id';
  
  // User endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static const String createUser = '/users';
  static String updateUser(String id) => '/users/$id';
  static String deleteUser(String id) => '/users/$id';
  static const String resetPassword = '/users/reset-password';
  static const String bulkUpdateUsers = '/users/bulk-update';
  static const String checkUsername = '/users/check-username';
  
  // Project endpoints
  static const String projects = '/projects';
  static String projectById(String id) => '/projects/$id';
  static const String createProject = '/projects';
  static String updateProject(String id) => '/projects/$id';
  static String deleteProject(String id) => '/projects/$id';
  static String projectByStatus(String status) => '/projects/status/$status';
  
  // Timesheet endpoints
  static const String timesheets = '/timesheets';
  static String timesheetById(String id) => '/timesheets/$id';
  static const String createTimesheet = '/timesheets';
  static String updateTimesheet(String id) => '/timesheets/$id';
  static String deleteTimesheet(String id) => '/timesheets/$id';
  static const String submitTimesheet = '/timesheets/submit';
  static const String approveTimesheet = '/timesheets/approve';
  static String timesheetsByEmployee(String employeeId) => '/timesheets/employee/$employeeId';
  static String timesheetsByProject(String projectId) => '/timesheets/project/$projectId';
  
  // Customer endpoints
  static const String customers = '/customers';
  static String customerById(String id) => '/customers/$id';
  static const String createCustomer = '/customers';
  static String updateCustomer(String id) => '/customers/$id';
  static String deleteCustomer(String id) => '/customers/$id';
  
  // Report endpoints
  static const String reports = '/reports';
  static const String employeeReport = '/reports/employee';
  static const String projectReport = '/reports/project';
  static const String monthlyReport = '/reports/monthly';
  static const String weeklyReport = '/reports/weekly';
  static const String dashboardReport = '/reports/dashboard';
  static const String exportReport = '/reports/export';
  static const String timesheetReport = '/reports/timesheet';
  static const String analytics = '/reports/analytics';
  
  // Dashboard endpoints
  static const String dashboard = '/dashboard';
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardCharts = '/dashboard/charts';
  static const String dashboardSummary = '/dashboard/summary';
  
  // Notification endpoints
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const String markAsRead = '/notifications/mark-read';
  static const String sendNotification = '/notifications/send';
  
  // File upload endpoints
  static const String uploadFile = '/upload';
  static const String downloadFile = '/download';
  
  // Utility endpoints
  static const String healthCheck = '/health';
  static const String version = '/version';
}
