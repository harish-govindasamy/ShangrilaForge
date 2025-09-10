import 'package:flutter/material.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  
  Map<String, dynamic>? _dashboardSummary;
  Map<String, dynamic>? _employeeReport;
  Map<String, dynamic>? _projectReport;
  Map<String, dynamic>? _timesheetReport;
  Map<String, dynamic>? _monthlyReport;
  Map<String, dynamic>? _weeklyReport;
  Map<String, dynamic>? _analytics;
  
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get dashboardSummary => _dashboardSummary;
  Map<String, dynamic>? get employeeReport => _employeeReport;
  Map<String, dynamic>? get projectReport => _projectReport;
  Map<String, dynamic>? get timesheetReport => _timesheetReport;
  Map<String, dynamic>? get monthlyReport => _monthlyReport;
  Map<String, dynamic>? get weeklyReport => _weeklyReport;
  Map<String, dynamic>? get analytics => _analytics;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load dashboard summary
  Future<void> loadDashboardSummary() async {
    _setLoading(true);
    _clearError();

    try {
      _dashboardSummary = await _reportService.getDashboardSummary();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load employee report
  Future<void> loadEmployeeReport({
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _employeeReport = await _reportService.getEmployeeReport(
        employeeId: employeeId,
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load project report
  Future<void> loadProjectReport({
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _projectReport = await _reportService.getProjectReport(
        projectId: projectId,
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load timesheet report
  Future<void> loadTimesheetReport({
    String? employeeId,
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _timesheetReport = await _reportService.getTimesheetReport(
        employeeId: employeeId,
        projectId: projectId,
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load monthly report
  Future<void> loadMonthlyReport({
    int? year,
    int? month,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _monthlyReport = await _reportService.getMonthlyReport(
        year: year,
        month: month,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load weekly report
  Future<void> loadWeeklyReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _weeklyReport = await _reportService.getWeeklyReport(
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load analytics
  Future<void> loadAnalytics({
    String? metric,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _analytics = await _reportService.getAnalytics(
        metric: metric,
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Export report
  Future<Map<String, dynamic>?> exportReport({
    required String reportType,
    required String format,
    Map<String, dynamic>? filters,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _reportService.exportReport(
        reportType: reportType,
        format: format,
        filters: filters,
      );
      notifyListeners();
      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get dashboard metrics
  Map<String, dynamic> getDashboardMetrics() {
    if (_dashboardSummary == null) return {};
    
    return {
      'totalEmployees': _dashboardSummary!['total_employees'] ?? 0,
      'totalProjects': _dashboardSummary!['total_projects'] ?? 0,
      'totalCustomers': _dashboardSummary!['total_customers'] ?? 0,
      'totalHours': _dashboardSummary!['total_hours'] ?? 0.0,
      'activeProjects': _dashboardSummary!['active_projects'] ?? 0,
      'pendingTimesheets': _dashboardSummary!['pending_timesheets'] ?? 0,
      'completedProjects': _dashboardSummary!['completed_projects'] ?? 0,
      'totalRevenue': _dashboardSummary!['total_revenue'] ?? 0.0,
    };
  }

  // Get employee metrics
  Map<String, dynamic> getEmployeeMetrics() {
    if (_employeeReport == null) return {};
    
    return {
      'totalHours': _employeeReport!['total_hours'] ?? 0.0,
      'projectsWorked': _employeeReport!['projects_worked'] ?? 0,
      'averageHoursPerDay': _employeeReport!['average_hours_per_day'] ?? 0.0,
      'timesheetsSubmitted': _employeeReport!['timesheets_submitted'] ?? 0,
      'timesheetsApproved': _employeeReport!['timesheets_approved'] ?? 0,
    };
  }

  // Get project metrics
  Map<String, dynamic> getProjectMetrics() {
    if (_projectReport == null) return {};
    
    return {
      'totalCost': _projectReport!['total_cost'] ?? 0.0,
      'totalHours': _projectReport!['total_hours'] ?? 0.0,
      'teamSize': _projectReport!['team_size'] ?? 0,
      'completionPercentage': _projectReport!['completion_percentage'] ?? 0.0,
      'budgetUtilization': _projectReport!['budget_utilization'] ?? 0.0,
    };
  }

  // Get timesheet metrics
  Map<String, dynamic> getTimesheetMetrics() {
    if (_timesheetReport == null) return {};
    
    return {
      'totalHours': _timesheetReport!['total_hours'] ?? 0.0,
      'submittedCount': _timesheetReport!['submitted_count'] ?? 0,
      'approvedCount': _timesheetReport!['approved_count'] ?? 0,
      'pendingCount': _timesheetReport!['pending_count'] ?? 0,
      'averageHoursPerWeek': _timesheetReport!['average_hours_per_week'] ?? 0.0,
    };
  }

  // Get monthly metrics
  Map<String, dynamic> getMonthlyMetrics() {
    if (_monthlyReport == null) return {};
    
    return {
      'totalHours': _monthlyReport!['total_hours'] ?? 0.0,
      'totalProjects': _monthlyReport!['total_projects'] ?? 0,
      'newEmployees': _monthlyReport!['new_employees'] ?? 0,
      'completedProjects': _monthlyReport!['completed_projects'] ?? 0,
      'totalRevenue': _monthlyReport!['total_revenue'] ?? 0.0,
    };
  }

  // Get weekly metrics
  Map<String, dynamic> getWeeklyMetrics() {
    if (_weeklyReport == null) return {};
    
    return {
      'totalHours': _weeklyReport!['total_hours'] ?? 0.0,
      'activeProjects': _weeklyReport!['active_projects'] ?? 0,
      'timesheetsSubmitted': _weeklyReport!['timesheets_submitted'] ?? 0,
      'timesheetsApproved': _weeklyReport!['timesheets_approved'] ?? 0,
      'averageProductivity': _weeklyReport!['average_productivity'] ?? 0.0,
    };
  }

  // Get analytics data
  Map<String, dynamic> getAnalyticsData() {
    if (_analytics == null) return {};
    
    return {
      'chartData': _analytics!['chart_data'] ?? [],
      'trends': _analytics!['trends'] ?? {},
      'insights': _analytics!['insights'] ?? [],
      'recommendations': _analytics!['recommendations'] ?? [],
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
