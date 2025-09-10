import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'user_model.dart';

enum ProjectStatus {
  open,
  inProgress,
  active,
  completed,
  paused,
  onHold,
  cancelled
}

enum ProjectPriority { low, medium, high, urgent }

class JobCodeHistory extends Equatable {
  final String jobCode;
  final DateTime changedAt;
  final String changedBy;
  final String? reason;
  final int version;

  const JobCodeHistory({
    required this.jobCode,
    required this.changedAt,
    required this.changedBy,
    this.reason,
    required this.version,
  });

  @override
  List<Object?> get props => [jobCode, changedAt, changedBy, reason, version];

  Map<String, dynamic> toJson() {
    return {
      'jobCode': jobCode,
      'changedAt': changedAt.toIso8601String(),
      'changedBy': changedBy,
      'reason': reason,
      'version': version,
    };
  }

  factory JobCodeHistory.fromJson(Map<String, dynamic> json) {
    return JobCodeHistory(
      jobCode: json['jobCode'] ?? '',
      changedAt:
          DateTime.parse(json['changedAt'] ?? DateTime.now().toIso8601String()),
      changedBy: json['changedBy'] ?? '',
      reason: json['reason'],
      version: json['version'] ?? 1,
    );
  }
}

class Project extends Equatable {
  final String projectId;
  final String jobName;
  final String customerId;
  final String jobCode;
  final String description;
  final double totalCost;
  final double totalHours;
  final double estimatedHours;
  final ProjectStatus status;
  final ProjectPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final String createdBy;
  final String updatedBy;
  final List<String> assignedEmployeeIds;
  final List<JobCodeHistory> jobCodeHistory;
  final bool isArchived;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final List<RecordTracking> recordTracking;

