/// Enum representing timesheet status
enum TimesheetStatus {
  /// Draft timesheet that hasn't been submitted
  draft,

  /// Timesheet has been submitted for approval
  submitted,

  /// Timesheet has been approved
  approved,

  /// Timesheet has been rejected
  rejected
}

/// Extension methods for TimesheetStatus
extension TimesheetStatusExtension on TimesheetStatus {
  /// Returns the display name of the timesheet status
  String get displayName {
    switch (this) {
      case TimesheetStatus.draft:
        return 'Draft';
      case TimesheetStatus.submitted:
        return 'Submitted';
      case TimesheetStatus.approved:
        return 'Approved';
      case TimesheetStatus.rejected:
        return 'Rejected';
    }
  }

  /// Returns the color associated with this status
  int get colorValue {
    switch (this) {
      case TimesheetStatus.draft:
        return 0xFF9E9E9E; // Grey
      case TimesheetStatus.submitted:
        return 0xFF2196F3; // Blue
      case TimesheetStatus.approved:
        return 0xFF4CAF50; // Green
      case TimesheetStatus.rejected:
        return 0xFFF44336; // Red
    }
  }

  /// Returns whether the timesheet can be edited
  bool get canEdit {
    return this == TimesheetStatus.draft || this == TimesheetStatus.rejected;
  }

  /// Returns whether the timesheet is pending approval
  bool get isPending {
    return this == TimesheetStatus.submitted;
  }

  /// Returns whether the timesheet is finalized
  bool get isFinalized {
    return this == TimesheetStatus.approved;
  }
}
