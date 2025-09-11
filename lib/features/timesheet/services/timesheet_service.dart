import 'dart:async';
import 'dart:math';
import 'package:logging/logging.dart';
import '../../../shared/models/timesheet_model.dart';

/// Mock timesheet service for demo purposes
/// This service provides mock data and simulates API operations
class TimesheetService {
  final Logger _logger = Logger('TimesheetService');
  final Random _random = Random();

  // Mock data storage
  static final List<Timesheet> _mockTimesheets = [];
  static bool _isInitialized = false;

  TimesheetService() {
    if (!_isInitialized) {
      _initializeMockData();
      _isInitialized = true;
    }
  }

  /// Initialize mock timesheet data
  void _initializeMockData() {
    final now = DateTime.now();
    final projects = [
      'PRJ-001',
      'PRJ-002',
      'PRJ-003',
      'PRJ-004',
      'PRJ-005',
      'PRJ-006',
      'PRJ-007',
      'PRJ-008',
      'PRJ-009',
      'PRJ-010'
    ];

    final employees = [
      'EMP-001',
      'EMP-002',
      'EMP-003',
      'EMP-004',
      'EMP-005',
      'EMP-006',
      'EMP-007',
      'EMP-008',
      'EMP-009',
      'EMP-010'
    ];

    final tasks = [
      'Development',
      'Testing',
      'Code Review',
      'Documentation',
      'Meeting',
      'Planning',
      'Design',
      'Research',
      'Bug Fixing',
      'Deployment'
    ];

    final creators = [
      'Admin',
      'HR Manager',
      'Project Manager',
      'Team Lead',
      'System'
    ];

    // Generate mock timesheets for the last 8 weeks (2 months)
    for (int i = 0; i < 30; i++) {
      final weekStart = now.subtract(Duration(days: (i * 7) + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final projectId = projects[_random.nextInt(projects.length)];
      final employeeId = employees[_random.nextInt(employees.length)];
      final taskId = tasks[_random.nextInt(tasks.length)];
      final createdBy = creators[_random.nextInt(creators.length)];

      // Generate random hours for each day (0-8 hours)
      final dailyHours = List.generate(16, (index) {
        // Some days will have 0 hours (weekend or days off)
        if (_random.nextInt(10) < 3) return 0.0;
        return _random.nextDouble() * 8;
      });

      // Random status distribution
      final statusRand = _random.nextInt(100);
      TimesheetStatus status;
      if (statusRand < 60) {
        status = TimesheetStatus.approved;
      } else if (statusRand < 80) {
        status = TimesheetStatus.submitted;
      } else if (statusRand < 90) {
        status = TimesheetStatus.draft;
      } else {
        status = TimesheetStatus.rejected;
      }

      final timesheet = Timesheet(
        userId: 'TS-${DateTime.now().millisecondsSinceEpoch}-$i',
        employeeId: employeeId,
        projectId: projectId,
        taskId: taskId,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        createdBy: createdBy,
        status: status,
        createdAt: weekStart.subtract(Duration(minutes: _random.nextInt(60))),
        updatedAt: weekStart.add(Duration(minutes: _random.nextInt(120))),
        day1Hours: dailyHours[0],
        day2Hours: dailyHours[1],
        day3Hours: dailyHours[2],
        day4Hours: dailyHours[3],
        day5Hours: dailyHours[4],
        day6Hours: dailyHours[5],
        day7Hours: dailyHours[6],
        day8Hours: dailyHours[7],
        day9Hours: dailyHours[8],
        day10Hours: dailyHours[9],
        day11Hours: dailyHours[10],
        day12Hours: dailyHours[11],
        day13Hours: dailyHours[12],
        day14Hours: dailyHours[13],
        day15Hours: dailyHours[14],
        day16Hours: dailyHours[15],
        recordTracking: [],
      );

      _mockTimesheets.add(timesheet);
    }

    _logger.info('Initialized ${_mockTimesheets.length} mock timesheets');
  }

  /// Get all timesheets with optional filters
  Future<List<Timesheet>> getTimesheets({
    String? employeeId,
    String? projectId,
    TimesheetStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _simulateNetworkDelay();

    try {
      List<Timesheet> filtered = List.from(_mockTimesheets);

      // Apply filters
      if (employeeId != null) {
        filtered = filtered.where((ts) => ts.employeeId == employeeId).toList();
      }

      if (projectId != null) {
        filtered = filtered.where((ts) => ts.projectId == projectId).toList();
      }

      if (status != null) {
        filtered = filtered.where((ts) => ts.status == status).toList();
      }

      if (startDate != null) {
        filtered = filtered
            .where((ts) => ts.weekStartDate
                .isAfter(startDate.subtract(const Duration(days: 1))))
            .toList();
      }

      if (endDate != null) {
        filtered = filtered
            .where((ts) =>
                ts.weekEndDate.isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      }

      // Sort by week start date (newest first)
      filtered.sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));

      _logger.info('Retrieved ${filtered.length} timesheets');
      return filtered;
    } catch (e) {
      _logger.severe('Failed to get timesheets: $e');
      throw Exception('Failed to load timesheets: $e');
    }
  }

  /// Get timesheet by ID
  Future<Timesheet> getTimesheetById(String id) async {
    await _simulateNetworkDelay();

    try {
      final timesheet = _mockTimesheets.firstWhere(
        (ts) => ts.userId == id,
        orElse: () => throw Exception('Timesheet not found'),
      );

      _logger.info('Retrieved timesheet: $id');
      return timesheet;
    } catch (e) {
      _logger.severe('Failed to get timesheet by ID: $e');
      throw Exception('Timesheet not found: $e');
    }
  }

  /// Create new timesheet
  Future<Timesheet> createTimesheet(Timesheet timesheet) async {
    await _simulateNetworkDelay();

    try {
      // Validate timesheet data
      _validateTimesheetData(timesheet);

      // Generate new ID and timestamps
      final newTimesheet = timesheet.copyWith(
        userId: 'TS-${DateTime.now().millisecondsSinceEpoch}',
        status: TimesheetStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _mockTimesheets.add(newTimesheet);
      _logger.info('Created timesheet: ${newTimesheet.userId}');

      return newTimesheet;
    } catch (e) {
      _logger.severe('Failed to create timesheet: $e');
      throw Exception('Failed to create timesheet: $e');
    }
  }

  /// Update existing timesheet
  Future<Timesheet> updateTimesheet(String id, Timesheet timesheet) async {
    await _simulateNetworkDelay();

    try {
      final index = _mockTimesheets.indexWhere((ts) => ts.userId == id);
      if (index == -1) {
        throw Exception('Timesheet not found');
      }

      // Validate timesheet data
      _validateTimesheetData(timesheet);

      // Check if user has permission to update
      final currentTimesheet = _mockTimesheets[index];
      if (!_canModifyTimesheet(currentTimesheet)) {
        throw Exception('Cannot modify timesheet in current status');
      }

      // Update timesheet
      final updatedTimesheet = timesheet.copyWith(
        userId: id,
        updatedAt: DateTime.now(),
      );

      _mockTimesheets[index] = updatedTimesheet;
      _logger.info('Updated timesheet: $id');

      return updatedTimesheet;
    } catch (e) {
      _logger.severe('Failed to update timesheet: $e');
      throw Exception('Failed to update timesheet: $e');
    }
  }

  /// Delete timesheet
  Future<bool> deleteTimesheet(String id) async {
    await _simulateNetworkDelay();

    try {
      final index = _mockTimesheets.indexWhere((ts) => ts.userId == id);
      if (index == -1) {
        throw Exception('Timesheet not found');
      }

      final timesheet = _mockTimesheets[index];
      if (!_canDeleteTimesheet(timesheet)) {
        throw Exception('Cannot delete timesheet in current status');
      }

      _mockTimesheets.removeAt(index);
      _logger.info('Deleted timesheet: $id');

      return true;
    } catch (e) {
      _logger.severe('Failed to delete timesheet: $e');
      throw Exception('Failed to delete timesheet: $e');
    }
  }

  /// Submit timesheet for approval
  Future<Timesheet> submitTimesheet(String id, String submittedBy) async {
    await _simulateNetworkDelay();

    try {
      final index = _mockTimesheets.indexWhere((ts) => ts.userId == id);
      if (index == -1) {
        throw Exception('Timesheet not found');
      }

      final timesheet = _mockTimesheets[index];
      if (timesheet.status != TimesheetStatus.draft) {
        throw Exception('Can only submit draft timesheets');
      }

      final updatedTimesheet = timesheet.copyWith(
        status: TimesheetStatus.submitted,
        updatedAt: DateTime.now(),
      );

      _mockTimesheets[index] = updatedTimesheet;
      _logger.info('Submitted timesheet: $id by $submittedBy');

      return updatedTimesheet;
    } catch (e) {
      _logger.severe('Failed to submit timesheet: $e');
      throw Exception('Failed to submit timesheet: $e');
    }
  }

  /// Approve timesheet
  Future<Timesheet> approveTimesheet(String id) async {
    await _simulateNetworkDelay();

    try {
      final index = _mockTimesheets.indexWhere((ts) => ts.userId == id);
      if (index == -1) {
        throw Exception('Timesheet not found');
      }

      final timesheet = _mockTimesheets[index];
      if (timesheet.status != TimesheetStatus.submitted) {
        throw Exception('Can only approve submitted timesheets');
      }

      final updatedTimesheet = timesheet.copyWith(
        status: TimesheetStatus.approved,
        updatedAt: DateTime.now(),
      );

      _mockTimesheets[index] = updatedTimesheet;
      _logger.info('Approved timesheet: $id');

      return updatedTimesheet;
    } catch (e) {
      _logger.severe('Failed to approve timesheet: $e');
      throw Exception('Failed to approve timesheet: $e');
    }
  }

  /// Reject timesheet
  Future<Timesheet> rejectTimesheet(String id, String feedback) async {
    await _simulateNetworkDelay();

    try {
      final index = _mockTimesheets.indexWhere((ts) => ts.userId == id);
      if (index == -1) {
        throw Exception('Timesheet not found');
      }

      final timesheet = _mockTimesheets[index];
      if (timesheet.status != TimesheetStatus.submitted) {
        throw Exception('Can only reject submitted timesheets');
      }

      final updatedTimesheet = timesheet.copyWith(
        status: TimesheetStatus.rejected,
        updatedAt: DateTime.now(),
      );

      _mockTimesheets[index] = updatedTimesheet;
      _logger.info('Rejected timesheet: $id with feedback: $feedback');

      return updatedTimesheet;
    } catch (e) {
      _logger.severe('Failed to reject timesheet: $e');
      throw Exception('Failed to reject timesheet: $e');
    }
  }

  /// Get timesheets by employee
  Future<List<Timesheet>> getTimesheetsByEmployee(String employeeId) async {
    return getTimesheets(employeeId: employeeId);
  }

  /// Get timesheets by project
  Future<List<Timesheet>> getTimesheetsByProject(String projectId) async {
    return getTimesheets(projectId: projectId);
  }

  /// Get timesheets by status
  Future<List<Timesheet>> getTimesheetsByStatus(TimesheetStatus status) async {
    return getTimesheets(status: status);
  }

  /// Get timesheets by date range
  Future<List<Timesheet>> getTimesheetsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return getTimesheets(startDate: startDate, endDate: endDate);
  }

  /// Get timesheet analytics
  Future<Map<String, dynamic>> getTimesheetAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _simulateNetworkDelay();

    try {
      final timesheets = await getTimesheets(
        startDate: startDate,
        endDate: endDate,
      );

      final totalHours = timesheets.fold<double>(
        0.0,
        (sum, ts) => sum + ts.totalHours,
      );

      final statusCounts = <TimesheetStatus, int>{};
      for (final status in TimesheetStatus.values) {
        statusCounts[status] =
            timesheets.where((ts) => ts.status == status).length;
      }

      final employeeHours = <String, double>{};
      for (final ts in timesheets) {
        employeeHours[ts.employeeId] =
            (employeeHours[ts.employeeId] ?? 0) + ts.totalHours;
      }

      final projectHours = <String, double>{};
      for (final ts in timesheets) {
        projectHours[ts.projectId] =
            (projectHours[ts.projectId] ?? 0) + ts.totalHours;
      }

      return {
        'totalHours': totalHours,
        'totalTimesheets': timesheets.length,
        'statusCounts': statusCounts,
        'employeeHours': employeeHours,
        'projectHours': projectHours,
        'averageHoursPerDay':
            timesheets.isNotEmpty ? totalHours / timesheets.length : 0.0,
      };
    } catch (e) {
      _logger.severe('Failed to get timesheet analytics: $e');
      throw Exception('Failed to get analytics: $e');
    }
  }

  /// Validate timesheet data
  void _validateTimesheetData(Timesheet timesheet) {
    if (timesheet.employeeId.isEmpty) {
      throw Exception('Employee ID is required');
    }

    if (timesheet.projectId.isEmpty) {
      throw Exception('Project ID is required');
    }

    if (timesheet.taskId.isEmpty) {
      throw Exception('Task ID is required');
    }

    if (timesheet.totalHours <= 0) {
      throw Exception('Total hours must be greater than 0');
    }

    if (timesheet.totalHours > 168) {
      // Max 168 hours per week (7 days * 24 hours)
      throw Exception('Total hours cannot exceed 168 hours per week');
    }

    if (timesheet.weekStartDate.isAfter(DateTime.now())) {
      throw Exception('Cannot create timesheet for future weeks');
    }

    // Validate daily hours (max 24 hours per day)
    for (final dayHours in timesheet.dailyHours) {
      if (dayHours > 24) {
        throw Exception('Daily hours cannot exceed 24 hours');
      }
    }
  }

  /// Check if timesheet can be modified
  bool _canModifyTimesheet(Timesheet timesheet) {
    // Can only modify draft and rejected timesheets
    return timesheet.status == TimesheetStatus.draft ||
        timesheet.status == TimesheetStatus.rejected;
  }

  /// Check if timesheet can be deleted
  bool _canDeleteTimesheet(Timesheet timesheet) {
    // Can only delete draft timesheets
    return timesheet.status == TimesheetStatus.draft;
  }

  /// Simulate network delay for realistic behavior
  Future<void> _simulateNetworkDelay() async {
    final delay = 200 + _random.nextInt(800); // 200-1000ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  /// Get mock timesheet count for testing
  int getMockTimesheetCount() => _mockTimesheets.length;

  /// Clear mock data (for testing)
  void clearMockData() {
    _mockTimesheets.clear();
    _isInitialized = false;
  }
}
