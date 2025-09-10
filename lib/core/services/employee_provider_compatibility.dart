// This file serves as a temporary bridge to maintain compatibility
// while transitioning from simple to enhanced employee providers.
// It redirects to the correct provider implementation.

export '../../features/employee/providers/enhanced_employee_provider.dart'
    show EnhancedEmployeeProvider;

// Mark as deprecated to encourage using the proper imports
@Deprecated(
    'Use features/employee/providers/enhanced_employee_provider.dart directly instead')
class SimpleToEnhancedBridge {
  // This class is empty and just serves as a marker for the deprecation warning
}
