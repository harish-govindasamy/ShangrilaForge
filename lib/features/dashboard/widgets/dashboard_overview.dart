import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_router.dart';
import '../../../shared/enums/user_role.dart';
import '../../auth/providers/auth_provider.dart';

class StatCard {
  final String id;
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final bool isIncreasing;
  final String changePercentage;
  final VoidCallback? onTap;

  StatCard({
    required this.id,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.isIncreasing = true,
    this.changePercentage = '',
    this.onTap,
  });
}

class DashboardOverviewWidget extends StatefulWidget {
  const DashboardOverviewWidget({super.key});

  @override
  State<DashboardOverviewWidget> createState() =>
      _DashboardOverviewWidgetState();
}

class _DashboardOverviewWidgetState extends State<DashboardOverviewWidget> {
  bool _isLoading = false;
  DateTime _lastUpdated = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Convert UserRole from model to enum
        UserRole userRole;
        final role = authProvider.user?.role;

        if (role == null || role == UserRole.employee.name) {
          userRole = UserRole.employee;
        } else if (role == UserRole.principal.name) {
          userRole = UserRole.principal;
        } else if (role == UserRole.admin.name) {
          userRole = UserRole.admin;
        } else {
          userRole = UserRole.employee;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Refresh button
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh, size: 20),
                  onPressed: _isLoading ? null : _refreshData,
                  tooltip: 'Refresh data',
                ),
              ],
            ),
            if (!_isLoading) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Last updated: ${_getFormattedUpdateTime()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid - adjust columns based on width
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                final childAspectRatio =
                    constraints.maxWidth > 600 ? 1.2 : 0.85;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  children: _getOverviewCards(userRole)
                      .map((card) => _buildStatCard(card))
                      .toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Refresh the data
  void _refreshData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call with delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _lastUpdated = DateTime.now();
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dashboard data refreshed'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  // Format the last updated time
  String _getFormattedUpdateTime() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  List<StatCard> _getOverviewCards(UserRole userRole) {
    switch (userRole) {
      case UserRole.admin:
        return [
          StatCard(
            id: 'employees',
            title: 'Total Employees',
            value: '24',
            icon: Icons.people,
            color: Colors.blue,
            subtitle: '+2 this month',
            isIncreasing: true,
            changePercentage: '8%',
            onTap: () => _navigateToSection('employees'),
          ),
          StatCard(
            id: 'projects',
            title: 'Active Projects',
            value: '12',
            icon: Icons.work,
            color: Colors.green,
            subtitle: '3 completed',
            isIncreasing: true,
            changePercentage: '15%',
            onTap: () => _navigateToSection('projects'),
          ),
          StatCard(
            id: 'approvals',
            title: 'Pending Approvals',
            value: '8',
            icon: Icons.pending_actions,
            color: Colors.orange,
            subtitle: '2 urgent',
            isIncreasing: false,
            changePercentage: '25%',
            onTap: () => _navigateToSection('approvals'),
          ),
          StatCard(
            id: 'revenue',
            title: 'Total Revenue',
            value: '\$45,230',
            icon: Icons.attach_money,
            color: Colors.purple,
            subtitle: 'This month',
            isIncreasing: true,
            changePercentage: '12%',
            onTap: () => _navigateToSection('revenue'),
          ),
        ];
      case UserRole.principal:
        return [
          StatCard(
            id: 'team',
            title: 'Team Members',
            value: '8',
            icon: Icons.people,
            color: Colors.blue,
            subtitle: 'All active',
            onTap: () => _navigateToSection('team'),
          ),
          StatCard(
            id: 'projects',
            title: 'My Projects',
            value: '5',
            icon: Icons.work,
            color: Colors.green,
            subtitle: '2 in progress',
            onTap: () => _navigateToSection('projects'),
          ),
          StatCard(
            id: 'reviews',
            title: 'Pending Reviews',
            value: '6',
            icon: Icons.pending_actions,
            color: Colors.orange,
            subtitle: '3 overdue',
            isIncreasing: false,
            changePercentage: '50%',
            onTap: () => _navigateToSection('reviews'),
          ),
          StatCard(
            id: 'hours',
            title: 'Team Hours',
            value: '320',
            icon: Icons.access_time,
            color: Colors.purple,
            subtitle: 'This week',
            isIncreasing: true,
            changePercentage: '5%',
            onTap: () => _navigateToSection('hours'),
          ),
        ];
      case UserRole.employee:
        return [
          StatCard(
            id: 'projects',
            title: 'My Projects',
            value: '3',
            icon: Icons.work,
            color: Colors.blue,
            subtitle: '2 active',
            onTap: () => _navigateToSection('projects'),
          ),
          StatCard(
            id: 'hours',
            title: 'Hours This Week',
            value: '40',
            icon: Icons.access_time,
            color: Colors.green,
            subtitle: 'On track',
            isIncreasing: true,
            changePercentage: '100%',
            onTap: () => _navigateToSection('hours'),
          ),
          StatCard(
            id: 'timesheets',
            title: 'Pending Timesheets',
            value: '1',
            icon: Icons.pending_actions,
            color: Colors.orange,
            subtitle: 'Due tomorrow',
            isIncreasing: false,
            changePercentage: '0%',
            onTap: () => _navigateToSection('timesheets'),
          ),
          StatCard(
            id: 'total_hours',
            title: 'Total Hours',
            value: '1,240',
            icon: Icons.timer,
            color: Colors.purple,
            subtitle: 'This month',
            onTap: () => _navigateToSection('total_hours'),
          ),
        ];
    }
  }

  // Navigate to a specific section
  void _navigateToSection(String section) {
    // Map section to route
    String route = '';

    switch (section) {
      case 'employees':
        route = AppRouter.employeesRoute;
        break;
      case 'projects':
        route = AppRouter.projectsRoute;
        break;
      case 'approvals':
        route = AppRouter.approvalsRoute;
        break;
      case 'revenue':
        route = AppRouter.revenueRoute;
        break;
      case 'team':
        route = AppRouter.teamRoute;
        break;
      case 'reviews':
        route = AppRouter.reviewsRoute;
        break;
      case 'hours':
        route = AppRouter.hoursRoute;
        break;
      case 'timesheets':
        route = AppRouter.timesheetsRoute;
        break;
      case 'total_hours':
        route = AppRouter.totalHoursRoute;
        break;
      default:
        route = AppRouter.dashboardRoute;
    }

    // Navigate to the route
    Navigator.of(context).pushNamed(route);
  }

  Widget _buildStatCard(StatCard card) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: card.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                card.color.withAlpha(25),
                card.color.withAlpha(12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon and trend indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: card.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      card.icon,
                      color: card.color,
                      size: 20,
                    ),
                  ),
                  if (card.changePercentage.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          card.isIncreasing
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: card.isIncreasing ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          card.changePercentage,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                card.isIncreasing ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Value and labels
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.title,
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
                    card.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
