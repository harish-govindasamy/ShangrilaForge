import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'login_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;

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
    });
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
        unselectedItemColor: Colors.grey[600],
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
              if (value == 'logout') {
                _handleLogout(context);
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dashboard refreshed'),
                duration: Duration(seconds: 1),
                backgroundColor: Color(0xFF2196F3),
              ),
            );
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
                            color: Colors.blue.withOpacity(0.2),
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
                                    color: Colors.white.withOpacity(0.9),
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
                                    color: Colors.white.withOpacity(0.2),
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
                            backgroundColor: Colors.white.withOpacity(0.2),
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

                // Summary Cards - Quick Overview
                _buildSummaryCards(context),

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

  Widget _buildSummaryCards(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Use responsive layout based on screen width
      final cardWidth = constraints.maxWidth > 600
          ? (constraints.maxWidth - 32) / 4
          : (constraints.maxWidth - 16) / 2;

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildSummaryCard(
            title: 'Today',
            value: '3',
            subtitle: 'Tasks',
            icon: Icons.task_alt,
            color: Colors.teal,
            width: cardWidth,
            onTap: () => _navigateToSection(context, 'tasks'),
          ),
          _buildSummaryCard(
            title: 'Projects',
            value: '12',
            subtitle: '2 due soon',
            icon: Icons.work,
            color: Colors.blue,
            width: cardWidth,
            onTap: () => _navigateToSection(context, 'projects'),
          ),
          _buildSummaryCard(
            title: 'Team',
            value: '24',
            subtitle: 'Members',
            icon: Icons.people,
            color: Colors.purple,
            width: cardWidth,
            onTap: () => _navigateToSection(context, 'employees'),
          ),
          _buildSummaryCard(
            title: 'Approvals',
            value: '5',
            subtitle: 'Pending',
            icon: Icons.approval,
            color: Colors.amber,
            width: cardWidth,
            onTap: () => _navigateToSection(context, 'approvals'),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double width,
    required VoidCallback onTap,
  }) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minWidth: 140),
      child: Card(
        elevation: 2,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: color, size: 28),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSection(BuildContext context, String section) {
    // Get parent scaffold to find bottom navigation
    final scaffoldState = Scaffold.of(context);

    // Show a notification about the navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $section section'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );

    // For actual navigation, we'd use Navigator or a state management solution
    // This is just a demonstration
    switch (section) {
      case 'tasks':
        // Example navigation
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TimesheetListScreen()),
        );
        break;
      case 'projects':
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => const ProjectListScreenWrapper()),
        );
        break;
      case 'employees':
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => const EmployeeListScreenWrapper()),
        );
        break;
      case 'approvals':
        // Show approvals dialog or navigate to approvals section
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pending Approvals'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildApprovalItem('Timesheet - John Smith', 'Sep 9, 2025',
                      Icons.access_time),
                  _buildApprovalItem('Expense Report - Jane Doe', 'Sep 8, 2025',
                      Icons.receipt),
                  _buildApprovalItem('Leave Request - Alex Wong',
                      'Sep 10, 2025', Icons.event_busy),
                  _buildApprovalItem('Project Milestone - Web Portal',
                      'Sep 7, 2025', Icons.flag),
                  _buildApprovalItem('Budget Approval - Marketing',
                      'Sep 5, 2025', Icons.account_balance),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
        break;
    }
  }

  Widget _buildApprovalItem(String title, String date, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(title),
      subtitle: Text('Due: $date'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
    );
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
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
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
