/// Enum representing project priority levels
enum ProjectPriority {
  /// Low priority project
  low,

  /// Medium priority project
  medium,

  /// High priority project
  high,

  /// Critical priority project
  critical
}

/// Extension methods for ProjectPriority
extension ProjectPriorityExtension on ProjectPriority {
  /// Returns the display name of the project priority
  String get displayName {
    switch (this) {
      case ProjectPriority.low:
        return 'Low';
      case ProjectPriority.medium:
        return 'Medium';
      case ProjectPriority.high:
        return 'High';
      case ProjectPriority.critical:
        return 'Critical';
    }
  }

  /// Returns the color associated with this priority
  int get colorValue {
    switch (this) {
      case ProjectPriority.low:
        return 0xFF4CAF50; // Green
      case ProjectPriority.medium:
        return 0xFF2196F3; // Blue
      case ProjectPriority.high:
        return 0xFFFFC107; // Amber
      case ProjectPriority.critical:
        return 0xFFF44336; // Red
    }
  }

  /// Returns the numeric weight of this priority for sorting
  int get weight {
    switch (this) {
      case ProjectPriority.low:
        return 0;
      case ProjectPriority.medium:
        return 1;
      case ProjectPriority.high:
        return 2;
      case ProjectPriority.critical:
        return 3;
    }
  }
}
