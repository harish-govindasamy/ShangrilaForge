class ApiConstants {
  // Base URL configuration
  static const String baseUrl = 'https://api.shangrilaengineers.com/v1';
  static const String developmentBaseUrl = 'http://localhost:3000/api/v1';
  static const String stagingBaseUrl =
      'https://staging-api.shangrilaengineers.com/v1';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Employee endpoints
  static const String employees = '/employees';
  static const String employeeSearch = '/employees/search';
  static const String employeeById = '/employees';
  static const String employeesByDepartment = '/employees/department';

  // Project endpoints
  static const String projects = '/projects';
  static const String projectSearch = '/projects/search';
  static const String projectById = '/projects';
  static const String projectsByStatus = '/projects/status';

  // Timesheet endpoints
  static const String timesheets = '/timesheets';
  static const String timesheetSearch = '/timesheets/search';
  static const String timesheetById = '/timesheets';
  static const String timesheetsByEmployee = '/timesheets/employee';
  static const String timesheetsByProject = '/timesheets/project';
  static const String timesheetApproval = '/timesheets/approval';

  // Customer endpoints
  static const String customers = '/customers';
  static const String customerSearch = '/customers/search';
  static const String customerById = '/customers';
  static const String customerProjects = '/customers/projects';

  // Report endpoints
  static const String reports = '/reports';
  static const String monthlyReports = '/reports/monthly';
  static const String weeklyReports = '/reports/weekly';
  static const String employeeReports = '/reports/employee';
  static const String projectReports = '/reports/project';
  static const String dashboardReports = '/reports/dashboard';
  static const String exportPdf = '/reports/export/pdf';
  static const String exportExcel = '/reports/export/excel';

  // File upload endpoints
  static const String uploadFile = '/upload';
  static const String uploadProfilePicture = '/upload/profile';
  static const String uploadDocument = '/upload/document';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';
  static const String deleteNotification = '/notifications/delete';

  // Analytics endpoints
  static const String analytics = '/analytics';
  static const String trackEvent = '/analytics/events';
  static const String userBehavior = '/analytics/behavior';

  // Settings endpoints
  static const String settings = '/settings';
  static const String userSettings = '/settings/user';
  static const String systemSettings = '/settings/system';

  // Content Type headers
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'multipart/form-data';
  static const String contentTypeUrlEncoded =
      'application/x-www-form-urlencoded';

  // Custom headers
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String acceptHeader = 'Accept';
  static const String contentTypeHeader = 'Content-Type';
  static const String userAgentHeader = 'User-Agent';
  static const String deviceIdHeader = 'X-Device-ID';
  static const String appVersionHeader = 'X-App-Version';
  static const String platformHeader = 'X-Platform';

  // Error codes
  static const int successCode = 200;
  static const int createdCode = 201;
  static const int noContentCode = 204;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int conflictCode = 409;
  static const int unprocessableEntityCode = 422;
  static const int internalServerErrorCode = 500;
  static const int badGatewayCode = 502;
  static const int serviceUnavailableCode = 503;

  // Rate limiting
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration rateLimitCooldown = Duration(minutes: 1);

  // Cache configuration
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  static const Duration longCacheDuration = Duration(hours: 1);
  static const Duration shortCacheDuration = Duration(minutes: 1);

  // API versioning
  static const String apiVersion = 'v1';
  static const String minSupportedVersion = 'v1.0.0';
  static const String currentVersion = 'v1.2.0';

  // Feature flags
  static const bool enableApiLogging = true;
  static const bool enableApiCaching = true;
  static const bool enableRetryLogic = true;
  static const bool enableMockMode = false;

  // Environment detection
  static String getCurrentBaseUrl() {
    // This would typically read from environment variables or build configuration
    const String environment =
        String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

    switch (environment) {
      case 'production':
        return baseUrl;
      case 'staging':
        return stagingBaseUrl;
      case 'development':
      default:
        return developmentBaseUrl;
    }
  }

  // Helper methods
  static String getEmployeeEndpoint(String? id) {
    return id != null ? '$employees/$id' : employees;
  }

  static String getProjectEndpoint(String? id) {
    return id != null ? '$projects/$id' : projects;
  }

  static String getTimesheetEndpoint(String? id) {
    return id != null ? '$timesheets/$id' : timesheets;
  }

  static String getCustomerEndpoint(String? id) {
    return id != null ? '$customers/$id' : customers;
  }

  static Map<String, String> getDefaultHeaders() {
    return {
      contentTypeHeader: contentTypeJson,
      acceptHeader: contentTypeJson,
      userAgentHeader: 'Shangrila Engineers App/$currentVersion',
      appVersionHeader: currentVersion,
      platformHeader: 'Flutter',
    };
  }

  static Map<String, String> getAuthHeaders(String token) {
    final headers = getDefaultHeaders();
    headers[authorizationHeader] = '$bearerPrefix$token';
    return headers;
  }
}
