import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';

class EmployeeFilterChips extends StatefulWidget {
  const EmployeeFilterChips({super.key});

  @override
  State<EmployeeFilterChips> createState() => _EmployeeFilterChipsState();
}

class _EmployeeFilterChipsState extends State<EmployeeFilterChips> {
  String? _selectedDesignation;

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, child) {
        final designations = employeeProvider.uniqueDesignations;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // All Employees Chip
              FilterChip(
                label: const Text('All'),
                selected: _selectedDesignation == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedDesignation = null;
                  });
                  // Clear search query and reload all employees
                  employeeProvider.searchEmployees('');
                  employeeProvider.loadEmployees();
                },
                selectedColor: Colors.blue.withValues(alpha: 0.2),
                checkmarkColor: Colors.blue,
              ),

              const SizedBox(width: 8),

              // Designation Filter Chips
              ...designations.map((designation) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(designation),
                    selected: _selectedDesignation == designation,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDesignation = selected ? designation : null;
                      });

                      if (selected) {
                        // Clear search and filter by designation
                        employeeProvider.getEmployeesByDesignation(designation);
                      } else {
                        // Clear search query and reload all employees
                        employeeProvider.searchEmployees('');
                        employeeProvider.loadEmployees();
                      }
                    },
                    selectedColor: Colors.blue.withValues(alpha: 0.2),
                    checkmarkColor: Colors.blue,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
