import 'package:flutter/material.dart';
import '../../shared/models/user_model.dart' hide UserRole;
import '../../shared/models/project_model.dart' hide ProjectStatus;
import '../../shared/models/employee_model.dart';
import '../../shared/models/timesheet_model.dart' hide TimesheetStatus;
import '../../shared/models/customer_model.dart';
import '../../shared/enums/user_role.dart';
import '../../shared/enums/project_status.dart';
import '../../shared/enums/timesheet_status.dart';
import '../navigation/app_router.dart';

/// A service class that handles the business logic and workflows
/// for the enterprise application.
class WorkflowService {
  // Singleton pattern
  static final WorkflowService _instance = WorkflowService._internal();

  factory WorkflowService() => _instance;

  WorkflowService._internal();

  /// Handles navigation based on user action in dashboard
  void navigateFromDashboardAction(BuildContext context, String action) {
    switch (action) {
      case 'add_employee':
        Navigator.pushNamed(context, AppRouter.employeeAddRoute);
        break;
      case 'view_employees':
        Navigator.pushNamed(context, AppRouter.employeesRoute);
        break;
      case 'create_project':
        Navigator.pushNamed(context, AppRouter.projectCreateRoute);
        break;
      case 'view_projects':
        Navigator.pushNamed(context, AppRouter.projectsRoute);
        break;
      case 'my_projects':
        Navigator.pushNamed(context, AppRouter.myProjectsRoute);
        break;
      case 'add_timesheet':
        Navigator.pushNamed(context, AppRouter.timesheetAddRoute);
        break;
      case 'view_timesheets':
        Navigator.pushNamed(context, AppRouter.timesheetsRoute);
        break;
      case 'approve_timesheets':
        Navigator.pushNamed(context, AppRouter.timesheetApproveRoute);
        break;
      case 'add_customer':
        Navigator.pushNamed(context, AppRouter.customerAddRoute);
        break;
      case 'view_customers':
        Navigator.pushNamed(context, AppRouter.customersRoute);
        break;
      case 'view_reports':
        Navigator.pushNamed(context, AppRouter.reportsRoute);
        break;
      case 'profile':
        Navigator.pushNamed(context, AppRouter.profileRoute);
        break;
      case 'settings':
        Navigator.pushNamed(context, AppRouter.settingsRoute);
        break;
      default:
        Navigator.pushNamed(context, AppRouter.dashboardRoute);
    }
  }

  /// Get available actions based on user role
  List<Map<String, dynamic>> getAvailableActionsForUser(UserRole role) {
    final List<Map<String, dynamic>> actions = [];

    // Common actions for all roles
    actions.addAll([
      {
        'id': 'my_projects',
        'title': 'My Projects',
        'icon': Icons.folder_special,
        'color': Colors.indigo,
      },
      {
        'id': 'add_timesheet',
        'title': 'Log Time',
        'icon': Icons.timer,
        'color': Colors.teal,
      },
      {
        'id': 'view_timesheets',
        'title': 'My Timesheets',
        'icon': Icons.access_time,
        'color': Colors.deepPurple,
      },
      {
        'id': 'profile',
        'title': 'Profile',
        'icon': Icons.person,
        'color': Colors.blueGrey,
      },
    ]);

    // Role-specific actions
    if (role == UserRole.admin) {
      actions.addAll([
        {
          'id': 'add_employee',
          'title': 'Add Employee',
          'icon': Icons.person_add,
          'color': Colors.green,
        },
        {
          'id': 'view_employees',
          'title': 'All Employees',
          'icon': Icons.people,
          'color': Colors.blue,
        },
        {
          'id': 'create_project',
          'title': 'New Project',
          'icon': Icons.add_box,
          'color': Colors.orange,
        },
        {
          'id': 'view_projects',
          'title': 'All Projects',
          'icon': Icons.folder,
          'color': Colors.amber,
        },
        {
          'id': 'add_customer',
          'title': 'Add Customer',
          'icon': Icons.business,
          'color': Colors.red,
        },
        {
          'id': 'view_customers',
          'title': 'Customers',
          'icon': Icons.contacts,
          'color': Colors.pink,
        },
        {
          'id': 'approve_timesheets',
          'title': 'Approve Time',
          'icon': Icons.check_circle,
          'color': Colors.cyan,
        },
        {
          'id': 'view_reports',
          'title': 'Reports',
          'icon': Icons.pie_chart,
          'color': Colors.deepOrange,
        },
        {
          'id': 'settings',
          'title': 'Settings',
          'icon': Icons.settings,
          'color': Colors.grey,
        },
      ]);
    } else if (role == UserRole.principal) {
      actions.addAll([
        {
          'id': 'view_employees',
          'title': 'All Employees',
          'icon': Icons.people,
          'color': Colors.blue,
        },
        {
          'id': 'create_project',
          'title': 'New Project',
          'icon': Icons.add_box,
          'color': Colors.orange,
        },
        {
          'id': 'view_projects',
          'title': 'All Projects',
          'icon': Icons.folder,
          'color': Colors.amber,
        },
        {
          'id': 'view_customers',
          'title': 'Customers',
          'icon': Icons.contacts,
          'color': Colors.pink,
        },
        {
          'id': 'approve_timesheets',
          'title': 'Approve Time',
          'icon': Icons.check_circle,
          'color': Colors.cyan,
        },
        {
          'id': 'view_reports',
          'title': 'Reports',
          'icon': Icons.pie_chart,
          'color': Colors.deepOrange,
        },
      ]);
    }

    return actions;
  }

