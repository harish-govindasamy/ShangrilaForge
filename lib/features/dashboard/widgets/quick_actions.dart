import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/service_provider.dart';
import '../../../core/services/workflow_service.dart';
import '../../../shared/enums/user_role.dart';
import '../../auth/providers/auth_provider.dart';

class QuickActionsWidget extends StatefulWidget {
  const QuickActionsWidget({super.key});

  @override
  State<QuickActionsWidget> createState() => _QuickActionsWidgetState();
}

class _QuickActionsWidgetState extends State<QuickActionsWidget> {
  // Store user preferences for visible actions
  final Map<String, bool> _userPreferences = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Convert UserRole from model to enum
        UserRole userRole;
        final role = authProvider.user?.role;

        if (role == null || role == UserRole.employee.toString()) {
          userRole = UserRole.employee;
        } else if (role == UserRole.principal.toString()) {
          userRole = UserRole.principal;
        } else if (role == UserRole.admin.toString()) {
          userRole = UserRole.admin;
        } else {
          userRole = UserRole.employee;
        }

        // Access the workflow service
        final workflowService = ServiceProvider.workflow(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showCustomizeDialog(context, userRole),
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Customize'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              // Responsive grid - adjust columns based on width
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              final childAspectRatio = constraints.maxWidth > 600 ? 1.0 : 0.85;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
                children: _getQuickActions(userRole, context, workflowService),
              );
            }),
          ],
        );
      },
    );
  }

  // Get actions to display based on user preferences or defaults
  List<Widget> _getQuickActions(UserRole userRole, BuildContext context,
      WorkflowService workflowService) {
    // Get all available actions for this role
    List<Map<String, dynamic>> allActions =
        workflowService.getAvailableActionsForUser(userRole);

    // If no preferences set yet, initialize with defaults (first 4 actions)
    if (_userPreferences.isEmpty) {
      for (var i = 0; i < allActions.length; i++) {
        _userPreferences[allActions[i]['id']] =
            i < 4; // First 4 are visible by default
      }
    }

    // Filter actions based on user preferences
    List<Map<String, dynamic>> visibleActions = allActions
        .where((action) => _userPreferences[action['id']] == true)
        .toList();

    // If somehow no actions are visible, show the first 4
    if (visibleActions.isEmpty) {
      visibleActions = allActions.take(4).toList();
    }

    return visibleActions
        .map((action) => _buildActionCard(action, context, workflowService))
        .toList();
  }

  Widget _buildActionCard(Map<String, dynamic> action, BuildContext context,
      WorkflowService workflowService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () =>
            workflowService.navigateFromDashboardAction(context, action['id']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                action['color'].withValues(alpha: 0.1),
                action['color'].withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action['icon'],
                  color: action['color'],
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show dialog to customize quick actions
  void _showCustomizeDialog(BuildContext context, UserRole userRole) {
    // Get workflow service
    final workflowService = ServiceProvider.workflow(context);

    // Get all available actions for this role
    final allActions = workflowService.getAvailableActionsForUser(userRole);

    // Create a map to track which actions are selected in the dialog
    // Initialize with current preferences
    Map<String, bool> dialogSelections = Map.from(_userPreferences);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Customize Quick Actions'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: allActions.map((action) {
                  return CheckboxListTile(
                    title: Text(action['title']),
                    secondary: Icon(action['icon'], color: action['color']),
                    value: dialogSelections[action['id']] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        dialogSelections[action['id']] = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Count selected actions
                  int selectedCount = dialogSelections.values
                      .where((isSelected) => isSelected)
                      .length;

                  // Ensure at least one action is selected
                  if (selectedCount == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one action'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Update preferences and refresh the widget
                  setState(() {
                    _userPreferences.clear();
                    _userPreferences.addAll(dialogSelections);
                  });

                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
