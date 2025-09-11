class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  // Mock data for demo purposes
  // In a real app, these would be API calls

  // Get dashboard summary
  Future<Map<String, dynamic>> getDashboardSummary() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'total_employees': 24,
      'total_projects': 12,
      'total_customers': 8,
      'total_hours': 1845.5,
      'active_projects': 8,
      'pending_timesheets': 6,
      'completed_projects': 4,
      'total_revenue': 125000.0,
      'monthly_growth': 15.2,
      'efficiency_rate': 92.5,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Get employee report
  Future<Map<String, dynamic>> getEmployeeReport({
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return {
      'total_hours': 168.5,
      'projects_worked': 3,
      'average_hours_per_day': 8.2,
      'timesheets_submitted': 12,
      'timesheets_approved': 10,
      'performance_score': 92.5,
      'productivity_trend': 'increasing',
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Get project report
  Future<Map<String, dynamic>> getProjectReport({
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return {
      'total_cost': 45000.0,
      'total_hours': 520.0,
      'team_size': 6,
      'completion_percentage': 75.5,
      'budget_utilization': 68.2,
      'estimated_completion': '2025-12-15',
      'status': 'on_track',
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Get timesheet report
  Future<Map<String, dynamic>> getTimesheetReport({
    String? employeeId,
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 550));

    return {
      'total_hours': 320.5,
      'submitted_count': 15,
      'approved_count': 12,
      'pending_count': 3,
      'average_hours_per_week': 40.0,
      'overtime_hours': 12.5,
      'efficiency_rate': 94.2,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Get monthly report
  Future<Map<String, dynamic>> getMonthlyReport({
    int? year,
    int? month,
  }) async {
    await Future.delayed(const Duration(milliseconds: 650));

    return {
      'total_hours': 1920.0,
      'total_projects': 8,
      'new_employees': 2,
      'completed_projects': 3,
      'total_revenue': 85000.0,
      'growth_rate': 12.5,
      'client_satisfaction': 4.7,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Get weekly report
  Future<Map<String, dynamic>> getWeeklyReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    return {
      'total_hours': 480.0,
      'active_projects': 6,
      'timesheets_submitted': 24,
      'timesheets_approved': 20,
      'average_productivity': 87.5,
      'team_availability': 92.0,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Export report
  Future<Map<String, dynamic>> exportReport({
    required String reportType,
    required String format, // 'pdf', 'excel', 'csv'
    Map<String, dynamic>? filters,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    return {
      'download_url':
          'https://example.com/reports/export_${DateTime.now().millisecondsSinceEpoch}.$format',
      'file_name':
          '${reportType}_report_${DateTime.now().toIso8601String().split('T')[0]}.$format',
      'file_size': '2.5 MB',
      'expiry_date':
          DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'status': 'ready',
    };
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalytics({
    String? metric,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return {
      'chart_data': [
        {'date': '2025-09-01', 'hours': 45.0, 'productivity': 85.0},
        {'date': '2025-09-02', 'hours': 52.0, 'productivity': 88.0},
        {'date': '2025-09-03', 'hours': 48.0, 'productivity': 92.0},
        {'date': '2025-09-04', 'hours': 55.0, 'productivity': 87.0},
        {'date': '2025-09-05', 'hours': 49.0, 'productivity': 91.0},
        {'date': '2025-09-06', 'hours': 46.0, 'productivity': 89.0},
        {'date': '2025-09-07', 'hours': 51.0, 'productivity': 93.0},
      ],
      'trends': {
        'productivity': 'increasing',
        'hours': 'stable',
        'efficiency': 'improving',
        'satisfaction': 'high',
      },
      'insights': [
        'Team productivity has increased by 8% this week',
        'Project completion rate is above target',
        'Client satisfaction scores are consistently high',
        'Time tracking compliance is at 95%',
      ],
      'recommendations': [
        'Consider expanding team capacity for Q4',
        'Implement new project management tools',
        'Schedule team training for advanced skills',
        'Review and optimize current workflows',
      ],
      'last_updated': DateTime.now().toIso8601String(),
    };
  }
}
