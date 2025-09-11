import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/enums/timesheet_status.dart';
import '../../../core/navigation/app_router.dart';
import '../providers/timesheet_provider.dart';

class TimesheetFormScreen extends StatefulWidget {
  final String? timesheetId;

  const TimesheetFormScreen({
    Key? key,
    this.timesheetId,
  }) : super(key: key);

  @override
  State<TimesheetFormScreen> createState() => _TimesheetFormScreenState();
}

class _TimesheetFormScreenState extends State<TimesheetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectController = TextEditingController();
  final _hoursController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedProject;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.timesheetId != null;

    if (_isEditMode) {
      // Load timesheet data for editing
      // This would typically come from a provider
      _projectController.text = 'Project Name';
      _hoursController.text = '8';
      _descriptionController.text = 'Worked on implementing the dashboard UI';
      _selectedDate = DateTime.now().subtract(const Duration(days: 1));
      _selectedProject = 'project-id-1';
    }
  }

  @override
  void dispose() {
    _projectController.dispose();
    _hoursController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTimesheet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Logic to save timesheet will go here
        // This would typically use a provider

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode
                  ? 'Timesheet updated successfully'
                  : 'Timesheet created successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to the timesheet list
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This would typically come from a provider
    final projects = [
      {'id': 'project-id-1', 'name': 'Website Redesign'},
      {'id': 'project-id-2', 'name': 'Mobile App Development'},
      {'id': 'project-id-3', 'name': 'Database Migration'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Timesheet' : 'New Timesheet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date picker
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('EEEE, MMMM d, yyyy')
                          .format(_selectedDate),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Project dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Project',
                  prefixIcon: Icon(Icons.business),
                ),
                value: _selectedProject,
                items: projects.map((project) {
                  return DropdownMenuItem<String>(
                    value: project['id'],
                    child: Text(project['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProject = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a project';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Hours input
              TextFormField(
                controller: _hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  prefixIcon: Icon(Icons.access_time),
                  suffixText: 'hours',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hours worked';
                  }
                  final hours = double.tryParse(value);
                  if (hours == null) {
                    return 'Please enter a valid number';
                  }
                  if (hours <= 0 || hours > 24) {
                    return 'Hours must be between 0 and 24';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description input
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTimesheet,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          _isEditMode ? 'UPDATE TIMESHEET' : 'SAVE TIMESHEET',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // Delete button (only in edit mode)
              if (_isEditMode) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            // Show delete confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Timesheet'),
                                content: const Text(
                                    'Are you sure you want to delete this timesheet?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Delete timesheet and navigate back
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Timesheet deleted successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    child: const Text('DELETE'),
                                  ),
                                ],
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text(
                      'DELETE TIMESHEET',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
