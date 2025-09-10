import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/enhanced_employee_provider.dart';
import '../../../shared/models/employee_model.dart';
import '../../../core/monitoring/analytics_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({
    super.key,
    this.employee,
  });

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers for form fields
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _designationController;
  late final TextEditingController _experienceController;
  late final TextEditingController _bgpController;
  late final TextEditingController _categoryController;
  late final TextEditingController _phoneController;
  late final TextEditingController _salaryController;
  late final TextEditingController _bankAccountController;
  late final TextEditingController _ifscCodeController;
  late final TextEditingController _uinController;
  late final TextEditingController _ssnController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyRelationController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _empCodeController;
  late final TextEditingController _departmentController;
  late final TextEditingController _parentNameController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalCodeController;

  // Form state
  DateTime? _dateOfBirth;
  DateTime? _joinDate;
  String _gender = 'Male';
  String _maritalStatus = 'Single';
  List<String> _skills = [];
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed'
  ];
  final List<String> _availableSkills = [
    'Flutter',
    'Dart',
    'React',
    'Node.js',
    'Python',
    'Java',
    'C++',
    'JavaScript',
    'TypeScript',
    'AWS',
    'Azure',
    'GCP',
    'Docker',
    'Kubernetes',
    'MongoDB',
    'PostgreSQL',
    'MySQL',
    'Redis',
    'GraphQL',
    'REST API',
    'Microservices',
    'CI/CD',
    'DevOps',
    'Machine Learning',
    'AI',
    'Data Science',
    'UI/UX',
    'Project Management'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _populateFormFields();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _designationController = TextEditingController();
    _experienceController = TextEditingController();
    _bgpController = TextEditingController();
    _categoryController = TextEditingController();
    _phoneController = TextEditingController();
    _salaryController = TextEditingController();
    _bankAccountController = TextEditingController();
    _ifscCodeController = TextEditingController();
    _uinController = TextEditingController();
    _ssnController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyRelationController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _empCodeController = TextEditingController();
    _departmentController = TextEditingController();
    _parentNameController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _postalCodeController = TextEditingController();
  }

  void _populateFormFields() {
    if (widget.employee != null) {
      final employee = widget.employee!;

      _nameController.text = employee.empName;
      _emailController.text = employee.empEmail;
      _addressController.text = employee.empAddress;
      _designationController.text = employee.empDesignation;
      _experienceController.text = employee.empExp.toString();
      _bgpController.text = employee.empBgp;
      _categoryController.text = employee.empCategory;
      _phoneController.text = employee.empCmob;
      _salaryController.text = employee.salary;
      _bankAccountController.text = employee.bankAccount;
      _ifscCodeController.text = employee.ifscCode;
      _uinController.text = employee.uniqueIdentificationNumber;
      _ssnController.text = employee.ssnNo;
      _emergencyNameController.text = employee.emergencyName;
      _emergencyRelationController.text = employee.emergencyRelation;
      _emergencyPhoneController.text = employee.emergencyPhone;
      _firstNameController.text = employee.firstName;
      _lastNameController.text = employee.lastName;
      _empCodeController.text = employee.empCode;
      _departmentController.text = employee.department;
      _parentNameController.text = employee.parentName ?? '';
      _cityController.text = employee.city;
      _stateController.text = employee.state;
      _countryController.text = employee.country;
      _postalCodeController.text = employee.postalCode;

      _dateOfBirth = employee.empDob;
      _joinDate = employee.joinDate;
      _gender = employee.gender;
      _maritalStatus = employee.maritalStatus;
      _skills = List.from(employee.skills);
    } else {
      // Set default values for new employee
      _countryController.text = 'India';
      _experienceController.text = '0';
      _salaryController.text = '0.00';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _designationController.dispose();
    _experienceController.dispose();
    _bgpController.dispose();
    _categoryController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    _bankAccountController.dispose();
    _ifscCodeController.dispose();
    _uinController.dispose();
    _ssnController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _empCodeController.dispose();
    _departmentController.dispose();
    _parentNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Personal Information', [
                _buildNameFields(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildDateField(
                  'Date of Birth',
                  _dateOfBirth,
                  (date) => setState(() => _dateOfBirth = date),
                ),
                const SizedBox(height: 16),
                _buildGenderField(),
                const SizedBox(height: 16),
                _buildMaritalStatusField(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _parentNameController,
                  label: 'Parent Name',
                  required: false,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Contact Information', [
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildAddressFields(),
              ]),
              const SizedBox(height: 24),
              _buildSection('Professional Information', [
                _buildTextField(
                  controller: _empCodeController,
                  label: 'Employee Code',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Employee code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _designationController,
                  label: 'Designation',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Designation is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _departmentController,
                  label: 'Department',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Department is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _experienceController,
                  label: 'Experience (Years)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Experience is required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  'Join Date',
                  _joinDate,
                  (date) => setState(() => _joinDate = date),
                  required: false,
                ),
                const SizedBox(height: 16),
                _buildSkillsField(),
              ]),
              const SizedBox(height: 24),
              _buildSection('Financial Information', [
                _buildTextField(
                  controller: _salaryController,
                  label: 'Salary',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Salary is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bankAccountController,
                  label: 'Bank Account Number',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bank account number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ifscCodeController,
                  label: 'IFSC Code',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'IFSC code is required';
                    }
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Government IDs', [
                _buildTextField(
                  controller: _uinController,
                  label: 'Unique Identification Number',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'UIN is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ssnController,
                  label: 'SSN Number',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'SSN is required';
                    }
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Emergency Contact', [
                _buildTextField(
                  controller: _emergencyNameController,
                  label: 'Emergency Contact Name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Emergency contact name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emergencyRelationController,
                  label: 'Relationship',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Relationship is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emergencyPhoneController,
                  label: 'Emergency Contact Phone',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Emergency contact phone is required';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Additional Information', [
                _buildTextField(
                  controller: _bgpController,
                  label: 'BGP',
                  required: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _categoryController,
                  label: 'Category',
                  required: false,
                ),
              ]),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First name is required';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'State',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'State is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _countryController,
                label: 'Country',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Country is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _postalCodeController,
                label: 'Postal Code',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Postal code is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: validator ??
          (required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email *',
        border: OutlineInputBorder(),
        filled: true,
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    Function(DateTime?) onDateSelected, {
    bool required = true,
  }) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).hintColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('dd/MM/yyyy').format(date)
                    : required
                        ? '$label *'
                        : label,
                style: TextStyle(
                  color: date != null
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender *',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _genderOptions.map((gender) {
            return ChoiceChip(
              label: Text(gender),
              selected: _gender == gender,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _gender = gender);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMaritalStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marital Status',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _maritalStatusOptions.map((status) {
            return ChoiceChip(
              label: Text(status),
              selected: _maritalStatus == status,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _maritalStatus = status);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _availableSkills.map((skill) {
            final isSelected = _skills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _skills.add(skill);
                  } else {
                    _skills.remove(skill);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (_skills.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Selected: ${_skills.join(', ')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                widget.employee == null ? 'Add Employee' : 'Update Employee',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update the full name field based on first and last name
      _nameController.text =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      final employee = Employee(
        empName: _nameController.text.trim(),
        empEmail: _emailController.text.trim(),
        empDob: _dateOfBirth!,
        empAddress: _addressController.text.trim(),
        empDesignation: _designationController.text.trim(),
        empExp: int.parse(_experienceController.text.trim()),
        empBgp: _bgpController.text.trim(),
        empCategory: _categoryController.text.trim(),
        empCmob: _phoneController.text.trim(),
        joinDate: _joinDate,
        salary: _salaryController.text.trim(),
        bankAccount: _bankAccountController.text.trim(),
        ifscCode: _ifscCodeController.text.trim(),
        uniqueIdentificationNumber: _uinController.text.trim(),
        ssnNo: _ssnController.text.trim(),
        emergencyName: _emergencyNameController.text.trim(),
        emergencyRelation: _emergencyRelationController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim(),
        employeeId: widget.employee?.employeeId ?? '',
        userId: widget.employee?.userId ?? '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        empCode: _empCodeController.text.trim(),
        email: _emailController.text.trim(),
        department: _departmentController.text.trim(),
        gender: _gender,
        maritalStatus: _maritalStatus,
        parentName: _parentNameController.text.trim().isEmpty
            ? null
            : _parentNameController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        skills: _skills,
        recordTracking: widget.employee?.recordTracking ?? [],
      );

      final provider = context.read<EnhancedEmployeeProvider>();
      bool success;

      if (widget.employee == null) {
        success = await provider.createEmployee(employee);
        AnalyticsService.trackEvent('employee_created_form', {
          'employee_name': employee.empName,
          'department': employee.department,
          'skills_count': employee.skills.length,
        });
      } else {
        success = await provider.updateEmployee(
            widget.employee!.employeeId, employee);
        AnalyticsService.trackEvent('employee_updated_form', {
          'employee_id': widget.employee!.employeeId,
          'employee_name': employee.empName,
        });
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage ??
                    (widget.employee == null
                        ? 'Failed to add employee'
                        : 'Failed to update employee'),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
