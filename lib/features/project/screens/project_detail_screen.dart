import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/enhanced_project_provider.dart';
import '../../../shared/models/project_model.dart';
import 'project_form_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EnhancedProjectProvider>();
      provider.selectProjectById(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          Consumer<EnhancedProjectProvider>(
            builder: (context, provider, child) {
              if (provider.selectedProject != null) {
                return PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleMenuAction(context, value, provider),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Project'),
                      ),
                    ),
                    if (provider.selectedProject?.isArchived == false)
                      const PopupMenuItem(
                        value: 'archive',
                        child: ListTile(
                          leading: Icon(Icons.archive),
                          title: Text('Archive Project'),
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'restore',
                        child: ListTile(
                          leading: Icon(Icons.restore),
                          title: Text('Restore Project'),
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<EnhancedProjectProvider>(
        builder: (context, provider, child) {
          if (provider.loadingState == ProjectLoadingState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.loadingState == ProjectLoadingState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading project details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadProjects(forceRefresh: true).then((_) {
                        provider.selectProjectById(widget.projectId);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final project = provider.selectedProject;
          if (project == null || project.projectId != widget.projectId) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Project not found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The requested project could not be found.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadProjects(forceRefresh: true);
              provider.selectProjectById(widget.projectId);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProjectHeader(context, project),
                  const SizedBox(height: 24),
                  _buildProjectDetails(context, project),
                  const SizedBox(height: 24),
                  _buildProgressSection(context, project),
                  const SizedBox(height: 24),
                  _buildJobCodeHistory(context, project),
                  const SizedBox(height: 24),
                  _buildAssignedEmployees(context, project),
                  const SizedBox(height: 24),
                  _buildProjectTags(context, project),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectHeader(BuildContext context, Project project) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.jobName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (project.isArchived)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ARCHIVED',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Job Code: $project.jobCode',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                project.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusChip(context, project.status),
                const SizedBox(width: 8),
                _buildPriorityChip(context, project.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ProjectStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context, ProjectPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getPriorityColor(priority)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(priority),
            size: 16,
            color: _getPriorityColor(priority),
          ),
          const SizedBox(width: 4),
          Text(
            _getPriorityText(priority),
            style: TextStyle(
              color: _getPriorityColor(priority),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetails(BuildContext context, Project project) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              'Customer ID',
              project.customerId,
              Icons.business,
            ),
            _buildDetailRow(
              context,
              'Created',
              DateFormat('MMM dd, yyyy').format(project.createdAt),
              Icons.calendar_today,
            ),
            _buildDetailRow(
              context,
              'Last Updated',
              DateFormat('MMM dd, yyyy').format(project.updatedAt),
              Icons.update,
            ),
            if (project.startDate != null)
              _buildDetailRow(
                context,
                'Start Date',
                DateFormat('MMM dd, yyyy').format(project.startDate!),
                Icons.play_arrow,
              ),
            if (project.endDate != null)
              _buildDetailRow(
                context,
                'End Date',
                DateFormat('MMM dd, yyyy').format(project.endDate!),
                Icons.stop,
              ),
            _buildDetailRow(
              context,
              'Created By',
              project.createdBy,
              Icons.person,
            ),
            _buildDetailRow(
              context,
              'Updated By',
              project.updatedBy,
              Icons.person_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final progress = project.progressPercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Tracking',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    context,
                    'Hours',
                    project.totalHours.toStringAsFixed(1),
                    '${project.estimatedHours.toStringAsFixed(1)} est.',
                    project.totalHours,
                    project.estimatedHours,
                    project.isOverBudget ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressCard(
                    context,
                    'Cost',
                    '\$${project.totalCost.toStringAsFixed(0)}',
                    'Budget tracking',
                    project.totalCost,
                    project.totalCost, // No budget estimate available
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Overall Progress: ${progress.toStringAsFixed(1)}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 100 ? Colors.red : Colors.blue,
              ),
            ),
            if (project.isOverBudget) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Project is over budget',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    String title,
    String current,
    String subtitle,
    double currentValue,
    double maxValue,
    Color color,
  ) {
    final progress =
        maxValue > 0 ? (currentValue / maxValue).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            current,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCodeHistory(BuildContext context, Project project) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Code History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (project.jobCodeHistory.isEmpty)
              Text(
                'No job code history available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              ...project.jobCodeHistory.reversed.map((history) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'v${history.version}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              history.jobCode,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Changed by ${history.changedBy} on ${DateFormat('MMM dd, yyyy').format(history.changedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (history.reason?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Reason: ${history.reason}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedEmployees(BuildContext context, Project project) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Assigned Employees',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${project.assignedEmployeeIds.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (project.assignedEmployeeIds.isEmpty)
              Text(
                'No employees assigned to this project',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: project.assignedEmployeeIds.map((employeeId) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue,
                          child: Text(
                            employeeId.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Employee: $employeeId', // TODO: Get actual employee name
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTags(BuildContext context, Project project) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (project.tags.isEmpty)
              Text(
                'No tags assigned',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: project.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, String action, EnhancedProjectProvider provider) {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ProjectFormScreen(project: provider.selectedProject),
          ),
        );
        break;
      case 'archive':
        _showArchiveDialog(context, provider);
        break;
      case 'restore':
        _showRestoreDialog(context, provider);
        break;
    }
  }

  void _showArchiveDialog(
      BuildContext context, EnhancedProjectProvider provider) {
    final parentContext = context;
    final project = provider.selectedProject!;
    final parentNavigator = Navigator.of(parentContext);
    final parentMessenger = ScaffoldMessenger.of(parentContext);
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive Project'),
        content: Text('Are you sure you want to archive "${project.jobName}"?'),
        actions: [
          TextButton(
            onPressed: () => parentNavigator.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              parentNavigator.pop();
              final success = await provider.archiveProject(
                projectId: project.projectId,
                archivedBy: 'current_user', // TODO: Get from auth
              );
              if (!mounted) return;
              if (success) {
                parentMessenger.showSnackBar(
                  const SnackBar(
                      content: Text('Project archived successfully')),
                );
              }
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(
      BuildContext context, EnhancedProjectProvider provider) {
    final parentContext = context;
    final project = provider.selectedProject!;
    final parentNavigator = Navigator.of(parentContext);
    final parentMessenger = ScaffoldMessenger.of(parentContext);
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore Project'),
        content: Text('Are you sure you want to restore "${project.jobName}"?'),
        actions: [
          TextButton(
            onPressed: () => parentNavigator.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              parentNavigator.pop();
              final success = await provider.restoreProject(
                projectId: project.projectId,
                restoredBy: 'current_user', // TODO: Get from auth
              );
              if (!mounted) return;
              if (success) {
                parentMessenger.showSnackBar(
                  const SnackBar(
                      content: Text('Project restored successfully')),
                );
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.open:
        return Colors.blue;
      case ProjectStatus.inProgress:
        return Colors.orange;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.completed:
        return Colors.blue;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.onHold:
        return Colors.amber;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.open:
        return 'Open';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.paused:
        return 'Paused';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.open:
        return Icons.folder_open;
      case ProjectStatus.inProgress:
        return Icons.work;
      case ProjectStatus.active:
        return Icons.play_circle;
      case ProjectStatus.completed:
        return Icons.check_circle;
      case ProjectStatus.paused:
        return Icons.pause_circle;
      case ProjectStatus.onHold:
        return Icons.hourglass_top;
      case ProjectStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getPriorityColor(ProjectPriority priority) {
    switch (priority) {
      case ProjectPriority.low:
        return Colors.grey;
      case ProjectPriority.medium:
        return Colors.blue;
      case ProjectPriority.high:
        return Colors.orange;
      case ProjectPriority.urgent:
        return Colors.red;
    }
  }

  String _getPriorityText(ProjectPriority priority) {
    switch (priority) {
      case ProjectPriority.low:
        return 'Low';
      case ProjectPriority.medium:
        return 'Medium';
      case ProjectPriority.high:
        return 'High';
      case ProjectPriority.urgent:
        return 'Urgent';
    }
  }

  IconData _getPriorityIcon(ProjectPriority priority) {
    switch (priority) {
      case ProjectPriority.low:
        return Icons.low_priority;
      case ProjectPriority.medium:
        return Icons.priority_high;
      case ProjectPriority.high:
        return Icons.priority_high;
      case ProjectPriority.urgent:
        return Icons.warning;
    }
  }
}
