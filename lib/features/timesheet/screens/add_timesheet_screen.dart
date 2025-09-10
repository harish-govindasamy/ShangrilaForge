import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timesheet_provider.dart';
import '../../../shared/models/timesheet_model.dart';

class AddTimesheetScreen extends StatefulWidget {
  final Timesheet? timesheet;

  const AddTimesheetScreen({super.key, this.timesheet});

  @override
  State<AddTimesheetScreen> createState() => _AddTimesheetScreenState();
}

class _AddTimesheetScreenState extends State<AddTimesheetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _taskIdController = TextEditingController();

  DateTime? _selectedWeekStart;
  DateTime? _selectedWeekEnd;
  TimesheetStatus _selectedStatus = TimesheetStatus.draft;

  // Daily hours controllers
  final List<TextEditingController> _dailyHoursControllers = List.generate(
    16,
    (index) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    if (widget.timesheet != null) {
      _populateForm();
    } else {
      // Set default week start to Monday of current week
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      _selectedWeekStart = monday;
      _selectedWeekEnd = monday.add(const Duration(days: 15)); // 16-day period
    }
  }

  void _populateForm() {
    final timesheet = widget.timesheet!;
    _userIdController.text = timesheet.userId;
    _employeeIdController.text = timesheet.employeeId;
    _projectIdController.text = timesheet.projectId;
    _taskIdController.text = timesheet.taskId;
    _selectedWeekStart = timesheet.weekStartDate;
    _selectedWeekEnd = timesheet.weekEndDate;
    _selectedStatus = timesheet.status;

    // Populate daily hours
    final dailyHours = timesheet.dailyHours;
    for (int i = 0; i < dailyHours.length && i < 16; i++) {
      _dailyHoursControllers[i].text = dailyHours[i].toString();
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _employeeIdController.dispose();
    _projectIdController.dispose();
    _taskIdController.dispose();
    for (final controller in _dailyHoursControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.timesheet == null ? 'Add Timesheet' : 'Edit Timesheet'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user ID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter employee ID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _projectIdController,
                      decoration: const InputDecoration(
                        labelText: 'Project ID',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter project ID';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _taskIdController,
                      decoration: const InputDecoration(
                        labelText: 'Task ID',
                        prefixIcon: Icon(Icons.task),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter task ID';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Week Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedWeekStart ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedWeekStart = date;
                            _selectedWeekEnd =
                                date.add(const Duration(days: 15));
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Week Start Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedWeekStart != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(_selectedWeekStart!)
                              : 'Select Start Date',
                          style: TextStyle(
                            color: _selectedWeekStart != null
                                ? Colors.black87
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Week End Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedWeekEnd != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedWeekEnd!)
                            : 'Auto-calculated',
                        style: TextStyle(
                          color: _selectedWeekEnd != null
                              ? Colors.black87
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Daily Hours
              const Text(
                'Daily Hours (16-day period)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  final dayNumber = index + 1;
                  final date = _selectedWeekStart?.add(Duration(days: index));

                  return Column(
                    children: [
                      Text(
                        'Day $dayNumber',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (date != null)
                        Text(
                          DateFormat('MMM dd').format(date),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _dailyHoursControllers[index],
                        decoration: const InputDecoration(
                          hintText: '0.0',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final hours = double.tryParse(value);
                            if (hours == null || hours < 0 || hours > 24) {
                              return 'Invalid hours';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Status
              DropdownButtonFormField<TimesheetStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: TimesheetStatus.values.map((status) {
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
                  onPressed: _saveTimesheet,
                  child: const Text(
                    'Save Timesheet',
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

  Future<void> _saveTimesheet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWeekStart == null || _selectedWeekEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select week start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Parse daily hours
    final dailyHours = <double>[];
    for (int i = 0; i < 16; i++) {
      final hours = double.tryParse(_dailyHoursControllers[i].text) ?? 0.0;
      dailyHours.add(hours);
    }

    final timesheet = Timesheet(
      userId: _userIdController.text.trim(),
      employeeId: _employeeIdController.text.trim(),
      projectId: _projectIdController.text.trim(),
      taskId: _taskIdController.text.trim(),
      weekStartDate: _selectedWeekStart!,
      weekEndDate: _selectedWeekEnd!,
      createdBy: 'current_user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      day1Hours: dailyHours[0],
      day2Hours: dailyHours[1],
      day3Hours: dailyHours[2],
      day4Hours: dailyHours[3],
      day5Hours: dailyHours[4],
      day6Hours: dailyHours[5],
      day7Hours: dailyHours[6],
      day8Hours: dailyHours[7],
      day9Hours: dailyHours[8],
      day10Hours: dailyHours[9],
      day11Hours: dailyHours[10],
      day12Hours: dailyHours[11],
      day13Hours: dailyHours[12],
      day14Hours: dailyHours[13],
      day15Hours: dailyHours[14],
      day16Hours: dailyHours[15],
      status: _selectedStatus,
    );

    final timesheetProvider = context.read<TimesheetProvider>();
    bool success;

    if (widget.timesheet == null) {
      success = await timesheetProvider.createTimesheet(timesheet);
    } else {
      success = await timesheetProvider.updateTimesheet(
          widget.timesheet!.userId, timesheet);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.timesheet == null
                ? 'Timesheet added successfully'
                : 'Timesheet updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            timesheetProvider.errorMessage ??
                (widget.timesheet == null
                    ? 'Failed to add timesheet'
                    : 'Failed to update timesheet'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
