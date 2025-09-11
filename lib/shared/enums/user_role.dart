/// Enum representing user roles in the system
enum UserRole {
  /// Administrator with full access
  admin,

  /// Principal/Manager with project management capabilities
  principal,

  /// Regular employee
  employee
}

/// Extension methods for UserRole
extension UserRoleExtension on UserRole {
  /// Returns the display name of the user role
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.principal:
        return 'Principal';
      case UserRole.employee:
        return 'Employee';
    }
  }

  /// Returns whether this role can manage employees
  bool get canManageEmployees {
    return this == UserRole.admin || this == UserRole.principal;
  }

  /// Returns whether this role can manage projects
  bool get canManageProjects {
    return this == UserRole.admin || this == UserRole.principal;
  }

  /// Returns whether this role can manage customers
  bool get canManageCustomers {
    return this == UserRole.admin;
  }

  /// Returns whether this role can approve timesheets
  bool get canApproveTimesheets {
    return this == UserRole.admin || this == UserRole.principal;
  }

  /// Returns whether this role can view reports
  bool get canViewReports {
    return this == UserRole.admin || this == UserRole.principal;
  }
}
