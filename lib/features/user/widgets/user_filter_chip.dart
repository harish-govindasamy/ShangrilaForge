import 'package:flutter/material.dart';
import '../../../shared/models/user_model.dart';

class UserFilterChip extends StatelessWidget {
  final UserRole? selectedRole;
  final Function(UserRole?) onRoleChanged;

  const UserFilterChip({
    super.key,
    this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: selectedRole == null,
          onSelected: (selected) {
            onRoleChanged(null); // Always set to null for "All"
          },
        ),
        FilterChip(
          label: const Text('Admin'),
          selected: selectedRole == UserRole.admin,
          onSelected: (selected) {
            onRoleChanged(selected ? UserRole.admin : null);
          },
        ),
        FilterChip(
          label: const Text('Principal'),
          selected: selectedRole == UserRole.principal,
          onSelected: (selected) {
            onRoleChanged(selected ? UserRole.principal : null);
          },
        ),
        FilterChip(
          label: const Text('Employee'),
          selected: selectedRole == UserRole.employee,
          onSelected: (selected) {
            onRoleChanged(selected ? UserRole.employee : null);
          },
        ),
      ],
    );
  }
}
