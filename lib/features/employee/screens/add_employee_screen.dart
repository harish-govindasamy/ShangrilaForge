import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/employee_provider.dart';
import '../../../shared/models/employee_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Employee? employee;

  const AddEmployeeScreen({super.key, this.employee});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _designationController = TextEditingController();
  final _mobileController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _uniqueIdController = TextEditingController();
  final _ssnController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _salaryController = TextEditingController();

  DateTime? _selectedDob;
  DateTime? _selectedJoinDate;
  String _selectedGender = 'Male';
  String _selectedMaritalStatus = 'Single';
  String _selectedBloodGroup = 'A+';
  int _experience = 0;
  List<String> _skills = [];

  final List<String> _designations = [
    'Software Engineer',
    'Senior Software Engineer',
    'Lead Engineer',
    'Project Manager',
    'Team Lead',
    'Junior Engineer',
    'Trainee',
    'QA Engineer',
    'DevOps Engineer',
    'UI/UX Designer',
    'System Administrator',
    'Data Analyst',
    'Business Analyst',
    'Technical Writer',
    'Product Manager',
    'Engineering Manager',
    'Database Administrator',
    'Network Administrator',
    'Security Engineer',
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'Mobile Developer',
    'Cloud Engineer',
    'Site Reliability Engineer',
  ];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  final List<String> _maritalStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final emp = widget.employee!;
    _nameController.text = emp.empName;
    _emailController.text = emp.empEmail;
    _addressController.text = emp.empAddress;
    _designationController.text = emp.empDesignation;
    _mobileController.text = emp.empCmob;
    _bankAccountController.text = emp.bankAccount;
    _ifscController.text = emp.ifscCode;
    _uniqueIdController.text = emp.uniqueIdentificationNumber;
    _ssnController.text = emp.ssnNo;
    _emergencyNameController.text = emp.emergencyName;
    _emergencyRelationController.text = emp.emergencyRelation;
    _emergencyPhoneController.text = emp.emergencyPhone;
    _cityController.text = emp.city;
    _stateController.text = emp.state;
    _countryController.text = emp.country;
    _postalCodeController.text = emp.postalCode;
    _parentNameController.text = emp.parentName ?? '';

    _selectedDob = emp.empDob;
    _selectedJoinDate = emp.joinDate;
    _selectedGender = emp.gender;
    _selectedMaritalStatus = emp.maritalStatus;
    _selectedBloodGroup = emp.empBgp;
    _experience = emp.empExp;
    _salaryController.text = emp.salary;
    _skills = List.from(emp.skills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _designationController.dispose();
    _mobileController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _uniqueIdController.dispose();
    _ssnController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _parentNameController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
        actions: [
          if (widget.employee != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information
              _buildSectionHeader('Personal Information'),
              _buildTextField(_nameController, 'Full Name', Icons.person, true),
              _buildTextField(
                  _emailController, 'Email Address', Icons.email, true),
              _buildDateField('Date of Birth', _selectedDob, (date) {
                setState(() {
                  _selectedDob = date;
                });
              }, true),
              _buildDropdownField('Gender', _selectedGender, _genders, (value) {
                setState(() {
                  _selectedGender = value!;
                });
              }, true),
              _buildDropdownField(
                  'Marital Status', _selectedMaritalStatus, _maritalStatuses,
                  (value) {
                setState(() {
                  _selectedMaritalStatus = value!;
                });
              }, true),
              _buildTextField(_parentNameController, 'Parent Name',
                  Icons.family_restroom, false),

              const SizedBox(height: 24),

              // Contact Information
              _buildSectionHeader('Contact Information'),
              _buildTextField(
                  _addressController, 'Address', Icons.location_on, true),
              _buildTextField(
                  _cityController, 'City', Icons.location_city, true),
              _buildTextField(_stateController, 'State', Icons.map, true),
              _buildTextField(
                  _countryController, 'Country', Icons.public, true),
              _buildTextField(_postalCodeController, 'Postal Code',
                  Icons.local_post_office, true),
              _buildTextField(
                  _mobileController, 'Mobile Number', Icons.phone, true),

              const SizedBox(height: 24),

              // Professional Information
              _buildSectionHeader('Professional Information'),
              _buildDropdownField(
                  'Designation', _designationController.text, _designations,
                  (value) {
                _designationController.text = value!;
              }, true),
              _buildNumberField('Experience (Years)', _experience, (value) {
                setState(() {
                  _experience = value;
                });
              }),
              _buildTextField(
                  _salaryController, 'Salary', Icons.attach_money, false),
              _buildDateField('Join Date', _selectedJoinDate, (date) {
                setState(() {
                  _selectedJoinDate = date;
                });
              }, false),
              _buildDropdownField(
                  'Blood Group', _selectedBloodGroup, _bloodGroups, (value) {
                setState(() {
                  _selectedBloodGroup = value!;
                });
              }, true),

              const SizedBox(height: 24),

              // Financial Information
              _buildSectionHeader('Financial Information'),
              _buildTextField(_bankAccountController, 'Bank Account Number',
                  Icons.account_balance, true),
              _buildTextField(_ifscController, 'IFSC Code', Icons.code, true),

              const SizedBox(height: 24),

              // Identification
              _buildSectionHeader('Identification'),
              _buildTextField(
                  _uniqueIdController, 'Unique ID Number', Icons.badge, true),
              _buildTextField(
                  _ssnController, 'SSN Number', Icons.credit_card, true),

              const SizedBox(height: 24),

              // Emergency Contact
              _buildSectionHeader('Emergency Contact'),
              _buildTextField(_emergencyNameController,
                  'Emergency Contact Name', Icons.emergency, true),
              _buildTextField(
                  _emergencyRelationController, 'Relation', Icons.people, true),
              _buildTextField(_emergencyPhoneController, 'Emergency Phone',
                  Icons.phone, true),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveEmployee,
                  child: const Text(
                    'Save Employee',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildNumberField(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value.toString(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.work),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          onChanged(int.tryParse(value) ?? 0);
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items,
      Function(String?) onChanged, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? value,
      Function(DateTime?) onChanged, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            onChanged(date);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(),
          ),
          child: Text(
            value != null
                ? DateFormat('yyyy-MM-dd').format(value)
                : 'Select Date',
            style: TextStyle(
              color: value != null ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final employee = Employee(
        employeeId: widget.employee?.employeeId ??
            'EMP${DateTime.now().millisecondsSinceEpoch}',
        userId: widget.employee?.userId ??
            'USER${DateTime.now().millisecondsSinceEpoch}',
        firstName: _nameController.text.trim().split(' ').first,
        lastName: _nameController.text.trim().split(' ').length > 1
            ? _nameController.text.trim().split(' ').skip(1).join(' ')
            : '',
        empCode: widget.employee?.empCode ??
            'EMP${DateTime.now().millisecondsSinceEpoch}',
        email: _emailController.text.trim(),
        department: _designationController.text.trim(),
        empName: _nameController.text.trim(),
        empEmail: _emailController.text.trim(),
        empAddress: _addressController.text.trim(),
        empDob: _selectedDob!,
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        empDesignation: _designationController.text.trim(),
        empCmob: _mobileController.text.trim(),
        empExp: _experience,
        bankAccount: _bankAccountController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        uniqueIdentificationNumber: _uniqueIdController.text.trim(),
        ssnNo: _ssnController.text.trim(),
        emergencyName: _emergencyNameController.text.trim(),
        emergencyRelation: _emergencyRelationController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        parentName: _parentNameController.text.trim().isNotEmpty
            ? _parentNameController.text.trim()
            : null,
        salary: _salaryController.text.trim(),
        joinDate: _selectedJoinDate,
        empBgp: _selectedBloodGroup,
        skills: _skills,
      );

      final employeeProvider = context.read<EmployeeProvider>();
      bool success;

      if (widget.employee == null) {
        // Creating new employee
        success = await employeeProvider.createEmployee(employee);
      } else {
        // Updating existing employee
        success = await employeeProvider.updateEmployee(
            widget.employee!.employeeId, employee);
      }

      // Hide loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.employee == null
                  ? 'Employee added successfully'
                  : 'Employee updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              employeeProvider.errorMessage ??
                  (widget.employee == null
                      ? 'Failed to add employee'
                      : 'Failed to update employee'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) Navigator.of(context).pop();

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

  void _showDeleteConfirmation() {
    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (_) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${widget.employee!.empName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(parentContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(parentContext);
              final messenger = ScaffoldMessenger.of(parentContext);
              final provider = parentContext.read<EmployeeProvider>();

              navigator.pop();
              final success =
                  await provider.deleteEmployee(widget.employee!.employeeId);

              if (!mounted) return;

              if (success) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                        '${widget.employee!.empName} deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.errorMessage ?? 'Failed to delete employee',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
