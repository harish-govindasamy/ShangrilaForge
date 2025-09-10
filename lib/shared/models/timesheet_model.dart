import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum TimesheetStatus { draft, submitted, approved, rejected }

class Timesheet extends Equatable {
  final String userId;
  final String employeeId;
  final String projectId;
  final String taskId;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double day1Hours;
  final double day2Hours;
  final double day3Hours;
  final double day4Hours;
  final double day5Hours;
  final double day6Hours;
  final double day7Hours;
  final double day8Hours;
  final double day9Hours;
  final double day10Hours;
  final double day11Hours;
  final double day12Hours;
  final double day13Hours;
  final double day14Hours;
  final double day15Hours;
  final double day16Hours;
  final TimesheetStatus status;
  final List<RecordTracking> recordTracking;

  const Timesheet({
    required this.userId,
    required this.employeeId,
    required this.projectId,
    required this.taskId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.day1Hours = 0.0,
    this.day2Hours = 0.0,
    this.day3Hours = 0.0,
    this.day4Hours = 0.0,
    this.day5Hours = 0.0,
    this.day6Hours = 0.0,
    this.day7Hours = 0.0,
    this.day8Hours = 0.0,
    this.day9Hours = 0.0,
    this.day10Hours = 0.0,
    this.day11Hours = 0.0,
    this.day12Hours = 0.0,
    this.day13Hours = 0.0,
    this.day14Hours = 0.0,
    this.day15Hours = 0.0,
    this.day16Hours = 0.0,
    this.status = TimesheetStatus.draft,
    this.recordTracking = const [],
  });

  factory Timesheet.fromJson(Map<String, dynamic> json) {
    return Timesheet(
      userId: json['user_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      projectId: json['project_id'] ?? '',
      taskId: json['task_id'] ?? '',
      weekStartDate: DateTime.parse(json['week_start_date']),
      weekEndDate: DateTime.parse(json['week_end_date']),
      createdBy: json['created_by'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      day1Hours: (json['day_1_hours'] ?? 0).toDouble(),
      day2Hours: (json['day_2_hours'] ?? 0).toDouble(),
      day3Hours: (json['day_3_hours'] ?? 0).toDouble(),
      day4Hours: (json['day_4_hours'] ?? 0).toDouble(),
      day5Hours: (json['day_5_hours'] ?? 0).toDouble(),
      day6Hours: (json['day_6_hours'] ?? 0).toDouble(),
      day7Hours: (json['day_7_hours'] ?? 0).toDouble(),
      day8Hours: (json['day_8_hours'] ?? 0).toDouble(),
      day9Hours: (json['day_9_hours'] ?? 0).toDouble(),
      day10Hours: (json['day_10_hours'] ?? 0).toDouble(),
      day11Hours: (json['day_11_hours'] ?? 0).toDouble(),
      day12Hours: (json['day_12_hours'] ?? 0).toDouble(),
      day13Hours: (json['day_13_hours'] ?? 0).toDouble(),
      day14Hours: (json['day_14_hours'] ?? 0).toDouble(),
      day15Hours: (json['day_15_hours'] ?? 0).toDouble(),
      day16Hours: (json['day_16_hours'] ?? 0).toDouble(),
      status: TimesheetStatus.values.firstWhere(
        (e) => e.name == json['status']?.toLowerCase(),
        orElse: () => TimesheetStatus.draft,
      ),
      recordTracking: (json['recordTracking'] as List<dynamic>?)
          ?.map((e) => RecordTracking.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'employee_id': employeeId,
      'project_id': projectId,
      'task_id': taskId,
      'week_start_date': weekStartDate.toIso8601String().split('T')[0],
      'week_end_date': weekEndDate.toIso8601String().split('T')[0],
      'created_by': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'day_1_hours': day1Hours,
      'day_2_hours': day2Hours,
      'day_3_hours': day3Hours,
      'day_4_hours': day4Hours,
      'day_5_hours': day5Hours,
      'day_6_hours': day6Hours,
      'day_7_hours': day7Hours,
      'day_8_hours': day8Hours,
      'day_9_hours': day9Hours,
      'day_10_hours': day10Hours,
      'day_11_hours': day11Hours,
      'day_12_hours': day12Hours,
      'day_13_hours': day13Hours,
      'day_14_hours': day14Hours,
      'day_15_hours': day15Hours,
      'day_16_hours': day16Hours,
      'status': status.name,
      'recordTracking': recordTracking.map((e) => e.toJson()).toList(),
    };
  }

  // Helper method to get daily hours as a list
  List<double> get dailyHours => [
        day1Hours,
        day2Hours,
        day3Hours,
        day4Hours,
        day5Hours,
        day6Hours,
        day7Hours,
        day8Hours,
        day9Hours,
        day10Hours,
        day11Hours,
        day12Hours,
        day13Hours,
        day14Hours,
        day15Hours,
        day16Hours,
      ];

  // Helper method to calculate total hours for the week
  double get totalHours => dailyHours.reduce((a, b) => a + b);
  
  // Method to get total hours (for compatibility with service calls)
  double getTotalHours() => totalHours;

  // Helper method to check if timesheet can be edited
  bool get canEdit => status == TimesheetStatus.draft || status == TimesheetStatus.submitted;

  // Helper method to check if timesheet is approved
  bool get isApproved => status == TimesheetStatus.approved;

  Timesheet copyWith({
    String? userId,
    String? employeeId,
    String? projectId,
    String? taskId,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? day1Hours,
    double? day2Hours,
    double? day3Hours,
    double? day4Hours,
    double? day5Hours,
    double? day6Hours,
    double? day7Hours,
    double? day8Hours,
    double? day9Hours,
    double? day10Hours,
    double? day11Hours,
    double? day12Hours,
    double? day13Hours,
    double? day14Hours,
    double? day15Hours,
    double? day16Hours,
    TimesheetStatus? status,
    List<RecordTracking>? recordTracking,
  }) {
    return Timesheet(
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      day1Hours: day1Hours ?? this.day1Hours,
      day2Hours: day2Hours ?? this.day2Hours,
      day3Hours: day3Hours ?? this.day3Hours,
      day4Hours: day4Hours ?? this.day4Hours,
      day5Hours: day5Hours ?? this.day5Hours,
      day6Hours: day6Hours ?? this.day6Hours,
      day7Hours: day7Hours ?? this.day7Hours,
      day8Hours: day8Hours ?? this.day8Hours,
      day9Hours: day9Hours ?? this.day9Hours,
      day10Hours: day10Hours ?? this.day10Hours,
      day11Hours: day11Hours ?? this.day11Hours,
      day12Hours: day12Hours ?? this.day12Hours,
      day13Hours: day13Hours ?? this.day13Hours,
      day14Hours: day14Hours ?? this.day14Hours,
      day15Hours: day15Hours ?? this.day15Hours,
      day16Hours: day16Hours ?? this.day16Hours,
      status: status ?? this.status,
      recordTracking: recordTracking ?? this.recordTracking,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        employeeId,
        projectId,
        taskId,
        weekStartDate,
        weekEndDate,
        createdBy,
        createdAt,
        updatedAt,
        day1Hours,
        day2Hours,
        day3Hours,
        day4Hours,
        day5Hours,
        day6Hours,
        day7Hours,
        day8Hours,
        day9Hours,
        day10Hours,
        day11Hours,
        day12Hours,
        day13Hours,
        day14Hours,
        day15Hours,
        day16Hours,
        status,
        recordTracking,
      ];
}
