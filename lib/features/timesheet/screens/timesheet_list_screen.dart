import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/timesheet_provider.dart';
import '../widgets/timesheet_card.dart';
import '../widgets/timesheet_search_bar.dart';
import '../widgets/timesheet_filter_chips.dart';
import 'add_timesheet_screen.dart';
import 'timesheet_detail_screen.dart';

class TimesheetListScreen extends StatefulWidget {
  const TimesheetListScreen({super.key});

  @override
  State<TimesheetListScreen> createState() => _TimesheetListScreenState();
}

class _TimesheetListScreenState extends State<TimesheetListScreen>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimesheets();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes back to foreground
      _loadTimesheets();
    }
  }

  void _loadTimesheets() {
    context.read<TimesheetProvider>().loadTimesheets();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 2), // Refresh every 2 minutes
      (timer) {
        if (mounted) {
          context.read<TimesheetProvider>().reloadTimesheets();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheets'),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.refresh,
                color: Color(0xFF2196F3),
              ),
            ),
            onPressed: () {
              _loadTimesheets();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Timesheets refreshed'),
                  backgroundColor: const Color(0xFF2196F3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF4CAF50),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddTimesheetScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.withValues(alpha: 0.05),
            child: const Column(
              children: [
                TimesheetSearchBar(),
                SizedBox(height: 12),
                TimesheetFilterChips(),
              ],
            ),
          ),

          // Timesheet List
          Expanded(
            child: Consumer<TimesheetProvider>(
              builder: (context, timesheetProvider, child) {
                if (timesheetProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (timesheetProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading timesheets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timesheetProvider.errorMessage!,
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            timesheetProvider.loadTimesheets();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final timesheets = timesheetProvider.getFilteredTimesheets();

                if (timesheets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 64,
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          timesheetProvider.searchQuery.isEmpty
                              ? 'No timesheets found'
                              : 'No timesheets match your search',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timesheetProvider.searchQuery.isEmpty
                              ? 'Add your first timesheet to get started'
                              : 'Try adjusting your search criteria',
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                        ),
                        if (timesheetProvider.searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddTimesheetScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Timesheet'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<TimesheetProvider>().loadTimesheets();
                  },
                  child: ListView.builder(
                    key: const ValueKey('timesheet_list'),
                    padding: const EdgeInsets.all(16),
                    itemCount: timesheets.length,
                    itemBuilder: (context, index) {
                      final timesheet = timesheets[index];
                      return TimesheetCard(
                        timesheet: timesheet,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TimesheetDetailScreen(
                                timesheetId: timesheet
                                    .userId, // Use userId as the timesheet identifier
                              ),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddTimesheetScreen(
                                timesheet: timesheet,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          _showDeleteConfirmation(context, timesheet);
                        },
                        onSubmit: () {
                          _showSubmitConfirmation(context, timesheet);
                        },
                        onApprove: () {
                          _showApproveConfirmation(context, timesheet);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_timesheet_fab",
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTimesheetScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, timesheet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Timesheet'),
        content: Text(
          'Are you sure you want to delete this timesheet for ${timesheet.weekStartDate} - ${timesheet.weekEndDate}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context
                  .read<TimesheetProvider>()
                  .deleteTimesheet(timesheet.userId);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Timesheet deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<TimesheetProvider>().errorMessage ??
                          'Failed to delete timesheet',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context, timesheet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Timesheet'),
        content: Text(
          'Are you sure you want to submit this timesheet for ${timesheet.weekStartDate} - ${timesheet.weekEndDate}? Once submitted, you cannot edit it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context
                  .read<TimesheetProvider>()
                  .submitTimesheet(timesheet.userId);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Timesheet submitted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the timesheet list to show updated status
                context.read<TimesheetProvider>().loadTimesheets();
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<TimesheetProvider>().errorMessage ??
                          'Failed to submit timesheet',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showApproveConfirmation(BuildContext context, timesheet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Timesheet'),
        content: Text(
          'Are you sure you want to approve this timesheet for ${timesheet.weekStartDate} - ${timesheet.weekEndDate}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context
                  .read<TimesheetProvider>()
                  .approveTimesheet(timesheet.userId);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Timesheet approved successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the timesheet list to show updated status
                context.read<TimesheetProvider>().loadTimesheets();
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<TimesheetProvider>().errorMessage ??
                          'Failed to approve timesheet',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }
}
