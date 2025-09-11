import 'package:flutter/material.dart';
import '../services/workflow_service.dart';

/// A service locator class that provides access to all services
/// in the application.
class ServiceProvider extends InheritedWidget {
  /// The workflow service
  final WorkflowService workflowService;

  /// Constructs a new [ServiceProvider]
  const ServiceProvider({
    super.key,
    required super.child,
    required this.workflowService,
  });

  /// Returns the nearest [ServiceProvider] up the widget tree
  static ServiceProvider of(BuildContext context) {
    final ServiceProvider? result =
        context.dependOnInheritedWidgetOfExactType<ServiceProvider>();
    assert(result != null, 'No ServiceProvider found in context');
    return result!;
  }

  /// Returns the [WorkflowService] instance
  static WorkflowService workflow(BuildContext context) {
    return of(context).workflowService;
  }

  @override
  bool updateShouldNotify(ServiceProvider oldWidget) {
    return workflowService != oldWidget.workflowService;
  }

  /// Creates a new instance of [ServiceProvider] with all services initialized
  factory ServiceProvider.initialize({required Widget child}) {
    return ServiceProvider(
      workflowService: WorkflowService(),
      child: child,
    );
  }
}
