import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_employee_provider.dart';
import '../../../core/monitoring/analytics_service.dart';
import 'employee_detail_screen.dart';
import 'employee_form_screen.dart';
import '../widgets/enhanced_employee_card.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedEmployeeProvider>().loadEmployees();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search employees...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                onSubmitted: (query) {
                  _performSearch(query);
                },
              )
            : const Text('Employees'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  _searchController.clear();
                });
                context.read<EnhancedEmployeeProvider>().loadEmployees();
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = true;
                });
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'refresh':
                    context.read<EnhancedEmployeeProvider>().loadEmployees();
                    break;
                  case 'sort_name':
                    context
                        .read<EnhancedEmployeeProvider>()
                        .applySorting('empName');
                    break;
                  case 'sort_dept':
                    context
                        .read<EnhancedEmployeeProvider>()
                        .applySorting('department');
                    break;
                  case 'sort_exp':
                    context
                        .read<EnhancedEmployeeProvider>()
                        .applySorting('empExp');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'sort_name',
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha),
                      SizedBox(width: 8),
                      Text('Sort by Name'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sort_dept',
                  child: Row(
                    children: [
                      Icon(Icons.business),
                      SizedBox(width: 8),
                      Text('Sort by Department'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sort_exp',
                  child: Row(
                    children: [
                      Icon(Icons.timeline),
                      SizedBox(width: 8),
                      Text('Sort by Experience'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Consumer<EnhancedEmployeeProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.loadEmployees(),
            child: _buildBody(context, provider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final provider = context.read<EnhancedEmployeeProvider>();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeFormScreen(),
            ),
          );
          if (!mounted) return;
          if (result == true) {
            provider.loadEmployees();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
        heroTag: 'add_employee_fab',
      ),
    );
  }

  Widget _buildBody(BuildContext context, EnhancedEmployeeProvider provider) {
    if (provider.state == EmployeeState.loading && provider.employees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state == EmployeeState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load employees',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Please try again',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.loadEmployees(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'Start by adding your first employee',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployeeFormScreen(),
                  ),
                );
                if (!mounted) return;
                if (result == true) {
                  provider.loadEmployees();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Employee'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Statistics Header
        if (provider.employees.isNotEmpty) _buildStatsHeader(context, provider),

        // Employee List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.employees.length,
            itemBuilder: (context, index) {
              final employee = provider.employees[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: EnhancedEmployeeCard(
                  employee: employee,
                  onTap: () {
                    AnalyticsService.trackEvent('employee_card_tapped', {
                      'employee_id': employee.employeeId,
                      'employee_name': employee.empName,
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeDetailScreen(
                          employeeId: employee.employeeId,
                        ),
                      ),
                    );
                  },
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeFormScreen(
                          employee: employee,
                        ),
                      ),
                    );
                    if (!mounted) return;
                    if (result == true) {
                      provider.loadEmployees();
                    }
                  },
                  onDelete: () => _showDeleteConfirmation(context, employee),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(
      BuildContext context, EnhancedEmployeeProvider provider) {
    final theme = Theme.of(context);
    final employees = provider.employees;

    // Calculate basic statistics
    final totalEmployees = employees.length;
    final departments = employees.map((e) => e.department).toSet().length;
    final averageExp = employees.isNotEmpty
        ? employees.map((e) => e.empExp).reduce((a, b) => a + b) /
            employees.length
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  totalEmployees.toString(),
                  Icons.people,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Departments',
                  departments.toString(),
                  Icons.business,
                  theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Avg Exp',
                  '${averageExp.toStringAsFixed(1)}y',
                  Icons.timeline,
                  theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    context.read<EnhancedEmployeeProvider>().searchEmployees(query);
    AnalyticsService.trackEvent('employee_search', {
      'query': query,
      'query_length': query.length,
    });
  }

  void _showDeleteConfirmation(BuildContext context, dynamic employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.empName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<EnhancedEmployeeProvider>();
              final success =
                  await provider.deleteEmployee(employee.employeeId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Employee deleted successfully'
                          : 'Failed to delete employee',
                    ),
                    backgroundColor: success
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