  /// Handle timesheet workflow
  Future<bool> processTimesheetAction({
    required TimesheetModel timesheet,
    required String action,
    String? comment,
  }) async {
    switch (action) {
      case 'submit':
        timesheet.status = TimesheetStatus.submitted;
        timesheet.submittedDate = DateTime.now();
        return true;

      case 'approve':
        timesheet.status = TimesheetStatus.approved;
        timesheet.approvedDate = DateTime.now();
        if (comment != null && comment.isNotEmpty) {
          timesheet.comments = [
            ...timesheet.comments ?? [],
            {
              'date': DateTime.now().toIso8601String(),
              'text': comment,
              'type': 'approval'
            }
          ];
        }
        return true;

      case 'reject':
        timesheet.status = TimesheetStatus.rejected;
        if (comment != null && comment.isNotEmpty) {
          timesheet.comments = [
            ...timesheet.comments ?? [],
            {
              'date': DateTime.now().toIso8601String(),
              'text': comment,
              'type': 'rejection'
            }
          ];
        }
        return true;

      case 'revise':
        timesheet.status = TimesheetStatus.draft;
        if (comment != null && comment.isNotEmpty) {
          timesheet.comments = [
            ...timesheet.comments ?? [],
            {
              'date': DateTime.now().toIso8601String(),
              'text': comment,
              'type': 'revision'
            }
          ];
        }
        return true;

      default:
        return false;
    }
  }

  /// Handle project workflow
  Future<bool> processProjectAction({
    required ProjectModel project,
    required String action,
    String? comment,
  }) async {
    switch (action) {
      case 'start':
        project.status = ProjectStatus.inProgress;
        project.startDate = DateTime.now();
        return true;

      case 'complete':
        project.status = ProjectStatus.completed;
        project.endDate = DateTime.now();
        return true;

      case 'pause':
        project.status = ProjectStatus.onHold;
        if (comment != null && comment.isNotEmpty) {
          project.notes = [
            ...project.notes ?? [],
            {
              'date': DateTime.now().toIso8601String(),
              'text': comment,
              'type': 'pause'
            }
          ];
        }
        return true;

      case 'resume':
        project.status = ProjectStatus.inProgress;
        if (comment != null && comment.isNotEmpty) {
          project.notes = [
            ...project.notes ?? [],
            {
              'date': DateTime.now().toIso8601String(),
              'text': comment,
              'type': 'resume'
            }
          ];
        }
        return true;

      case 'cancel':
        project.status = ProjectStatus.cancelled;
        project.endDate = DateTime.now();
        if (comment != null && comment.isNotEmpty) {
          project.notes = [
            ...project.notes ?? [],
            {
              'date': DateTime.now().toIso8601String(),
              'text': comment,
              'type': 'cancellation'
            }
          ];
        }
        return true;

      default:
        return false;
    }
  }

