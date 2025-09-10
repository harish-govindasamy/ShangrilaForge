// This file serves as a temporary bridge to maintain compatibility
// while transitioning from simple to enhanced providers.
// It redirects to the correct provider implementation.

export '../../providers/enhanced_project_provider.dart'
    show EnhancedProjectProvider;

// Mark as deprecated to encourage using the proper imports
@Deprecated('Use providers/enhanced_project_provider.dart directly instead')
class SimpleToEnhancedBridge {
  // This class is empty and just serves as a marker for the deprecation warning
}
