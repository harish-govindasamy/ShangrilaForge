import '../../../core/network/api_service.dart';
import '../../../core/constants/api_endpoints.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final ApiService _apiService = ApiService();

  // Get dashboard summary
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await _apiService.get(ApiEndpoints.dashboardSummary);
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch dashboard summary');
    } catch (e) {
      throw Exception('Error fetching dashboard summary: $e');
    }
  }

  // Get employee report
  Future<Map<String, dynamic>> getEmployeeReport({
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await _apiService.get(
        ApiEndpoints.employeeReport,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch employee report');
    } catch (e) {
      throw Exception('Error fetching employee report: $e');
    }
  }

  // Get project report
  Future<Map<String, dynamic>> getProjectReport({
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (projectId != null) queryParams['project_id'] = projectId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await _apiService.get(
        ApiEndpoints.projectReport,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch project report');
    } catch (e) {
      throw Exception('Error fetching project report: $e');
    }
  }

  // Get timesheet report
  Future<Map<String, dynamic>> getTimesheetReport({
    String? employeeId,
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (projectId != null) queryParams['project_id'] = projectId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await _apiService.get(
        ApiEndpoints.timesheetReport,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch timesheet report');
    } catch (e) {
      throw Exception('Error fetching timesheet report: $e');
    }
  }

  // Get monthly report
  Future<Map<String, dynamic>> getMonthlyReport({
    int? year,
    int? month,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _apiService.get(
        ApiEndpoints.monthlyReport,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch monthly report');
    } catch (e) {
      throw Exception('Error fetching monthly report: $e');
    }
  }

  // Get weekly report
  Future<Map<String, dynamic>> getWeeklyReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await _apiService.get(
        ApiEndpoints.weeklyReport,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch weekly report');
    } catch (e) {
      throw Exception('Error fetching weekly report: $e');
    }
  }

  // Export report
  Future<Map<String, dynamic>> exportReport({
    required String reportType,
    required String format, // 'pdf', 'excel', 'csv'
    Map<String, dynamic>? filters,
  }) async {
    try {
      final data = <String, dynamic>{
        'report_type': reportType,
        'format': format,
        if (filters != null) 'filters': filters,
      };

      final response = await _apiService.post(
        ApiEndpoints.exportReport,
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to export report');
    } catch (e) {
      throw Exception('Error exporting report: $e');
    }
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalytics({
    String? metric,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (metric != null) queryParams['metric'] = metric;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await _apiService.get(
        ApiEndpoints.analytics,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch analytics');
    } catch (e) {
      throw Exception('Error fetching analytics: $e');
    }
  }
}
