import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/employee_provider.dart';
import '../../../shared/models/employee_model.dart';
import 'add_employee_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployeeById(widget.employeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          Consumer<EmployeeProvider>(
            builder: (context, employeeProvider, child) {
              if (employeeProvider.selectedEmployee != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEmployeeScreen(
                          employee: employeeProvider.selectedEmployee,
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, child) {
          if (employeeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (employeeProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading employee details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    employeeProvider.errorMessage!,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      employeeProvider.loadEmployeeById(widget.employeeId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final employee = employeeProvider.selectedEmployee;
          if (employee == null) {
            return const Center(
              child: Text('Employee not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(employee),

                const SizedBox(height: 24),

                // Personal Information
                _buildInfoSection(
                  'Personal Information',
                  Icons.person,
                  [
                    _buildInfoRow('Full Name', employee.empName),
                    _buildInfoRow('Email', employee.empEmail),
                    _buildInfoRow('Date of Birth',
                        DateFormat('yyyy-MM-dd').format(employee.empDob)),
                    _buildInfoRow('Gender', employee.gender),
                    _buildInfoRow('Marital Status', employee.maritalStatus),
                    if (employee.parentName != null)
                      _buildInfoRow('Parent Name', employee.parentName!),
                  ],
                ),

                const SizedBox(height: 16),

                // Contact Information
                _buildInfoSection(
                  'Contact Information',
                  Icons.contact_phone,
                  [
                    _buildInfoRow('Address', employee.empAddress),
                    _buildInfoRow('City', employee.city),
                    _buildInfoRow('State', employee.state),
                    _buildInfoRow('Country', employee.country),
                    _buildInfoRow('Postal Code', employee.postalCode),
                    _buildInfoRow('Mobile', employee.empCmob),
                  ],
                ),

                const SizedBox(height: 16),

                // Professional Information
                _buildInfoSection(
                  'Professional Information',
                  Icons.work,
                  [
                    _buildInfoRow('Employee ID', employee.employeeId),
                    _buildInfoRow('Designation', employee.empDesignation),
                    _buildInfoRow('Experience', '${employee.empExp} years'),
                    _buildInfoRow('Salary', '\$${employee.salary}'),
                    if (employee.joinDate != null)
                      _buildInfoRow('Join Date',
                          DateFormat('yyyy-MM-dd').format(employee.joinDate!)),
                    _buildInfoRow('Blood Group', employee.empBgp),
                  ],
                ),

                const SizedBox(height: 16),

                // Financial Information
                _buildInfoSection(
                  'Financial Information',
                  Icons.account_balance,
                  [
                    _buildInfoRow('Bank Account', employee.bankAccount),
                    _buildInfoRow('IFSC Code', employee.ifscCode),
                  ],
                ),

                const SizedBox(height: 16),

                // Identification
                _buildInfoSection(
                  'Identification',
                  Icons.badge,
                  [
                    _buildInfoRow(
                        'Unique ID', employee.uniqueIdentificationNumber),
                    _buildInfoRow('SSN Number', employee.ssnNo),
                  ],
                ),

                const SizedBox(height: 16),

                // Emergency Contact
                _buildInfoSection(
                  'Emergency Contact',
                  Icons.emergency,
                  [
                    _buildInfoRow('Contact Name', employee.emergencyName),
                    _buildInfoRow('Relation', employee.emergencyRelation),
                    _buildInfoRow('Phone', employee.emergencyPhone),
                  ],
                ),

                if (employee.skills.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  // Skills
                  _buildInfoSection(
                    'Skills',
                    Icons.star,
                    [
                      _buildSkillsRow(employee.skills),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(Employee employee) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                _getInitials(employee.empName),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.empName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    employee.empDesignation,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${employee.employeeId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2196F3)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsRow(List<String> skills) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2196F3),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
