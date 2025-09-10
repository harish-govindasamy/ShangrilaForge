import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_project_provider.dart';
import '../../../shared/models/project_model.dart';
import '../../../core/monitoring/analytics_service.dart';
import 'project_detail_screen.dart';
import 'project_form_screen.dart';
import '../widgets/project_card.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _sortBy = 'priority'; // priority, name, startDate, updatedAt

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EnhancedProjectProvider>();
      provider.loadProjects();
      provider.loadAnalytics();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Projects are already loaded and filtered, no pagination needed for now
    // This could be extended for server-side pagination
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EnhancedProjectProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadProjects(forceRefresh: true);
              await provider.loadAnalytics();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(context, provider),
                _buildStatisticsHeader(context, provider),
                if (provider.loadingState == ProjectLoadingState.loading &&
                    provider.projects.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.loadingState == ProjectLoadingState.error)
                  _buildErrorState(context, provider)
                else if (provider.projects.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildProjectList(context, provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
        heroTag: 'new_project_fab',
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, EnhancedProjectProvider provider) {
    return SliverAppBar(
      title: _showSearch
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search projects...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: provider.setSearchQuery,
            )
          : const Text('Projects'),
      floating: true,
      snap: true,
      actions: [
        IconButton(
          icon: Icon(_showSearch ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                provider.setSearchQuery('');
              }
            });
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (value) {
            setState(() {
              _sortBy = value;
            });
            _applySorting(provider);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'priority',
              child: Text('Sort by Priority'),
            ),
            const PopupMenuItem(
              value: 'name',
              child: Text('Sort by Name'),
            ),
            const PopupMenuItem(
              value: 'startDate',
              child: Text('Sort by Start Date'),
            ),
            const PopupMenuItem(
              value: 'updatedAt',
              child: Text('Sort by Updated'),
            ),
          ],
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          onSelected: (value) => _showFilterDialog(context, provider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'filter',
              child: Text('Filters'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsHeader(
      BuildContext context, EnhancedProjectProvider provider) {
    final theme = Theme.of(context);
    final analytics = provider.analytics;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Projects',
                        '${provider.totalActiveProjects + provider.totalArchivedProjects}',
                        Icons.folder,
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Active',
                        '${provider.totalActiveProjects}',
                        Icons.play_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Archived',
                        '${provider.totalArchivedProjects}',
                        Icons.archive,
                        Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Delayed',
                        '${provider.delayedProjects.length}',
                        Icons.warning,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressCard(
                        context,
                        'Total Hours',
                        '${provider.totalActiveHours.toStringAsFixed(1)}h',
                        provider.totalActiveHours,
                        analytics['totalHours']?.toDouble() ??
                            provider.totalActiveHours,
                        theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressCard(
                        context,
                        'Total Cost',
                        '\$${provider.totalActiveCost.toStringAsFixed(0)}',
                        provider.totalActiveCost,
                        analytics['totalCost']?.toDouble() ??
                            provider.totalActiveCost,
                        theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, String title, String value,
      double current, double total, Color color) {
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

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
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
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

  Widget _buildProjectList(
      BuildContext context, EnhancedProjectProvider provider) {
    final projects = _getSortedProjects(provider);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= projects.length) return null;

          final project = projects[index];
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: index == 0 ? 8.0 : 4.0,
            ),
            child: ProjectCard(
              project: project,
              onTap: () => _navigateToDetail(context, project),
              onEdit: () => _navigateToForm(context, project: project),
              onArchive: () => _showArchiveDialog(context, provider, project),
              onRestore: () => _showRestoreDialog(context, provider, project),
            ),
          );
        },
        childCount: projects.length,
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, EnhancedProjectProvider provider) {
    return SliverFillRemaining(
      child: Center(
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
              'Error loading projects',
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
              onPressed: () => provider.loadProjects(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No projects found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first project to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }

  List<Project> _getSortedProjects(EnhancedProjectProvider provider) {
    final projects = List<Project>.from(provider.projects);

    switch (_sortBy) {
      case 'name':
        projects.sort((a, b) => a.jobName.compareTo(b.jobName));
        break;
      case 'startDate':
        projects.sort((a, b) {
          if (a.startDate == null && b.startDate == null) return 0;
          if (a.startDate == null) return 1;
          if (b.startDate == null) return -1;
          return b.startDate!.compareTo(a.startDate!);
        });
        break;
      case 'updatedAt':
        projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'priority':
      default:
        // Default sorting already applied in provider
        break;
    }

    return projects;
  }

  void _applySorting(EnhancedProjectProvider provider) {
    // Trigger rebuild with new sorting
    setState(() {});
  }

  void _showFilterDialog(
      BuildContext context, EnhancedProjectProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Projects'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filter
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: provider.statusFilter == null,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setStatusFilter(null);
                            setDialogState(() {});
                          }
                        },
                      ),
                      ...ProjectStatus.values.map((status) => FilterChip(
                            label: Text(status.name),
                            selected: provider.statusFilter == status,
                            onSelected: (selected) {
                              provider
                                  .setStatusFilter(selected ? status : null);
                              setDialogState(() {});
                            },
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Priority Filter
                  Text(
                    'Priority',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: provider.priorityFilter == null,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setPriorityFilter(null);
                            setDialogState(() {});
                          }
                        },
                      ),
                      ...ProjectPriority.values.map((priority) => FilterChip(
                            label: Text(priority.name),
                            selected: provider.priorityFilter == priority,
                            onSelected: (selected) {
                              provider.setPriorityFilter(
                                  selected ? priority : null);
                              setDialogState(() {});
                            },
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Show Archived Toggle
                  SwitchListTile(
                    title: const Text('Show Archived'),
                    value: provider.showArchived,
                    onChanged: (value) {
                      provider.setShowArchived(value);
                      setDialogState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showArchiveDialog(
      BuildContext context, EnhancedProjectProvider provider, Project project) {
    final parentNavigator = Navigator.of(context);
    final parentMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Project'),
        content: Text('Are you sure you want to archive "${project.jobName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              parentNavigator.pop();
              final success = await provider.archiveProject(
                projectId: project.projectId,
                archivedBy: 'current_user', // TODO: Get from auth
              );
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
      BuildContext context, EnhancedProjectProvider provider, Project project) {
    final parentNavigator = Navigator.of(context);
    final parentMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Project'),
        content: Text('Are you sure you want to restore "${project.jobName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              parentNavigator.pop();
              final success = await provider.restoreProject(
                projectId: project.projectId,
                restoredBy: 'current_user', // TODO: Get from auth
              );
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

  void _navigateToDetail(BuildContext context, Project project) {
    AnalyticsService.trackEvent('project_detail_view', {
      'project_id': project.projectId,
      'source': 'list_screen',
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(projectId: project.projectId),
      ),
    );
  }

  void _navigateToForm(BuildContext context, {Project? project}) {
    AnalyticsService.trackEvent(
      project == null ? 'project_create_start' : 'project_edit_start',
      {
        if (project != null) 'project_id': project.projectId,
        'source': 'list_screen',
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectFormScreen(project: project),
      ),
    );
  }
}
