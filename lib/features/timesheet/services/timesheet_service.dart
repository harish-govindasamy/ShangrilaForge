import '../../../core/network/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/email_notification_service.dart';
import '../../../shared/models/timesheet_model.dart';
import '../../../shared/models/user_model.dart';
import '../../project/services/project_service.dart';

class TimesheetService {
  static final TimesheetService _instance = TimesheetService._internal();
  factory TimesheetService() => _instance;
  TimesheetService._internal();

  final ApiService _apiService = ApiService();
  final EmailNotificationService _emailService = EmailNotificationService();
  final ProjectService _projectService = ProjectService();

  // Get all timesheets (RBAC controlled)
  Future<List<Timesheet>> getTimesheets(
      {UserRole? userRole, String? userId}) async {
    try {
      Map<String, dynamic> queryParams = {};

      // Apply RBAC filters
      if (userRole == UserRole.employee && userId != null) {
        queryParams['employee_id'] = userId;
      }
      // Admin and Principal can see all timesheets

      final response = await _apiService.get(
        ApiEndpoints.timesheets,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['timesheets'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Timesheet.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch timesheets');
    } catch (e) {
      throw Exception('Error fetching timesheets: $e');
    }
  }

  // Get timesheet by ID with RBAC validation
  Future<Timesheet> getTimesheetById(String id,
      {UserRole? userRole, String? userId}) async {
    try {
      final response = await _apiService.get(ApiEndpoints.timesheetById(id));
      if (response.statusCode == 200) {
        final timesheet = Timesheet.fromJson(response.data);

        // RBAC validation
        if (userRole == UserRole.employee && timesheet.employeeId != userId) {
          throw Exception(
              'Access denied: You can only view your own timesheets');
        }

        return timesheet;
      }
      throw Exception('Failed to fetch timesheet');
    } catch (e) {
      throw Exception('Error fetching timesheet: $e');
    }
  }

  // Create new timesheet with project validation
  Future<Timesheet> createTimesheet(Timesheet timesheet) async {
    try {
      // Validate project accessibility for timesheet entry
      final project = await _projectService.getProjectById(timesheet.projectId);

      if (!project.isAccessibleForTimesheet) {
        throw Exception(
            'Cannot create timesheet for completed project: ${project.jobName}');
      }

      // Set initial status as draft
      final timesheetWithStatus = timesheet.copyWith(
        status: TimesheetStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _apiService.post(
        ApiEndpoints.createTimesheet,
        data: timesheetWithStatus.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Timesheet.fromJson(response.data);
      }
      throw Exception('Failed to create timesheet');
    } catch (e) {
      throw Exception('Error creating timesheet: $e');
    }
  }

  // Update timesheet with validation
  Future<Timesheet> updateTimesheet(String id, Timesheet timesheet,
      {UserRole? userRole, String? userId}) async {
    try {
      // Get current timesheet for validation
      final currentTimesheet =
          await getTimesheetById(id, userRole: userRole, userId: userId);

      // Check if timesheet can be updated
      if (currentTimesheet.status == TimesheetStatus.approved) {
        throw Exception('Cannot update approved timesheet');
      }

      // Employees can only update their own draft timesheets
      if (userRole == UserRole.employee) {
        if (currentTimesheet.employeeId != userId) {
          throw Exception(
              'Access denied: You can only update your own timesheets');
        }
        if (currentTimesheet.status != TimesheetStatus.draft) {
          throw Exception('Cannot update timesheet after submission');
        }
      }

      // Validate project accessibility
      final project = await _projectService.getProjectById(timesheet.projectId);
      if (!project.isAccessibleForTimesheet) {
        throw Exception(
            'Cannot update timesheet for completed project: ${project.jobName}');
      }

      final updatedTimesheet = timesheet.copyWith(
        updatedAt: DateTime.now(),
      );

      final response = await _apiService.put(
        ApiEndpoints.updateTimesheet(id),
        data: updatedTimesheet.toJson(),
      );

      if (response.statusCode == 200) {
        return Timesheet.fromJson(response.data);
      }
      throw Exception('Failed to update timesheet');
    } catch (e) {
      throw Exception('Error updating timesheet: $e');
    }
  }

  // Delete timesheet with RBAC validation
  Future<void> deleteTimesheet(String id,
      {UserRole? userRole, String? userId}) async {
    try {
      final timesheet =
          await getTimesheetById(id, userRole: userRole, userId: userId);

      // Validation rules
      if (userRole == UserRole.employee) {
        if (timesheet.employeeId != userId) {
          throw Exception(
              'Access denied: You can only delete your own timesheets');
        }
        if (timesheet.status != TimesheetStatus.draft) {
          throw Exception('Can only delete draft timesheets');
        }
      }

      final response =
          await _apiService.delete(ApiEndpoints.deleteTimesheet(id));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete timesheet');
      }
    } catch (e) {
      throw Exception('Error deleting timesheet: $e');
    }
  }

  // Submit timesheet for approval with Principal notification
  Future<Timesheet> submitTimesheet(String id, String employeeName,
      {UserRole? userRole, String? userId}) async {
    try {
      final timesheet =
          await getTimesheetById(id, userRole: userRole, userId: userId);

      // Validation
      if (userRole == UserRole.employee && timesheet.employeeId != userId) {
        throw Exception(
            'Access denied: You can only submit your own timesheets');
      }

      if (timesheet.status != TimesheetStatus.draft) {
        throw Exception('Can only submit draft timesheets');
      }

      // Validate total hours
      final totalHours = timesheet.getTotalHours();
      if (totalHours <= 0) {
        throw Exception('Cannot submit timesheet with no hours');
      }

      final response = await _apiService.post(
        ApiEndpoints.submitTimesheet,
        data: {
          'timesheet_id': id,
          'status': TimesheetStatus.submitted.name,
          'submittedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final submittedTimesheet = Timesheet.fromJson(response.data);

        // Send notification to Principal
        await _emailService.sendTimesheetSubmissionNotification(
          'principal@shangrilaengineers.com', // This should come from config
          employeeName,
          id,
        );

        return submittedTimesheet;
      }
      throw Exception('Failed to submit timesheet');
    } catch (e) {
      throw Exception('Error submitting timesheet: $e');
    }
  }

  // Approve timesheet (Principal only)
  Future<Timesheet> approveTimesheet(String id,
      {String? feedback, UserRole? userRole}) async {
    try {
      if (userRole != UserRole.principal && userRole != UserRole.admin) {
        throw Exception(
            'Access denied: Only Principals and Admins can approve timesheets');
      }

      final timesheet = await getTimesheetById(id);

      if (timesheet.status != TimesheetStatus.submitted) {
        throw Exception('Can only approve submitted timesheets');
      }

      final response = await _apiService.post(
        ApiEndpoints.approveTimesheet,
        data: {
          'timesheet_id': id,
          'status': TimesheetStatus.approved.name,
          'approvedAt': DateTime.now().toIso8601String(),
          'feedback': feedback ?? '',
        },
      );

      if (response.statusCode == 200) {
        final approvedTimesheet = Timesheet.fromJson(response.data);

        // Send approval notification to employee
        await _emailService.sendTimesheetStatusNotification(
          'employee@shangrilaengineers.com', // This should be the employee's email
          'approved',
          id,
          feedback,
        );

        return approvedTimesheet;
      }
      throw Exception('Failed to approve timesheet');
    } catch (e) {
      throw Exception('Error approving timesheet: $e');
    }
  }

  // Reject timesheet (Principal only)
  Future<Timesheet> rejectTimesheet(String id, String feedback,
      {UserRole? userRole}) async {
    try {
      if (userRole != UserRole.principal && userRole != UserRole.admin) {
        throw Exception(
            'Access denied: Only Principals and Admins can reject timesheets');
      }

      final timesheet = await getTimesheetById(id);

      if (timesheet.status != TimesheetStatus.submitted) {
        throw Exception('Can only reject submitted timesheets');
      }

      final response = await _apiService.post(
        ApiEndpoints.timesheets, // Adjust endpoint as needed
        data: {
          'timesheet_id': id,
          'status': TimesheetStatus.rejected.name,
          'rejectedAt': DateTime.now().toIso8601String(),
          'feedback': feedback,
        },
      );

      if (response.statusCode == 200) {
        final rejectedTimesheet = Timesheet.fromJson(response.data);

        // Send rejection notification to employee
        await _emailService.sendTimesheetStatusNotification(
          'employee@shangrilaengineers.com', // This should be the employee's email
          'rejected',
          id,
          feedback,
        );

        return rejectedTimesheet;
      }
      throw Exception('Failed to reject timesheet');
    } catch (e) {
      throw Exception('Error rejecting timesheet: $e');
    }
  }

  // Get timesheets by employee with RBAC
  Future<List<Timesheet>> getTimesheetsByEmployee(String employeeId,
      {UserRole? userRole, String? currentUserId}) async {
    try {
      // RBAC validation
      if (userRole == UserRole.employee && employeeId != currentUserId) {
        throw Exception('Access denied: You can only view your own timesheets');
      }

      final response = await _apiService.get(
        ApiEndpoints.timesheets,
        queryParameters: {'employee_id': employeeId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['timesheets'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Timesheet.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch employee timesheets');
    } catch (e) {
      throw Exception('Error fetching employee timesheets: $e');
    }
  }

  // Get timesheets by project
  Future<List<Timesheet>> getTimesheetsByProject(String projectId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.timesheets,
        queryParameters: {'project_id': projectId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['timesheets'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Timesheet.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch project timesheets');
    } catch (e) {
      throw Exception('Error fetching project timesheets: $e');
    }
  }

  // Get timesheets by status
  Future<List<Timesheet>> getTimesheetsByStatus(TimesheetStatus status) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.timesheets,
        queryParameters: {'status': status.name},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['timesheets'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Timesheet.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch timesheets by status');
    } catch (e) {
      throw Exception('Error fetching timesheets by status: $e');
    }
  }

  // Get pending approvals for Principals
  Future<List<Timesheet>> getPendingApprovals({UserRole? userRole}) async {
    try {
      if (userRole != UserRole.principal && userRole != UserRole.admin) {
        throw Exception(
            'Access denied: Only Principals and Admins can view pending approvals');
      }

      return await getTimesheetsByStatus(TimesheetStatus.submitted);
    } catch (e) {
      throw Exception('Error fetching pending approvals: $e');
    }
  }

  // Get timesheets by date range
  Future<List<Timesheet>> getTimesheetsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.timesheets,
        queryParameters: {
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Timesheet.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch timesheets by date range');
    } catch (e) {
      throw Exception('Error fetching timesheets by date range: $e');
    }
  }

  // Get timesheet statistics for reporting
  Future<Map<String, dynamic>> getTimesheetStatistics(
      {String? employeeId, String? projectId}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (projectId != null) queryParams['project_id'] = projectId;

      final timesheets = await getTimesheets();

      return {
        'total': timesheets.length,
        'draft':
            timesheets.where((t) => t.status == TimesheetStatus.draft).length,
        'submitted': timesheets
            .where((t) => t.status == TimesheetStatus.submitted)
            .length,
        'approved': timesheets
            .where((t) => t.status == TimesheetStatus.approved)
            .length,
        'rejected': timesheets
            .where((t) => t.status == TimesheetStatus.rejected)
            .length,
        'totalHours':
            timesheets.fold<double>(0, (sum, t) => sum + t.getTotalHours()),
      };
    } catch (e) {
      throw Exception('Error fetching timesheet statistics: $e');
    }
  }

  // Search timesheets
  Future<List<Timesheet>> searchTimesheets(String query) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.timesheets,
        queryParameters: {'search': query},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['timesheets'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Timesheet.fromJson(json)).toList();
      }
      throw Exception('Failed to search timesheets');
    } catch (e) {
      throw Exception('Error searching timesheets: $e');
    }
  }
}
