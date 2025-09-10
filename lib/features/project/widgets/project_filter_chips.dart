import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../../../shared/models/project_model.dart';

class ProjectFilterChips extends StatefulWidget {
  const ProjectFilterChips({super.key});

  @override
  State<ProjectFilterChips> createState() => _ProjectFilterChipsState();
}

class _ProjectFilterChipsState extends State<ProjectFilterChips> {
  ProjectStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // All Projects Chip
              FilterChip(
                label: const Text('All'),
                selected: _selectedStatus == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = null;
                  });
                  projectProvider.loadProjects();
                },
                selectedColor: Colors.blue.withValues(alpha: 0.2),
                checkmarkColor: Colors.blue,
              ),

              const SizedBox(width: 8),

              // Status Filter Chips
              ...ProjectStatus.values.map((status) {
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
                        projectProvider.getProjectsByStatus(status);
                      } else {
                        projectProvider.loadProjects();
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
}
