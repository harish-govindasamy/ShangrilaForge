import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/navigation/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../employee/screens/employee_list_screen_wrapper.dart';
import '../../project/screens/project_list_screen_wrapper.dart';
import '../../timesheet/screens/timesheet_list_screen.dart';
import '../../timesheet/providers/timesheet_provider.dart';
import '../../customer/screens/customer_list_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../reports/providers/report_provider.dart';
import '../widgets/dashboard_overview.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_activities.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  Timer? _refreshTimer;

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const EmployeeListScreenWrapper(),
    const ProjectListScreenWrapper(),
    const TimesheetListScreen(),
    const CustomerListScreen(),
    const ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load data for all providers when the app starts
      context.read<TimesheetProvider>().loadTimesheets();
      context.read<ReportProvider>().loadDashboardSummary();
      _startPeriodicRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5), // Refresh every 5 minutes
      (timer) {
        if (mounted) {
          // Background refresh for real-time updates
          context.read<TimesheetProvider>().reloadTimesheets();
          context.read<ReportProvider>().loadDashboardSummary();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: const ValueKey('main_bottom_nav'),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey.withValues(alpha: 0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined,
                key: ValueKey('nav_dashboard_outline')),
            activeIcon:
                Icon(Icons.dashboard, key: ValueKey('nav_dashboard_active')),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.people_outline, key: ValueKey('nav_people_outline')),
            activeIcon: Icon(Icons.people, key: ValueKey('nav_people_active')),
            label: 'Employees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline, key: ValueKey('nav_work_outline')),
            activeIcon: Icon(Icons.work, key: ValueKey('nav_work_active')),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined,
                key: ValueKey('nav_time_outline')),
            activeIcon:
                Icon(Icons.access_time, key: ValueKey('nav_time_active')),
            label: 'Time',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.person_outline, key: ValueKey('nav_person_outline')),
            activeIcon: Icon(Icons.person, key: ValueKey('nav_person_active')),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined,
                key: ValueKey('nav_analytics_outline')),
            activeIcon:
                Icon(Icons.analytics, key: ValueKey('nav_analytics_active')),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.of(context).pushNamed(AppRouter.profileRoute);
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed(AppRouter.settingsRoute);
                  break;
                case 'logout':
                  _handleLogout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh dashboard data
            await context.read<TimesheetProvider>().loadTimesheets();
            await context.read<ReportProvider>().loadDashboardSummary();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dashboard refreshed'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF2196F3),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.user;
                    final employee = authProvider.employee;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  employee?.empName ?? user?.userName ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getRoleDisplayName(user?.role),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            child: Text(
                              employee != null && employee.empName.isNotEmpty
                                  ? employee.empName[0].toUpperCase()
                                  : (user != null && user.userName.isNotEmpty
                                      ? user.userName[0].toUpperCase()
                                      : 'U'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Summary Cards - Enhanced with Real-time Data
                Consumer<ReportProvider>(
                  builder: (context, reportProvider, child) {
                    final dashboardMetrics =
                        reportProvider.getDashboardMetrics();
                    final timesheetMetrics =
                        reportProvider.getTimesheetMetrics();

                    return _buildSummaryCards(
                      context,
                      dashboardMetrics,
                      timesheetMetrics,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Quick Actions
                const QuickActionsWidget(),

                const SizedBox(height: 24),

                // Dashboard Overview
                const DashboardOverviewWidget(),

                const SizedBox(height: 24),

                // Recent Activities
                const RecentActivitiesWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    Map<String, dynamic> dashboardMetrics,
    Map<String, dynamic> timesheetMetrics,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildEnhancedSummaryCard(
              title: 'Active Projects',
              value: '${dashboardMetrics['activeProjects'] ?? 8}',
              subtitle: '${dashboardMetrics['totalProjects'] ?? 12} total',
              icon: Icons.business,
              color: Colors.blue,
              trend: '+12%',
              isPositive: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildEnhancedSummaryCard(
              title: 'Pending Tasks',
              value: '${timesheetMetrics['pendingCount'] ?? 12}',
              subtitle: 'Need review',
              icon: Icons.assignment,
              color: Colors.orange,
              trend: '-5%',
              isPositive: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildEnhancedSummaryCard(
              title: 'Team Hours',
              value:
                  '${(timesheetMetrics['totalHours'] ?? 240.0).toStringAsFixed(0)}h',
              subtitle: 'This week',
              icon: Icons.access_time,
              color: Colors.green,
              trend: '+8%',
              isPositive: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(dynamic role) {
    switch (role?.toString()) {
      case 'UserRole.admin':
        return 'Administrator';
      case 'UserRole.principal':
        return 'Principal';
      case 'UserRole.employee':
        return 'Employee';
      default:
        return 'User';
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.loginRoute,
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens for other tabs
