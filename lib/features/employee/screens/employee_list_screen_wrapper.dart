import 'package:flutter/material.dart';
import '../../../shared/widgets/employee_provider_scope.dart';
import 'employee_list_screen_new.dart';

/// A wrapper widget that ensures the EnhancedEmployeeListScreen always has
/// access to an EnhancedEmployeeProvider
class EmployeeListScreenWrapper extends StatelessWidget {
  const EmployeeListScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmployeeProviderScope(
      child: EnhancedEmployeeListScreen(),
    );
  }
}
