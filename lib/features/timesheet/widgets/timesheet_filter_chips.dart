import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timesheet_provider.dart';
import '../../../shared/models/timesheet_model.dart';

class TimesheetFilterChips extends StatefulWidget {
  const TimesheetFilterChips({super.key});

  @override
  State<TimesheetFilterChips> createState() => _TimesheetFilterChipsState();
}

class _TimesheetFilterChipsState extends State<TimesheetFilterChips> {
  TimesheetStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Consumer<TimesheetProvider>(
      builder: (context, timesheetProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // All Timesheets Chip
              FilterChip(
                label: const Text('All'),
                selected: _selectedStatus == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = null;
                  });
                  // Clear search query and reload all timesheets
                  timesheetProvider.searchTimesheets('');
                  timesheetProvider.loadTimesheets();
                },
                selectedColor: Colors.blue.withValues(alpha: 0.2),
                checkmarkColor: Colors.blue,
              ),

              const SizedBox(width: 8),

              // Status Filter Chips
              ...TimesheetStatus.values.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getStatusText(status)),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : null;
                      });

                      if (selected) {
                        // Clear search and filter by status
                        timesheetProvider.getTimesheetsByStatus(status);
                      } else {
                        // Clear search query and reload all timesheets
                        timesheetProvider.searchTimesheets('');
                        timesheetProvider.loadTimesheets();
                      }
                    },
                    selectedColor:
                        _getStatusColor(status).withValues(alpha: 0.2),
                    checkmarkColor: _getStatusColor(status),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(TimesheetStatus status) {
    switch (status) {
      case TimesheetStatus.draft:
        return 'Draft';
      case TimesheetStatus.submitted:
        return 'Submitted';
      case TimesheetStatus.approved:
        return 'Approved';
      case TimesheetStatus.rejected:
        return 'Rejected';
    }
  }

  Color _getStatusColor(TimesheetStatus status) {
    switch (status) {
      case TimesheetStatus.draft:
        return Colors.grey;
      case TimesheetStatus.submitted:
        return Colors.orange;
      case TimesheetStatus.approved:
        return Colors.green;
      case TimesheetStatus.rejected:
        return Colors.red;
    }
  }
}
