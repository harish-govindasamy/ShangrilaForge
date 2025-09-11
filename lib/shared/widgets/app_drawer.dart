import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/models/user_model.dart';
import '../../core/navigation/app_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: Column(
        children: [
          _buildHeader(context, user),
          Expanded(
            child: _buildMenuItems(context, user),
          ),
          _buildLogoutButton(context, authProvider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return UserAccountsDrawerHeader(
      accountName: Text(user?.userName ?? 'User'),
      accountEmail: Text('Employee ID: ${user?.employeeId ?? 'N/A'}'),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Text(
          user?.userName.isNotEmpty == true
              ? user!.userName.substring(0, 1).toUpperCase()
              : 'U',
          style: const TextStyle(fontSize: 24.0),
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, User? user) {
    // Default menu items for all users
    final List<Widget> menuItems = [
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, AppRouter.dashboardRoute);
        },
      ),
      ListTile(
        leading: const Icon(Icons.timer),
        title: const Text('Timesheets'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRouter.timesheetsRoute);
        },
      ),
    ];

    // Role-specific menu items
    if (user != null) {
      final bool isAdmin = user.role == UserRole.admin;
      final bool isPrincipal = user.role == UserRole.principal;

      if (isAdmin || isPrincipal) {
        menuItems.addAll([
          const Divider(),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Projects'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.projectsRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Employees'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.employeesRoute);
            },
          ),
        ]);
      }

      if (isAdmin) {
        menuItems.addAll([
          ListTile(
            leading: const Icon(Icons.person_pin),
            title: const Text('Customers'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.customersRoute);
            },
          ),
        ]);
      }

      if (isAdmin || isPrincipal) {
        menuItems.addAll([
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.reportsRoute);
            },
          ),
        ]);
      }
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: menuItems,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SafeArea(
        child: ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Logout'),
          onTap: () async {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.loginRoute,
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }
}