  const Project({
    required this.projectId,
    required this.jobName,
    required this.customerId,
    required this.jobCode,
    this.description = '',
    this.totalCost = 0.0,
    this.totalHours = 0.0,
    this.estimatedHours = 0.0,
    this.status = ProjectStatus.active,
    this.priority = ProjectPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.endDate,
    required this.createdBy,
    required this.updatedBy,
    this.assignedEmployeeIds = const [],
    this.jobCodeHistory = const [],
    this.isArchived = false,
    this.tags = const [],
    this.metadata = const {},
    this.recordTracking = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'] ?? '',
      jobName: json['job_name'] ?? '',
      customerId: json['customer_id'] ?? '',
      jobCode: json['job_code'] ?? '',
      description: json['description'] ?? '',
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      totalHours: (json['totalHours'] ?? 0).toDouble(),
      estimatedHours: (json['estimatedHours'] ?? 0).toDouble(),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status']?.toLowerCase().replaceAll('-', ''),
        orElse: () => ProjectStatus.active,
      ),
      priority: ProjectPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ProjectPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      assignedEmployeeIds: List<String>.from(json['assignedEmployeeIds'] ?? []),
      jobCodeHistory: (json['jobCodeHistory'] as List<dynamic>?)
              ?.map((h) => JobCodeHistory.fromJson(h))
              .toList() ??
          [],
      isArchived: json['isArchived'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      recordTracking: (json['recordTracking'] as List<dynamic>?)
              ?.map((e) => RecordTracking.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'job_name': jobName,
      'customer_id': customerId,
      'job_code': jobCode,
      'description': description,
      'totalCost': totalCost,
      'totalHours': totalHours,
      'estimatedHours': estimatedHours,
      'status': status.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'assignedEmployeeIds': assignedEmployeeIds,
      'jobCodeHistory': jobCodeHistory.map((h) => h.toJson()).toList(),
      'isArchived': isArchived,
      'tags': tags,
      'metadata': metadata,
      'recordTracking': recordTracking.map((e) => e.toJson()).toList(),
    };
  }

  Project copyWith({
    String? projectId,
    String? jobName,
    String? customerId,
    String? jobCode,
    String? description,
    double? totalCost,
    double? totalHours,
    double? estimatedHours,
    ProjectStatus? status,
    ProjectPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    String? updatedBy,
    List<String>? assignedEmployeeIds,
    List<JobCodeHistory>? jobCodeHistory,
    bool? isArchived,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    List<RecordTracking>? recordTracking,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      jobName: jobName ?? this.jobName,
      customerId: customerId ?? this.customerId,
      jobCode: jobCode ?? this.jobCode,
      description: description ?? this.description,
      totalCost: totalCost ?? this.totalCost,
      totalHours: totalHours ?? this.totalHours,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      assignedEmployeeIds: assignedEmployeeIds ?? this.assignedEmployeeIds,
      jobCodeHistory: jobCodeHistory ?? this.jobCodeHistory,
      isArchived: isArchived ?? this.isArchived,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      recordTracking: recordTracking ?? this.recordTracking,
    );
  }

  // Generate initial job code for new project based on customer code
  static String generateInitialJobCode(
      String customerCode, List<String> existingJobCodes) {
    // Customer code format: CUST001, CUST002, etc.
    // Project code format: 0001, 0002, etc. (for customer CUST001)

    // Extract customer number from customer code
    final customerNumber = customerCode.replaceAll(RegExp(r'[^0-9]'), '');
    final baseCode = customerNumber.padLeft(4, '0');

    // Find highest existing project number for this customer
    int highestNumber = 0;
    for (final existingCode in existingJobCodes) {
      if (existingCode.startsWith(baseCode)) {
        // Extract just the base part (before any version suffix)
        final basePart = existingCode.split('-')[0];
        if (basePart == baseCode) {
          highestNumber = math.max(highestNumber, int.tryParse(basePart) ?? 0);
        }
      }
    }

    // Generate next project code
    final nextNumber = (highestNumber + 1).toString().padLeft(4, '0');
    return nextNumber;
  }

  // Generate next version of job code for updates (0001 → 0001-A → 0001-B)
  String generateNextJobCodeVersion() {
    if (jobCode.isEmpty) return '0001';

    final parts = jobCode.split('-');
    if (parts.length == 1) {
      // First update, add version 'A'
      return '${parts[0]}-A';
    } else {
      // Increment version letter (A → B → C, etc.)
      final version = parts[1];
      if (version.length == 1 &&
          version.codeUnitAt(0) >= 65 &&
          version.codeUnitAt(0) < 90) {
        final nextVersion = String.fromCharCode(version.codeUnitAt(0) + 1);
        return '${parts[0]}-$nextVersion';
      } else {
        // Handle edge case: after Z, start with AA, AB, etc.
        return '${parts[0]}-AA';
      }
    }
  }

  // Check if job code is unique
  static bool isJobCodeUnique(String jobCode, List<String> existingJobCodes) {
    return !existingJobCodes.contains(jobCode);
  }

  // Helper method to check if project is accessible for timesheet entry
  bool get isAccessibleForTimesheet => status != ProjectStatus.completed;

  // Helper methods
  bool get isActive => status == ProjectStatus.active;
  bool get isCompleted => status == ProjectStatus.completed;
  bool get isPaused => status == ProjectStatus.paused;
  bool get isOnHold => status == ProjectStatus.onHold;
  bool get isCancelled => status == ProjectStatus.cancelled;

  double get progressPercentage {
    if (estimatedHours == 0) return 0.0;
    return (totalHours / estimatedHours * 100).clamp(0.0, 100.0);
  }

  bool get isOverBudget => estimatedHours > 0 && totalHours > estimatedHours;

  bool get canBeDeleted =>
      status != ProjectStatus.completed && status != ProjectStatus.active;

  String get statusDisplayName {
    switch (status) {
      case ProjectStatus.open:
        return 'Open';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.paused:
        return 'Paused';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case ProjectPriority.low:
        return 'Low';
      case ProjectPriority.medium:
        return 'Medium';
      case ProjectPriority.high:
        return 'High';
      case ProjectPriority.urgent:
        return 'Urgent';
    }
  }

  Color get statusColor {
    switch (status) {
      case ProjectStatus.open:
        return Colors.blue;
      case ProjectStatus.inProgress:
        return Colors.orange;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.completed:
        return Colors.blue;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.onHold:
        return Colors.amber;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case ProjectPriority.low:
        return Colors.grey;
      case ProjectPriority.medium:
        return Colors.blue;
      case ProjectPriority.high:
        return Colors.orange;
      case ProjectPriority.urgent:
        return Colors.red;
    }
  }

  JobCodeHistory? get latestJobCodeChange {
    if (jobCodeHistory.isEmpty) return null;
    return jobCodeHistory
        .reduce((a, b) => a.changedAt.isAfter(b.changedAt) ? a : b);
  }

  String generateNextJobCode({String prefix = 'JOB'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final version = jobCodeHistory.length + 1;
    return '$prefix-$timestamp-V$version';
  }

  @override
  List<Object?> get props => [
        projectId,
        jobName,
        customerId,
        jobCode,
        totalCost,
        totalHours,
        status,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        recordTracking,
      ];
}
