import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/timesheet_model.dart';

class TimesheetCard extends StatelessWidget {
  final Timesheet timesheet;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSubmit;
  final VoidCallback? onApprove;

  const TimesheetCard({
    super.key,
    required this.timesheet,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSubmit,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Timesheet Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(timesheet.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: _getStatusColor(timesheet.status),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Timesheet Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week of ${DateFormat('MMM dd').format(timesheet.weekStartDate)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM dd').format(timesheet.weekStartDate)} - ${DateFormat('MMM dd, yyyy').format(timesheet.weekEndDate)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(timesheet.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(timesheet.status),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Timesheet Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.access_time,
                      'Total Hours',
                      '${timesheet.totalHours.toStringAsFixed(1)}h',
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.work,
                      'Project',
                      'Project ID: ${timesheet.projectId.length > 8 ? '${timesheet.projectId.substring(0, 8)}...' : timesheet.projectId}',
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.task,
                      'Task',
                      'Task ID: ${timesheet.taskId.length > 8 ? '${timesheet.taskId.substring(0, 8)}...' : timesheet.taskId}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  // Submit Button (only for draft)
                  if (timesheet.status == TimesheetStatus.draft)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onSubmit,
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                  if (timesheet.status == TimesheetStatus.draft)
                    const SizedBox(width: 8),

                  // Approve Button (only for submitted)
                  if (timesheet.status == TimesheetStatus.submitted)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                  if (timesheet.status == TimesheetStatus.submitted)
                    const SizedBox(width: 8),

                  // Edit Button (only for draft)
                  if (timesheet.status == TimesheetStatus.draft)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),

                  if (timesheet.status == TimesheetStatus.draft)
                    const SizedBox(width: 8),

                  // More Actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.more_vert, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
}
