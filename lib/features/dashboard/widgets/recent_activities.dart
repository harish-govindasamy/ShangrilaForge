import 'package:flutter/material.dart';
import '../../../core/services/service_provider.dart';
import '../../../core/navigation/app_router.dart';

class Activity {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final String? avatarUrl;
  final bool isUnread;

  Activity({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    this.avatarUrl,
    this.isUnread = false,
  });
}

class RecentActivitiesWidget extends StatefulWidget {
  const RecentActivitiesWidget({super.key});

  @override
  State<RecentActivitiesWidget> createState() => _RecentActivitiesWidgetState();
}

class _RecentActivitiesWidgetState extends State<RecentActivitiesWidget> {
  // Mock data for activities
  final List<Activity> _activities = [
    Activity(
      id: '1',
      icon: Icons.person_add,
      title: 'New employee added',
      subtitle: 'John Doe joined the team',
      time: '2 hours ago',
      color: Colors.green,
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      isUnread: true,
    ),
    Activity(
      id: '2',
      icon: Icons.work,
      title: 'Project completed',
      subtitle: 'Website Redesign project finished',
      time: '4 hours ago',
      color: Colors.blue,
      isUnread: true,
    ),
    Activity(
      id: '3',
      icon: Icons.access_time,
      title: 'Timesheet approved',
      subtitle: 'Sarah\'s weekly timesheet approved',
      time: '6 hours ago',
      color: Colors.orange,
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    Activity(
      id: '4',
      icon: Icons.analytics,
      title: 'Monthly report generated',
      subtitle: 'September 2024 report ready',
      time: '1 day ago',
      color: Colors.purple,
    ),
    Activity(
      id: '5',
      icon: Icons.chat,
      title: 'New comment on project',
      subtitle: 'Office Tower - Client feedback received',
      time: '1 day ago',
      color: Colors.teal,
    ),
    Activity(
      id: '6',
      icon: Icons.attach_money,
      title: 'Invoice paid',
      subtitle: 'Invoice #1234 paid by Client XYZ',
      time: '2 days ago',
      color: Colors.amber,
    ),
  ];

  // Number of activities to show initially
  int _displayCount = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: _showAllActivities,
              icon: const Icon(Icons.history, size: 18),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _buildActivityItems(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActivityItems() {
    List<Widget> activityWidgets = [];

    // Display limited activities
    final activitiesToDisplay = _activities.take(_displayCount).toList();

    for (int i = 0; i < activitiesToDisplay.length; i++) {
      activityWidgets.add(
        _buildActivityItem(activitiesToDisplay[i]),
      );

      // Add divider between items (but not after the last one)
      if (i < activitiesToDisplay.length - 1) {
        activityWidgets.add(const Divider(height: 1));
      }
    }

    // Add "Load More" button if there are more activities
    if (_displayCount < _activities.length) {
      activityWidgets.add(const Divider(height: 1));
      activityWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _displayCount = _activities.length;
                });
              },
              icon: const Icon(Icons.expand_more, size: 18),
              label: const Text('Load More'),
            ),
          ),
        ),
      );
    }

    return activityWidgets;
  }

  Widget _buildActivityItem(Activity activity) {
    return InkWell(
      onTap: () => _viewActivityDetails(activity),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Avatar or Icon Container
            activity.avatarUrl != null
                ? _buildAvatar(activity)
                : _buildIconContainer(activity),
            const SizedBox(width: 12),
            // Activity content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: activity.isUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (activity.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activity.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(Activity activity) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: activity.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        activity.icon,
        color: activity.color,
        size: 20,
      ),
    );
  }

  Widget _buildAvatar(Activity activity) {
    return CircleAvatar(
      radius: 18,
      backgroundImage: NetworkImage(activity.avatarUrl!),
      backgroundColor: activity.color.withOpacity(0.2),
    );
  }

  void _viewActivityDetails(Activity activity) {
    // Mark activity as read
    setState(() {
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = Activity(
          id: activity.id,
          icon: activity.icon,
          title: activity.title,
          subtitle: activity.subtitle,
          time: activity.time,
          color: activity.color,
          avatarUrl: activity.avatarUrl,
          isUnread: false,
        );
      }
    });

    // Show activity details dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.avatarUrl != null)
              Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(activity.avatarUrl!),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              activity.subtitle,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Timestamp: ${activity.time}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Activity ID: ${activity.id}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (_canTakeAction(activity))
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _takeActionOn(activity);
              },
              child: Text(_getActionText(activity)),
            ),
        ],
      ),
    );
  }

  // Determine if we can take action on this activity
  bool _canTakeAction(Activity activity) {
    return activity.icon == Icons.access_time ||
        activity.icon == Icons.work ||
        activity.icon == Icons.chat;
  }

  // Get action text based on activity type
  String _getActionText(Activity activity) {
    if (activity.icon == Icons.access_time) return 'View Timesheet';
    if (activity.icon == Icons.work) return 'View Project';
    if (activity.icon == Icons.chat) return 'Respond';
    return 'View Details';
  }

  // Take action based on activity type
  void _takeActionOn(Activity activity) {
<<<<<<< HEAD
    String route = '';
    String id = activity.id; // In a real app, this would be a meaningful ID

    if (activity.icon == Icons.access_time) {
      route = AppRouter.timesheetDetailRoute;
    } else if (activity.icon == Icons.work) {
      route = AppRouter.projectDetailRoute;
    } else if (activity.icon == Icons.chat) {
      route = AppRouter
          .projectDetailRoute; // Assuming comments are in project details
    } else if (activity.icon == Icons.person_add) {
      route = AppRouter.employeeDetailRoute;
    } else if (activity.icon == Icons.analytics) {
      route = AppRouter.reportsRoute;
    } else if (activity.icon == Icons.attach_money) {
      route = AppRouter.revenueRoute;
    } else {
      route = AppRouter.dashboardRoute;
    }

    // Navigate to the appropriate route with the ID
    Navigator.of(context).pushNamed(route, arguments: id);
=======
    String message = 'Navigating to ';

    if (activity.icon == Icons.access_time) {
      message += 'timesheet details...';
    } else if (activity.icon == Icons.work) {
      message += 'project details...';
    } else if (activity.icon == Icons.chat) {
      message += 'comments section...';
    } else {
      message += 'details page...';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
>>>>>>> fa182ade0bba8505d68c4b285e48c5684a4446f5
  }

  // Show all activities in a separate view
  void _showAllActivities() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: _activities.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _buildActivityItem(_activities[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
