import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/user_model.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.6,
              children: _getQuickActions(userRole, context),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getQuickActions(UserRole userRole, BuildContext context) {
    List<QuickAction> actions = [];

    switch (userRole) {
      case UserRole.admin:
        actions = [
          QuickAction(
            icon: Icons.person_add,
            title: 'Add Employee',
            color: Colors.green,
            onTap: () => _showComingSoon(context, 'Add Employee'),
          ),
          QuickAction(
            icon: Icons.work,
            title: 'Create Project',
            color: Colors.blue,
            onTap: () => _showComingSoon(context, 'Create Project'),
          ),
          QuickAction(
            icon: Icons.people,
            title: 'Manage Users',
            color: Colors.orange,
            onTap: () => _showComingSoon(context, 'Manage Users'),
          ),
          QuickAction(
            icon: Icons.analytics,
            title: 'View Reports',
            color: Colors.purple,
            onTap: () => _showComingSoon(context, 'View Reports'),
          ),
        ];
        break;
      case UserRole.principal:
        actions = [
          QuickAction(
            icon: Icons.work,
            title: 'Create Project',
            color: Colors.blue,
            onTap: () => _showComingSoon(context, 'Create Project'),
          ),
          QuickAction(
            icon: Icons.access_time,
            title: 'Approve Timesheets',
            color: Colors.green,
            onTap: () => _showComingSoon(context, 'Approve Timesheets'),
          ),
          QuickAction(
            icon: Icons.people,
            title: 'View Team',
            color: Colors.orange,
            onTap: () => _showComingSoon(context, 'View Team'),
          ),
          QuickAction(
            icon: Icons.analytics,
            title: 'Team Reports',
            color: Colors.purple,
            onTap: () => _showComingSoon(context, 'Team Reports'),
          ),
        ];
        break;
      case UserRole.employee:
        actions = [
          QuickAction(
            icon: Icons.access_time,
            title: 'Log Time',
            color: Colors.blue,
            onTap: () => _showComingSoon(context, 'Log Time'),
          ),
          QuickAction(
            icon: Icons.work,
            title: 'My Projects',
            color: Colors.green,
            onTap: () => _showComingSoon(context, 'My Projects'),
          ),
          QuickAction(
            icon: Icons.person,
            title: 'My Profile',
            color: Colors.orange,
            onTap: () => _showComingSoon(context, 'My Profile'),
          ),
          QuickAction(
            icon: Icons.history,
            title: 'Timesheet History',
            color: Colors.purple,
            onTap: () => _showComingSoon(context, 'Timesheet History'),
          ),
        ];
        break;
    }

    return actions.map((action) => _buildActionCard(action)).toList();
  }

  Widget _buildActionCard(QuickAction action) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                action.color.withValues(alpha: 0.1),
                action.color.withValues(alpha: 0.05),
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
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action.title,
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}
