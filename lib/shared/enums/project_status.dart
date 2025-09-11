/// Enum representing project status
enum ProjectStatus {
  /// New project that hasn't started
  pending,

  /// Project is currently active
  inProgress,

  /// Project is temporarily paused
  onHold,

  /// Project has been completed
  completed,

  /// Project has been cancelled
  cancelled
}

/// Extension methods for ProjectStatus
extension ProjectStatusExtension on ProjectStatus {
  /// Returns the display name of the project status
  String get displayName {
    switch (this) {
      case ProjectStatus.pending:
        return 'Pending';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Returns the color associated with this status
  int get colorValue {
    switch (this) {
      case ProjectStatus.pending:
        return 0xFF9E9E9E; // Grey
      case ProjectStatus.inProgress:
        return 0xFF2196F3; // Blue
      case ProjectStatus.onHold:
        return 0xFFFFC107; // Amber
      case ProjectStatus.completed:
        return 0xFF4CAF50; // Green
      case ProjectStatus.cancelled:
        return 0xFFF44336; // Red
    }
  }

  /// Returns whether the project is active
  bool get isActive {
    return this == ProjectStatus.inProgress;
  }

  /// Returns whether the project is closed (completed or cancelled)
  bool get isClosed {
    return this == ProjectStatus.completed || this == ProjectStatus.cancelled;
  }
}
