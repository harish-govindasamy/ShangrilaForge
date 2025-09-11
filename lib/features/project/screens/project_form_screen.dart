import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/models/project_model.dart';
import '../../../shared/models/employee_model.dart';
import '../../../providers/enhanced_project_provider.dart';
import '../../../features/employee/providers/enhanced_employee_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;

  const ProjectFormScreen({
    super.key,
    this.project,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobNameController = TextEditingController();
  final _jobCodeController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedHoursController = TextEditingController();

  ProjectStatus _selectedStatus = ProjectStatus.active;
  ProjectPriority _selectedPriority = ProjectPriority.medium;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _tags = [];
  final List<String> _assignedEmployeeIds = [];

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final project = widget.project!;
    _jobNameController.text = project.jobName;
    _jobCodeController.text = project.jobCode;
    _customerIdController.text = project.customerId;
    _descriptionController.text = project.description;
    _estimatedHoursController.text = project.estimatedHours.toString();
    _selectedStatus = project.status;
    _selectedPriority = project.priority;
    _startDate = project.startDate;
    _endDate = project.endDate;
    _tags.addAll(project.tags);
    _assignedEmployeeIds.addAll(project.assignedEmployeeIds);
  }

  @override
  void dispose() {
    _jobNameController.dispose();
    _jobCodeController.dispose();
    _customerIdController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Project' : 'Create Project'),
        actions: [
          TextButton(
            onPressed: _saveProject,
            child: Text(_isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(theme),
              const SizedBox(height: 24),
              _buildStatusPrioritySection(theme),
              const SizedBox(height: 24),
              _buildDatesSection(theme),
              const SizedBox(height: 24),
              _buildTagsSection(theme),
              const SizedBox(height: 24),
              _buildEmployeeSection(theme),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jobNameController,
              decoration: const InputDecoration(
                labelText: 'Project Name *',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Project name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jobCodeController,
              decoration: const InputDecoration(
                labelText: 'Job Code *',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Job code is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerIdController,
              decoration: const InputDecoration(
                labelText: 'Customer ID *',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Customer ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estimatedHoursController,
              decoration: const InputDecoration(
                labelText: 'Estimated Hours',
                border: OutlineInputBorder(),
                suffixText: 'hrs',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final hours = double.tryParse(value);
                  if (hours == null || hours < 0) {
                    return 'Enter valid hours';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPrioritySection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status & Priority',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ProjectStatus>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isExpanded: true, // Important to prevent overflow
                    items: ProjectStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Use minimum space
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              size: 16,
                              color: _getStatusColor(status),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _getStatusText(status),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<ProjectPriority>(
                    initialValue: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isExpanded: true, // Important to prevent overflow
                    items: ProjectPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Use minimum space
                          children: [
                            Icon(
                              _getPriorityIcon(priority),
                              size: 16,
                              color: _getPriorityColor(priority),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _getPriorityText(priority),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Timeline',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                        // Ensure content padding is appropriate
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      // Force child to respect the constraints of its parent
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _startDate != null
                              ? _formatDate(_startDate!)
                              : 'Select date',
                          style: TextStyle(
                            color: _startDate != null
                                ? theme.textTheme.bodyLarge?.color
                                : theme.hintColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                        // Ensure content padding is appropriate
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      // Force child to respect the constraints of its parent
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _endDate != null
                              ? _formatDate(_endDate!)
                              : 'Select date',
                          style: TextStyle(
                            color: _endDate != null
                                ? theme.textTheme.bodyLarge?.color
                                : theme.hintColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Tags',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showAddTagDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tag'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tags.isEmpty)
              Text(
                'No tags added',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _tags.map((tag) {
                  return Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelStyle: const TextStyle(fontSize: 12), // Smaller font
                    label: Text(
                      tag,
                      overflow: TextOverflow.ellipsis,
                    ),
                    deleteIcon:
                        const Icon(Icons.close, size: 16), // Smaller icon
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                    visualDensity: VisualDensity.compact, // More compact layout
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Assigned Employees',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showAssignEmployeeDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Assign'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_assignedEmployeeIds.isEmpty)
              Text(
                'No employees assigned',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              Wrap(
                spacing: 6, // Reduced spacing
                runSpacing: 6, // Reduced spacing
                children: _assignedEmployeeIds.map((employeeId) {
                  final employeeProvider =
                      context.watch<EnhancedEmployeeProvider>();
                  final employee = employeeProvider.employees.firstWhere(
                    (emp) => emp.employeeId == employeeId,
                    orElse: () => Employee(
                      empName: 'Unknown Employee',
                      empEmail: '',
                      empDob: DateTime.now(),
                      empAddress: '',
                      empDesignation: '',
                      empBgp: '',
                      empCmob: '',
                      bankAccount: '',
                      ifscCode: '',
                      uniqueIdentificationNumber: '',
                      ssnNo: '',
                      emergencyName: '',
                      emergencyRelation: '',
                      emergencyPhone: '',
                      employeeId: employeeId,
                      userId: '',
                      firstName: '',
                      lastName: '',
                      empCode: '',
                      email: '',
                      department: '',
                      gender: '',
                      maritalStatus: '',
                      city: '',
                      state: '',
                      country: '',
                      postalCode: '',
                    ),
                  );

                  return Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    avatar: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 12, // Smaller radius
                      child: Text(
                        employee.empName.isNotEmpty
                            ? employee.empName.substring(0, 1).toUpperCase()
                            : employeeId.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10, // Smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    labelStyle: const TextStyle(fontSize: 12), // Smaller font
                    label: Text(
                      employee.empName.isNotEmpty
                          ? employee.empName
                          : 'Emp: $employeeId',
                      overflow: TextOverflow.ellipsis,
                    ),
                    deleteIcon:
                        const Icon(Icons.close, size: 16), // Smaller icon
                    onDeleted: () {
                      setState(() {
                        _assignedEmployeeIds.remove(employeeId);
                      });
                    },
                    visualDensity: VisualDensity.compact, // More compact layout
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveProject,
            child: Text(_isEditing ? 'Update Project' : 'Create Project'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2030);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // If end date is before start date, clear it
          if (_endDate != null && _endDate!.isBefore(pickedDate)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tag name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() {
                  _tags.add(tag);
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAssignEmployeeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Employee'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Employee ID',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final employeeId = controller.text.trim();
              if (employeeId.isNotEmpty &&
                  !_assignedEmployeeIds.contains(employeeId)) {
                setState(() {
                  _assignedEmployeeIds.add(employeeId);
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate date logic
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = context.read<EnhancedProjectProvider>();

    try {
      if (_isEditing) {
        final authProvider = context.read<AuthProvider>();
        final currentUserId = authProvider.user?.userId ?? 'unknown_user';

        final success = await provider.updateProject(
          projectId: widget.project!.projectId,
          updatedBy: currentUserId,
          jobName: _jobNameController.text.trim(),
          description: _descriptionController.text.trim(),
          estimatedHours: double.tryParse(_estimatedHoursController.text),
          status: _selectedStatus,
          priority: _selectedPriority,
          startDate: _startDate,
          endDate: _endDate,
          tags: List.from(_tags),
        );

        if (success && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final authProvider = context.read<AuthProvider>();
        final currentUserId = authProvider.user?.userId ?? 'unknown_user';

        final success = await provider.createProject(
          jobName: _jobNameController.text.trim(),
          customerId: _customerIdController.text.trim(),
          createdBy: currentUserId,
          description: _descriptionController.text.trim(),
          estimatedHours: double.tryParse(_estimatedHoursController.text),
          priority: _selectedPriority,
          startDate: _startDate,
          endDate: _endDate,
          assignedEmployeeIds: List.from(_assignedEmployeeIds),
          tags: List.from(_tags),
        );

        if (success && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper methods for status and priority display
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