  /// Handle employee assignment to project
  Future<bool> assignEmployeeToProject({
    required String employeeId,
    required String projectId,
    required String role,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // This would typically involve updating both the employee's projects
    // and the project's team members
    // For now, we're just returning true as a placeholder
    return true;
  }

  /// Check if user has permission for an action
  bool hasPermission(UserRole userRole, String action) {
    // Admin has all permissions
    if (userRole == UserRole.admin) return true;

    // Principal permissions
    if (userRole == UserRole.principal) {
      return [
        'view_employees',
        'view_employee_details',
        'create_project',
        'edit_project',
        'view_projects',
        'view_project_details',
        'assign_employees',
        'view_customers',
        'view_customer_details',
        'approve_timesheets',
        'view_timesheets',
        'view_reports',
        'my_projects',
        'add_timesheet',
        'edit_timesheet',
        'profile',
      ].contains(action);
    }

    // Employee permissions
    return [
      'view_projects',
      'view_project_details',
      'my_projects',
      'add_timesheet',
      'edit_timesheet',
      'view_timesheets',
      'profile',
    ].contains(action);
  }

  /// Get available reports based on user role
  List<Map<String, dynamic>> getAvailableReports(UserRole role) {
    final List<Map<String, dynamic>> reports = [];

    // Common reports for all roles
    reports.add({
      'id': 'my_time_summary',
      'title': 'My Time Summary',
      'description': 'Summary of your logged time across projects',
      'icon': Icons.access_time,
    });

    // Role-specific reports
    if (role == UserRole.admin || role == UserRole.principal) {
      reports.addAll([
        {
          'id': 'team_time_summary',
          'title': 'Team Time Summary',
          'description': 'Summary of time logged by team members',
          'icon': Icons.people,
        },
        {
          'id': 'project_time_report',
          'title': 'Project Time Report',
          'description': 'Time spent on each project',
          'icon': Icons.folder_open,
        },
        {
          'id': 'employee_productivity',
          'title': 'Employee Productivity',
          'description': 'Productivity metrics for employees',
          'icon': Icons.trending_up,
        },
      ]);
    }

    if (role == UserRole.admin) {
      reports.addAll([
        {
          'id': 'financial_summary',
          'title': 'Financial Summary',
          'description': 'Summary of project costs and revenue',
          'icon': Icons.attach_money,
        },
        {
          'id': 'customer_report',
          'title': 'Customer Report',
          'description': 'Projects and revenue by customer',
          'icon': Icons.business,
        },
      ]);
    }

    return reports;
  }

  /// Calculate project metrics
  Map<String, dynamic> calculateProjectMetrics(
      ProjectModel project, List<TimesheetModel> timesheets) {
    // Calculate total hours spent on the project
    double totalHours = 0;
    for (var timesheet in timesheets) {
      if (timesheet.projectId == project.id &&
          timesheet.status == TimesheetStatus.approved) {
        totalHours += timesheet.hours ?? 0;
      }
    }

    // Calculate progress percentage
    double progressPercentage = 0;
    if (project.estimatedHours != null && project.estimatedHours! > 0) {
      progressPercentage = (totalHours / project.estimatedHours!) * 100;
      // Cap at 100%
      progressPercentage = progressPercentage > 100 ? 100 : progressPercentage;
    }

    // Calculate remaining budget
    double? remainingBudget;
    if (project.budget != null) {
      // Simplified calculation - in reality, would need to account for rates
      remainingBudget =
          project.budget! - (totalHours * 100); // Assuming $100/hour
    }

    // Calculate days until deadline
    int? daysUntilDeadline;
    if (project.deadline != null) {
      daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
    }

    return {
      'totalHours': totalHours,
      'progressPercentage': progressPercentage,
      'remainingBudget': remainingBudget,
      'daysUntilDeadline': daysUntilDeadline,
      'isOnTrack': progressPercentage <= 100 &&
          (daysUntilDeadline == null || daysUntilDeadline > 0),
    };
  }

  /// Generate activity feed item
  Map<String, dynamic> generateActivityItem({
    required String type,
    required String userId,
    required String userName,
    String? targetId,
    String? targetName,
    String? action,
    DateTime? timestamp,
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'userId': userId,
      'userName': userName,
      'targetId': targetId,
      'targetName': targetName,
      'action': action,
      'timestamp': timestamp ?? DateTime.now(),
    };
  }
}
