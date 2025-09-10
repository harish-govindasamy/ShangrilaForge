import 'package:flutter/material.dart';
import '../shared/models/employee_model.dart';
import '../shared/models/employee_statistics.dart';
import '../shared/enums/sort_by.dart';
import '../features/employee/services/employee_service.dart';

enum EmployeeState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
}

class EnhancedEmployeeProvider with ChangeNotifier {
  final EmployeeService _employeeService = EmployeeService();

  // State management
  EmployeeState _state = EmployeeState.initial;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  Employee? _selectedEmployee;
  String? _errorMessage;
  String _searchQuery = '';
  bool _hasReachedMax = false;

  // Filters
  final List<String> _selectedDepartments = [];
  SortBy _sortBy = SortBy.name;
  bool _sortAscending = true;

  // Getters
  EmployeeState get state => _state;
  List<Employee> get employees =>
      _filteredEmployees.isNotEmpty ? _filteredEmployees : _employees;
  Employee? get selectedEmployee => _selectedEmployee;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasReachedMax => _hasReachedMax;
  bool get isLoading => _state == EmployeeState.loading;
  bool get isLoadingMore => _state == EmployeeState.loadingMore;
  List<String> get selectedDepartments => _selectedDepartments;
  SortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  // Statistics
  EmployeeStatistics get statistics {
    return EmployeeStatistics(
      departmentDistribution: _getDepartmentBreakdown(),
      designationDistribution: _getDesignationBreakdown(),
      averageExperience: _getAverageExperience(),
    );
  }

  // Pagination
  bool get canLoadMore =>
      !_hasReachedMax &&
      _state != EmployeeState.loading &&
      _state != EmployeeState.loadingMore;

  // Load employees
  Future<void> loadEmployees({bool refresh = false}) async {
    if (refresh) {
      _hasReachedMax = false;
      _employees.clear();
      _filteredEmployees.clear();
    }

    _setState(EmployeeState.loading);
    _clearError();

    try {
      final employees = await _employeeService.getEmployees();
      _employees = employees;
      _applyFiltersAndSort();
      _setState(EmployeeState.loaded);
    } catch (e) {
      _setError('Failed to load employees: $e');
      _setState(EmployeeState.error);
    }
  }

  // Load more employees
  Future<void> loadMoreEmployees() async {
    if (!canLoadMore) return;

    _setState(EmployeeState.loadingMore);

    try {
      // Simulate pagination (in real app, this would fetch next page)
      await Future.delayed(const Duration(milliseconds: 500));
      _setState(EmployeeState.loaded);
    } catch (e) {
      _setError('Failed to load more employees: $e');
      _setState(EmployeeState.error);
    }
  }

  // Search
  void searchEmployees(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  // Department filter
  void toggleDepartmentFilter(String department) {
    if (_selectedDepartments.contains(department)) {
      _selectedDepartments.remove(department);
    } else {
      _selectedDepartments.add(department);
    }
    _applyFiltersAndSort();
  }

  void clearDepartmentFilters() {
    _selectedDepartments.clear();
    _applyFiltersAndSort();
  }

  // Sorting
  void setSortBy(SortBy sortBy) {
    if (_sortBy == sortBy) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = sortBy;
      _sortAscending = true;
    }
    _applyFiltersAndSort();
  }

  // Additional sorting method for compatibility
  void applySorting(String sortBy) {
    SortBy sortType;
    switch (sortBy) {
      case 'empName':
        sortType = SortBy.name;
        break;
      case 'department':
        sortType = SortBy.department;
        break;
      case 'empExp':
        sortType = SortBy.experience;
        break;
      case 'joinDate':
        sortType = SortBy.joinDate;
        break;
      case 'empDesignation':
        sortType = SortBy.designation;
        break;
      default:
        sortType = SortBy.name;
    }
    setSortBy(sortType);
  }

  // CRUD operations
  Future<bool> createEmployee(Employee employee) async {
    try {
      final created = await _employeeService.createEmployee(employee);
      _employees.add(created);
      _applyFiltersAndSort();
      return true;
    } catch (e) {
      _setError('Failed to create employee: $e');
      return false;
    }
  }

  Future<bool> updateEmployee(Employee employee) async {
    try {
      final updated =
          await _employeeService.updateEmployee(employee.employeeId, employee);
      final index =
          _employees.indexWhere((e) => e.employeeId == employee.employeeId);
      if (index != -1) {
        _employees[index] = updated;
        _applyFiltersAndSort();
      }
      return true;
    } catch (e) {
      _setError('Failed to update employee: $e');
      return false;
    }
  }

  Future<bool> deleteEmployee(String employeeId) async {
    try {
      await _employeeService.deleteEmployee(employeeId);
      _employees.removeWhere((e) => e.employeeId == employeeId);
      _applyFiltersAndSort();
      return true;
    } catch (e) {
      _setError('Failed to delete employee: $e');
      return false;
    }
  }

  // Get employee by ID
  Future<Employee?> getEmployeeById(String employeeId) async {
    try {
      return await _employeeService.getEmployeeById(employeeId);
    } catch (e) {
      _setError('Failed to get employee: $e');
      return null;
    }
  }

  // Select employee
  void selectEmployee(Employee employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  void clearSelection() {
    _selectedEmployee = null;
    notifyListeners();
  }

  // Private methods
  void _setState(EmployeeState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _applyFiltersAndSort() {
    List<Employee> filtered = List.from(_employees);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((employee) {
        return employee.empName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            employee.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            employee.empCode
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            employee.department
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply department filter
    if (_selectedDepartments.isNotEmpty) {
      filtered = filtered.where((employee) {
        return _selectedDepartments.contains(employee.department);
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case SortBy.name:
          comparison = a.empName.compareTo(b.empName);
          break;
        case SortBy.joinDate:
          final aDate = a.joinDate ?? DateTime(1900);
          final bDate = b.joinDate ?? DateTime(1900);
          comparison = aDate.compareTo(bDate);
          break;
        case SortBy.department:
          comparison = a.department.compareTo(b.department);
          break;
        case SortBy.designation:
          comparison = a.empDesignation.compareTo(b.empDesignation);
          break;
        case SortBy.experience:
          comparison = a.empExp.compareTo(b.empExp);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    _filteredEmployees = filtered;
    notifyListeners();
  }

  Map<String, int> _getDepartmentBreakdown() {
    final breakdown = <String, int>{};
    for (final employee in _employees) {
      breakdown[employee.department] =
          (breakdown[employee.department] ?? 0) + 1;
    }
    return breakdown;
  }

  Map<String, int> _getDesignationBreakdown() {
    final breakdown = <String, int>{};
    for (final employee in _employees) {
      breakdown[employee.empDesignation] =
          (breakdown[employee.empDesignation] ?? 0) + 1;
    }
    return breakdown;
  }

  double _getAverageExperience() {
    if (_employees.isEmpty) return 0.0;
    final totalExperience = _employees.fold<int>(0, (sum, employee) {
      return sum + employee.empExp;
    });
    return totalExperience / _employees.length;
  }
}
