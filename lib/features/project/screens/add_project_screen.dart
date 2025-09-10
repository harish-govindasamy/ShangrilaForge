import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../../../shared/models/project_model.dart';

class AddProjectScreen extends StatefulWidget {
  final Project? project;

  const AddProjectScreen({super.key, this.project});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobNameController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _totalHoursController = TextEditingController();

  ProjectStatus _selectedStatus = ProjectStatus.open;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final project = widget.project!;
    _jobNameController.text = project.jobName;
    _customerIdController.text = project.customerId;
    _totalCostController.text = project.totalCost.toString();
    _totalHoursController.text = project.totalHours.toString();
    _selectedStatus = project.status;
  }

  @override
  void dispose() {
    _jobNameController.dispose();
    _customerIdController.dispose();
    _totalCostController.dispose();
    _totalHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'Add Project' : 'Edit Project'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Information
              const Text(
                'Project Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _jobNameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter project name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _customerIdController,
                decoration: const InputDecoration(
                  labelText: 'Customer ID',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer ID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalCostController,
                      decoration: const InputDecoration(
                        labelText: 'Total Cost',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter total cost';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _totalHoursController,
                      decoration: const InputDecoration(
                        labelText: 'Total Hours',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter total hours';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<ProjectStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: ProjectStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProject,
                  child: const Text(
                    'Save Project',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final project = Project(
      projectId: widget.project?.projectId ?? '',
      jobName: _jobNameController.text.trim(),
      customerId: _customerIdController.text.trim(),
      jobCode: widget.project?.jobCode ?? '0001',
      totalCost: double.parse(_totalCostController.text),
      totalHours: double.parse(_totalHoursController.text),
      status: _selectedStatus,
      createdAt: widget.project?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: widget.project?.createdBy ?? 'current_user',
      updatedBy: 'current_user',
    );

    final projectProvider = context.read<ProjectProvider>();
    bool success;

    if (widget.project == null) {
      success = await projectProvider.createProject(project);
    } else {
      success = await projectProvider.updateProject(
          widget.project!.projectId, project);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.project == null
                ? 'Project added successfully'
                : 'Project updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            projectProvider.errorMessage ??
                (widget.project == null
                    ? 'Failed to add project'
                    : 'Failed to update project'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
