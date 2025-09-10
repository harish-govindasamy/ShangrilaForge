import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../services/employee_service.dart';
import '../../../shared/models/employee_model.dart';
import '../../../core/services/local_storage_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _employeeService = EmployeeService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final Logger _logger = Logger('EmployeeProvider');

  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Employee> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Get all employees
  Future<void> loadEmployees() async {
    _setLoading(true);
    _clearError();

    try {
      // First load from local storage
      _employees = await _localStorageService.getEmployees();
      notifyListeners();

      // Then try to sync with API
      try {
        final apiEmployees = await _employeeService.getEmployees();
        _employees = apiEmployees;
        await _localStorageService.saveEmployees(_employees);
        notifyListeners();
      } catch (apiError) {
        // API failed, but we have local data
        if (_employees.isEmpty) {
          rethrow;
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get employee by ID
  Future<void> loadEmployeeById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // First try local storage
      final localEmployees = await _localStorageService.getEmployees();
      _selectedEmployee = localEmployees.firstWhere(
        (emp) => emp.employeeId == id,
        orElse: () => throw Exception('Employee not found'),
      );
      notifyListeners();

      // Then try API
      try {
        _selectedEmployee = await _employeeService.getEmployeeById(id);
        notifyListeners();
      } catch (apiError) {
        // API failed, but we have local data
        if (_selectedEmployee == null) {
          rethrow;
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create employee
  Future<bool> createEmployee(Employee employee) async {
    _setLoading(true);
    _clearError();

    try {
      // Add to local storage first
      _employees.add(employee);
      await _localStorageService.saveEmployees(_employees);
      notifyListeners();

      // Try to sync with API
      try {
        final newEmployee = await _employeeService.createEmployee(employee);
        // Update with server response
        final index =
            _employees.indexWhere((e) => e.employeeId == employee.employeeId);
        if (index != -1) {
          _employees[index] = newEmployee;
          await _localStorageService.saveEmployees(_employees);
          notifyListeners();
        }
      } catch (apiError) {
        // API failed, but local save succeeded
        _logger.warning('API sync failed during employee creation: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update employee
  Future<bool> updateEmployee(String id, Employee employee) async {
    _setLoading(true);
    _clearError();

    try {
      // Update locally first
      final index = _employees.indexWhere((emp) => emp.employeeId == id);
      if (index != -1) {
        _employees[index] = employee;
        await _localStorageService.saveEmployees(_employees);
      }
      if (_selectedEmployee?.employeeId == id) {
        _selectedEmployee = employee;
      }
      notifyListeners();

      // Try to sync with API
      try {
        final updatedEmployee =
            await _employeeService.updateEmployee(id, employee);
        // Update with server response
        if (index != -1) {
          _employees[index] = updatedEmployee;
          await _localStorageService.saveEmployees(_employees);
        }
        if (_selectedEmployee?.employeeId == id) {
          _selectedEmployee = updatedEmployee;
        }
        notifyListeners();
      } catch (apiError) {
        _logger.warning('API sync failed during employee update: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete employee
  Future<bool> deleteEmployee(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Remove locally first
      _employees.removeWhere((emp) => emp.employeeId == id);
      await _localStorageService.saveEmployees(_employees);
      if (_selectedEmployee?.employeeId == id) {
        _selectedEmployee = null;
      }
      notifyListeners();

      // Try to sync with API
      try {
        await _employeeService.deleteEmployee(id);
      } catch (apiError) {
        _logger.warning('API sync failed during employee deletion: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search employees
  Future<void> searchEmployees(String query) async {
    _searchQuery = query;
    _setLoading(true);
    _clearError();

    try {
      if (query.isEmpty) {
        _employees = await _localStorageService.getEmployees();
      } else {
        try {
          _employees = await _employeeService.searchEmployees(query);
        } catch (apiError) {
          // Fallback to local search
          final localEmployees = await _localStorageService.getEmployees();
          _employees = localEmployees
              .where((emp) =>
                  emp.empName.toLowerCase().contains(query.toLowerCase()) ||
                  emp.empEmail.toLowerCase().contains(query.toLowerCase()) ||
                  emp.employeeId.toLowerCase().contains(query.toLowerCase()) ||
                  emp.empDesignation
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();
        }
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get employees by designation
  Future<void> getEmployeesByDesignation(String designation) async {
    _searchQuery = ''; // Clear search query when filtering by designation
    _setLoading(true);
    _clearError();

    try {
      try {
        _employees =
            await _employeeService.getEmployeesByDesignation(designation);
      } catch (apiError) {
        // Fallback to local filtering
        final localEmployees = await _localStorageService.getEmployees();
        _employees = localEmployees
            .where((emp) =>
                emp.empDesignation.toLowerCase() == designation.toLowerCase())
            .toList();
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Set selected employee
  void setSelectedEmployee(Employee? employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  // Get filtered employees
  List<Employee> get filteredEmployees {
    if (_searchQuery.isEmpty) {
      return _employees;
    }

    return _employees
        .where((employee) =>
            employee.empName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            employee.empEmail
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            employee.employeeId
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            employee.empDesignation
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Get unique designations
  List<String> get uniqueDesignations {
    final designations =
        _employees.map((emp) => emp.empDesignation).toSet().toList();
    designations.sort();
    return designations;
  }

  // Get employees count by designation
  Map<String, int> getEmployeesCountByDesignation() {
    final Map<String, int> count = {};
    for (final employee in _employees) {
      count[employee.empDesignation] =
          (count[employee.empDesignation] ?? 0) + 1;
    }
    return count;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
