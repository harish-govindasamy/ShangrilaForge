import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Personal settings section
          const SectionHeader(title: 'Personal Settings'),
          SettingsItem(
            icon: Icons.person_outline,
            title: 'My Profile',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRouter.profileRoute),
          ),
          SettingsItem(
            icon: Icons.password_outlined,
            title: 'Change Password',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRouter.passwordChangeRoute),
          ),
          SettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          SettingsItem(
            icon: Icons.language_outlined,
            title: 'Language',
            onTap: () {
              // Show language selector dialog
            },
          ),

          const Divider(height: 32),

          // Company settings section
          const SectionHeader(title: 'Company Settings'),
          SettingsItem(
            icon: Icons.business_outlined,
            title: 'Company Profile',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRouter.companySettingsRoute),
          ),
          SettingsItem(
            icon: Icons.people_outline,
            title: 'User Management',
            onTap: () {
              // Navigate to user management
            },
          ),
          SettingsItem(
            icon: Icons.category_outlined,
            title: 'Timesheet Categories',
            onTap: () {
              // Navigate to timesheet categories
            },
          ),

          const Divider(height: 32),

          // App settings section
          const SectionHeader(title: 'App Settings'),
          SettingsItem(
            icon: Icons.color_lens_outlined,
            title: 'Theme',
            onTap: () {
              // Show theme selector dialog
            },
          ),
          SettingsItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // Navigate to help & support
            },
          ),
          SettingsItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // Show about dialog
            },
          ),

          const Divider(height: 32),

          // Logout
          SettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              // Show logout confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Perform logout
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushReplacementNamed(AppRouter.loginRoute);
                      },
                      child: const Text('LOGOUT'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
