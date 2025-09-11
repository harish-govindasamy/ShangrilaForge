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
<<<<<<< HEAD
                children: _getQuickActions(userRole, context, workflowService),
=======
                children: _getQuickActions(userRole, context),
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
              );
            }),
          ],
        );
      },
    );
  }

<<<<<<< HEAD
  // Get actions to display based on user preferences or defaults
  List<Widget> _getQuickActions(UserRole userRole, BuildContext context,
      WorkflowService workflowService) {
    // Get all available actions for this role
    List<Map<String, dynamic>> allActions =
        workflowService.getAvailableActionsForUser(userRole);
=======
  // Get all available quick actions based on user role
  List<QuickAction> _getAllActions(UserRole userRole) {
    switch (userRole) {
      case UserRole.admin:
        return [
          QuickAction(
            id: 'add_employee',
            icon: Icons.person_add,
            title: 'Add Employee',
            color: Colors.green,
            onTap: (context) => _navigateTo(context, '/employees/add'),
          ),
          QuickAction(
            id: 'create_project',
            icon: Icons.work,
            title: 'Create Project',
            color: Colors.blue,
            onTap: (context) => _navigateTo(context, '/projects/create'),
          ),
          QuickAction(
            id: 'manage_users',
            icon: Icons.people,
            title: 'Manage Users',
            color: Colors.orange,
            onTap: (context) => _navigateTo(context, '/users'),
          ),
          QuickAction(
            id: 'view_reports',
            icon: Icons.analytics,
            title: 'View Reports',
            color: Colors.purple,
            onTap: (context) => _navigateTo(context, '/reports'),
          ),
          QuickAction(
            id: 'approve_timesheets',
            icon: Icons.approval,
            title: 'Approve Items',
            color: Colors.red,
            onTap: (context) => _showApprovalItems(context),
          ),
          QuickAction(
            id: 'company_settings',
            icon: Icons.business,
            title: 'Company Settings',
            color: Colors.teal,
            onTap: (context) => _navigateTo(context, '/settings/company'),
          ),
        ];
      case UserRole.principal:
        return [
          QuickAction(
            id: 'create_project',
            icon: Icons.work,
            title: 'Create Project',
            color: Colors.blue,
            onTap: (context) => _navigateTo(context, '/projects/create'),
          ),
          QuickAction(
            id: 'approve_timesheets',
            icon: Icons.access_time,
            title: 'Approve Timesheets',
            color: Colors.green,
            onTap: (context) => _navigateTo(context, '/timesheets/approve'),
          ),
          QuickAction(
            id: 'view_team',
            icon: Icons.people,
            title: 'View Team',
            color: Colors.orange,
            onTap: (context) => _navigateTo(context, '/team'),
          ),
          QuickAction(
            id: 'team_reports',
            icon: Icons.analytics,
            title: 'Team Reports',
            color: Colors.purple,
            onTap: (context) => _navigateTo(context, '/reports/team'),
          ),
          QuickAction(
            id: 'client_management',
            icon: Icons.business,
            title: 'Client Management',
            color: Colors.teal,
            onTap: (context) => _navigateTo(context, '/clients'),
          ),
        ];
      case UserRole.employee:
        return [
          QuickAction(
            id: 'log_time',
            icon: Icons.access_time,
            title: 'Log Time',
            color: Colors.blue,
            onTap: (context) => _navigateTo(context, '/timesheets/log'),
          ),
          QuickAction(
            id: 'my_projects',
            icon: Icons.work,
            title: 'My Projects',
            color: Colors.green,
            onTap: (context) => _navigateTo(context, '/projects/my'),
          ),
          QuickAction(
            id: 'my_profile',
            icon: Icons.person,
            title: 'My Profile',
            color: Colors.orange,
            onTap: (context) => _navigateTo(context, '/profile'),
          ),
          QuickAction(
            id: 'timesheet_history',
            icon: Icons.history,
            title: 'Timesheet History',
            color: Colors.purple,
            onTap: (context) => _navigateTo(context, '/timesheets/history'),
          ),
          QuickAction(
            id: 'expense_reports',
            icon: Icons.receipt,
            title: 'Expense Reports',
            color: Colors.amber,
            onTap: (context) => _navigateTo(context, '/expenses'),
          ),
        ];
    }
  }

  // Get actions to display based on user preferences or defaults
  List<Widget> _getQuickActions(UserRole userRole, BuildContext context) {
    // Get all available actions for this role
    List<QuickAction> allActions = _getAllActions(userRole);
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5

    // If no preferences set yet, initialize with defaults (first 4 actions)
    if (_userPreferences.isEmpty) {
      for (var i = 0; i < allActions.length; i++) {
<<<<<<< HEAD
        _userPreferences[allActions[i]['id']] =
=======
        _userPreferences[allActions[i].id] =
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
            i < 4; // First 4 are visible by default
      }
    }

    // Filter actions based on user preferences
<<<<<<< HEAD
    List<Map<String, dynamic>> visibleActions = allActions
        .where((action) => _userPreferences[action['id']] == true)
=======
    List<QuickAction> visibleActions = allActions
        .where((action) => _userPreferences[action.id] == true)
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
        .toList();

    // If somehow no actions are visible, show the first 4
    if (visibleActions.isEmpty) {
      visibleActions = allActions.take(4).toList();
    }

<<<<<<< HEAD
    return visibleActions
        .map((action) => _buildActionCard(action, context, workflowService))
        .toList();
=======
    return visibleActions.map((action) => _buildActionCard(action)).toList();
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
  }

  Widget _buildActionCard(Map<String, dynamic> action, BuildContext context,
      WorkflowService workflowService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
<<<<<<< HEAD
        onTap: () =>
            workflowService.navigateFromDashboardAction(context, action['id']),
=======
        onTap: () => action.onTap(context),
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
<<<<<<< HEAD
                action['color'].withOpacity(0.1),
                action['color'].withOpacity(0.05),
=======
                action.color.withOpacity(0.1),
                action.color.withOpacity(0.05),
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
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
<<<<<<< HEAD
                  color: action['color'].withOpacity(0.1),
=======
                  color: action.color.withOpacity(0.1),
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
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
                  color: Colors.grey[800],
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
<<<<<<< HEAD
    // Get workflow service
    final workflowService = ServiceProvider.workflow(context);

    // Get all available actions for this role
    final allActions = workflowService.getAvailableActionsForUser(userRole);
=======
    // Get all available actions for this role
    final allActions = _getAllActions(userRole);
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5

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
<<<<<<< HEAD
                    title: Text(action['title']),
                    secondary: Icon(action['icon'], color: action['color']),
                    value: dialogSelections[action['id']] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        dialogSelections[action['id']] = value ?? false;
=======
                    title: Text(action.title),
                    secondary: Icon(action.icon, color: action.color),
                    value: dialogSelections[action.id] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        dialogSelections[action.id] = value ?? false;
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
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
<<<<<<< HEAD
=======
      ),
    );
  }

  // Navigation helper
  void _navigateTo(BuildContext context, String route) {
    if (_isRouteImplemented(route)) {
      Navigator.of(context).pushNamed(route);
    } else {
      _showComingSoon(context, route.split('/').last.replaceAll('_', ' '));
    }
  }

  // Check if route is implemented
  bool _isRouteImplemented(String route) {
    // List of implemented routes - update as routes are implemented
    List<String> implementedRoutes = [
      '/profile',
      '/projects/create',
      '/projects/my',
    ];
    return implementedRoutes.contains(route);
  }

  // Show approval items dialog
  void _showApprovalItems(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Items Requiring Approval'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              _buildApprovalItem(
                context,
                'Timesheet - John Smith',
                'Week of May 15-21, 2023',
                Icons.access_time,
                Colors.blue,
              ),
              _buildApprovalItem(
                context,
                'Expense Report - Sarah Johnson',
                'Client Meeting - \$425.00',
                Icons.receipt,
                Colors.green,
              ),
              _buildApprovalItem(
                context,
                'Project Proposal - Office Tower',
                'Requires review by May 30',
                Icons.description,
                Colors.orange,
              ),
              _buildApprovalItem(
                context,
                'Leave Request - Michael Chen',
                'June 5-9, 2023 - Vacation',
                Icons.event,
                Colors.purple,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Build individual approval item
  Widget _buildApprovalItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                _showSuccessMessage(context, '$title approved');
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _showSuccessMessage(context, '$title rejected');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show coming soon message
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show success message
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
      ),
    );
  }
}
<<<<<<< HEAD
=======

class QuickAction {
  final String id;
  final IconData icon;
  final String title;
  final Color color;
  final Function(BuildContext) onTap;

  QuickAction({
    required this.id,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
