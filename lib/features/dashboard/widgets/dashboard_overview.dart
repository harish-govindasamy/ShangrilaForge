import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/user_model.dart';

class DashboardOverviewWidget extends StatelessWidget {
  const DashboardOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
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
              children: _getOverviewCards(userRole),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getOverviewCards(UserRole userRole) {
    switch (userRole) {
      case UserRole.admin:
        return [
          _buildStatCard(
            'Total Employees',
            '24',
            Icons.people,
            Colors.blue,
            '+2 this month',
          ),
          _buildStatCard(
            'Active Projects',
            '12',
            Icons.work,
            Colors.green,
            '3 completed',
          ),
          _buildStatCard(
            'Pending Approvals',
            '8',
            Icons.pending_actions,
            Colors.orange,
            '2 urgent',
          ),
          _buildStatCard(
            'Total Revenue',
            '\$45,230',
            Icons.attach_money,
            Colors.purple,
            '+12% this month',
          ),
        ];
      case UserRole.principal:
        return [
          _buildStatCard(
            'Team Members',
            '8',
            Icons.people,
            Colors.blue,
            'All active',
          ),
          _buildStatCard(
            'My Projects',
            '5',
            Icons.work,
            Colors.green,
            '2 in progress',
          ),
          _buildStatCard(
            'Pending Reviews',
            '6',
            Icons.pending_actions,
            Colors.orange,
            '3 overdue',
          ),
          _buildStatCard(
            'Team Hours',
            '320',
            Icons.access_time,
            Colors.purple,
            'This week',
          ),
        ];
      case UserRole.employee:
        return [
          _buildStatCard(
            'My Projects',
            '3',
            Icons.work,
            Colors.blue,
            '2 active',
          ),
          _buildStatCard(
            'Hours This Week',
            '40',
            Icons.access_time,
            Colors.green,
            'On track',
          ),
          _buildStatCard(
            'Pending Timesheets',
            '1',
            Icons.pending_actions,
            Colors.orange,
            'Due tomorrow',
          ),
          _buildStatCard(
            'Total Hours',
            '1,240',
            Icons.timer,
            Colors.purple,
            'This month',
          ),
        ];
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1 * 255),
              color.withValues(alpha: 0.05 * 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1 * 255),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
