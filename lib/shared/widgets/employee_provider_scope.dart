import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/provider_factory.dart';
import '../../features/employee/providers/enhanced_employee_provider.dart'
    as employee;

/// This widget ensures that an EnhancedEmployeeProvider is available to all descendants
/// It acts as a scoped provider to avoid the "Provider not found" error
class EmployeeProviderScope extends StatelessWidget {
  final Widget child;

  const EmployeeProviderScope({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the provider is already available in the parent context
    try {
      Provider.of<employee.EnhancedEmployeeProvider>(context, listen: false);
      // If we reach here, the provider exists, so just return the child
      return child;
    } catch (_) {
      // Provider not found, so create a new one
      return ChangeNotifierProvider(
        create: (_) => ProviderFactory.createEnhancedEmployeeProvider(),
        child: child,
      );
    }
  }
}
