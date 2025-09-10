class AppConstants {
  // App Information
  static const String appName = 'Shangrila Engineers';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Employee & Project Management System';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String userRoleKey = 'user_role';
  static const String employeeDataKey = 'employee_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String lastSyncKey = 'last_sync';
  
  // User Roles
  static const String adminRole = 'admin';
  static const String principalRole = 'principal';
  static const String employeeRole = 'employee';
  
  // Project Status
  static const String projectStatusOpen = 'open';
  static const String projectStatusInProgress = 'in-progress';
  static const String projectStatusCompleted = 'completed';
  
  // Timesheet Status
  static const String timesheetStatusDraft = 'draft';
  static const String timesheetStatusSubmitted = 'submitted';
  static const String timesheetStatusApproved = 'approved';
  static const String timesheetStatusRejected = 'rejected';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int maxNameLength = 100;
  static const int maxAddressLength = 500;
  static const int maxDescriptionLength = 1000;
  
  // Time Constants
  static const int sessionTimeoutMinutes = 30;
  static const int autoSyncIntervalMinutes = 15;
  static const int maxRetryAttempts = 3;
  
  // File Upload
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
  
  // Error Messages
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unauthorizedErrorMessage = 'Unauthorized access. Please login again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful';
  static const String logoutSuccessMessage = 'Logout successful';
  static const String saveSuccessMessage = 'Data saved successfully';
  static const String deleteSuccessMessage = 'Data deleted successfully';
  static const String updateSuccessMessage = 'Data updated successfully';
  
  // Notification Types
  static const String notificationTypeInfo = 'info';
  static const String notificationTypeSuccess = 'success';
  static const String notificationTypeWarning = 'warning';
  static const String notificationTypeError = 'error';
  
  // Chart Colors
  static const List<int> chartColors = [
    0xFF2196F3, // Blue
    0xFF4CAF50, // Green
    0xFFFF9800, // Orange
    0xFFF44336, // Red
    0xFF9C27B0, // Purple
    0xFF00BCD4, // Cyan
    0xFFFFEB3B, // Yellow
    0xFF795548, // Brown
  ];
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
