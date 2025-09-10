import 'package:flutter/material.dart';
import '../../../core/domain/usecases/employee_usecases.dart';
import '../../../core/errors/failures.dart';
import '../../../shared/models/employee_model.dart';
import '../../../shared/models/employee_statistics.dart';
import '../../../core/monitoring/analytics_service.dart';
import '../../../core/monitoring/error_reporter.dart';
import '../../../shared/enums/sort_by.dart';

enum EmployeeState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
}

class EnhancedEmployeeProvider with ChangeNotifier {
  final GetEmployeesUseCase _getEmployeesUseCase;
  final CreateEmployeeUseCase _createEmployeeUseCase;
  final UpdateEmployeeUseCase _updateEmployeeUseCase;
  final DeleteEmployeeUseCase _deleteEmployeeUseCase;
  final SearchEmployeesUseCase _searchEmployeesUseCase;
  final GetEmployeeByIdUseCase _getEmployeeByIdUseCase;

  EnhancedEmployeeProvider({
    required GetEmployeesUseCase getEmployeesUseCase,
    required CreateEmployeeUseCase createEmployeeUseCase,
    required UpdateEmployeeUseCase updateEmployeeUseCase,
    required DeleteEmployeeUseCase deleteEmployeeUseCase,
    required SearchEmployeesUseCase searchEmployeesUseCase,
    required GetEmployeeByIdUseCase getEmployeeByIdUseCase,
  })  : _getEmployeesUseCase = getEmployeesUseCase,
        _createEmployeeUseCase = createEmployeeUseCase,
        _updateEmployeeUseCase = updateEmployeeUseCase,
        _deleteEmployeeUseCase = deleteEmployeeUseCase,
        _searchEmployeesUseCase = searchEmployeesUseCase,
        _getEmployeeByIdUseCase = getEmployeeByIdUseCase;

  // State management
  EmployeeState _state = EmployeeState.initial;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  Employee? _selectedEmployee;
  String? _errorMessage;
  String _searchQuery = '';
  bool _hasReachedMax = false;
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Sorting and filtering
  String _sortBy = 'empName';
  bool _sortAscending = true;
  Map<String, dynamic> _filters = {};

  // Filter state
  final Set<String> _selectedDepartments = {};
  final Set<String> _selectedDesignations = {};
  RangeValues? _experienceRange;
  SortBy _currentSortBy = SortBy.name;

  // Getters
  EmployeeState get state => _state;
  List<Employee> get employees =>
      _filteredEmployees.isEmpty && _searchQuery.isEmpty
          ? _employees
          : _filteredEmployees;
  Employee? get selectedEmployee => _selectedEmployee;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasReachedMax => _hasReachedMax;
  int get totalEmployees => _employees.length;
  bool get isLoading => _state == EmployeeState.loading;
  bool get isLoadingMore => _state == EmployeeState.loadingMore;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  Map<String, dynamic> get activeFilters => Map.from(_filters);

  // New getters for missing properties
  bool get canLoadMore =>
      !_hasReachedMax && _state != EmployeeState.loadingMore;
  String get currentSearchQuery => _searchQuery;
  Set<String> get selectedDepartments => Set.from(_selectedDepartments);
  Set<String> get selectedDesignations => Set.from(_selectedDesignations);
  RangeValues? get experienceRange => _experienceRange;
  SortBy get currentSortBy => _currentSortBy;
  bool get isAscending => _sortAscending;

  bool get hasActiveFilters =>
      _selectedDepartments.isNotEmpty ||
      _selectedDesignations.isNotEmpty ||
      _experienceRange != null ||
      _searchQuery.isNotEmpty;

  List<String> get availableDepartments {
    final departments = _employees.map((e) => e.department).toSet().toList();
    departments.sort();
    return departments;
  }

  List<String> get availableDesignations {
    final designations =
        _employees.map((e) => e.empDesignation).toSet().toList();
    designations.sort();
    return designations;
  }

  // Statistics getter with proper structure
  EmployeeStatistics get statistics => EmployeeStatistics(
        departmentDistribution: departmentDistribution,
        designationDistribution: designationDistribution,
        averageExperience: averageExperience.toDouble(),
      );

  // Statistics
  Map<String, int> get departmentDistribution {
    final distribution = <String, int>{};
    for (final employee in _employees) {
      distribution[employee.department] =
          (distribution[employee.department] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> get designationDistribution {
    final distribution = <String, int>{};
    for (final employee in _employees) {
      distribution[employee.empDesignation] =
          (distribution[employee.empDesignation] ?? 0) + 1;
    }
    return distribution;
  }

  int get averageExperience {
    if (_employees.isEmpty) return 0;
    final totalExp = _employees.fold<int>(0, (sum, emp) => sum + emp.empExp);
    return (totalExp / _employees.length).round();
  }

  // Load employees with pagination
  Future<void> loadEmployees({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _employees.clear();
      _filteredEmployees.clear();
    }

    if (_hasReachedMax && !refresh) return;

    _state = refresh ? EmployeeState.loading : EmployeeState.loadingMore;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _getEmployeesUseCase();

      result.fold(
        (failure) {
          _state = EmployeeState.error;
          _errorMessage = _getFailureMessage(failure);

          AnalyticsService.trackEvent('employee_load_failed', {
            'failure_type': failure.runtimeType.toString(),
            'message': _errorMessage,
            'page': _currentPage,
          });

          ErrorReporter.reportError(
            Exception('Failed to load employees: $_errorMessage'),
            StackTrace.current,
            context: {
              'page': _currentPage,
              'refresh': refresh,
              'failure_type': failure.runtimeType.toString(),
            },
          );
        },
        (employeeList) {
          if (refresh) {
            _employees = employeeList;
          } else {
            // For pagination, we would typically append new employees
            // But since our use case returns all employees, we'll just update
            _employees = employeeList;
          }

          _applyFiltersAndSort();
          _state = EmployeeState.loaded;

          // Check if we've reached max (for pagination)
          if (employeeList.length < _pageSize) {
            _hasReachedMax = true;
          }

          AnalyticsService.trackEvent('employees_loaded', {
            'count': employeeList.length,
            'page': _currentPage,
            'total_cached': _employees.length,
          });

          _currentPage++;
        },
      );
    } catch (e) {
      _state = EmployeeState.error;
      _errorMessage = 'Unexpected error occurred';

      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {
          'action': 'load_employees',
          'page': _currentPage,
          'refresh': refresh,
        },
      );
    }

    notifyListeners();
  }

  // Create employee
  Future<bool> createEmployee(Employee employee) async {
    try {
      final result = await _createEmployeeUseCase(employee);

      return result.fold(
        (failure) {
          _errorMessage = _getFailureMessage(failure);

          AnalyticsService.trackEvent('employee_create_failed', {
            'failure_type': failure.runtimeType.toString(),
            'employee_name': employee.empName,
          });

          return false;
        },
        (createdEmployee) {
          _employees.add(createdEmployee);
          _applyFiltersAndSort();

          AnalyticsService.trackEvent('employee_created', {
            'employee_id': createdEmployee.employeeId,
            'employee_name': createdEmployee.empName,
            'department': createdEmployee.department,
          });

          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to create employee';

      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {
          'action': 'create_employee',
          'employee_name': employee.empName,
        },
      );

      return false;
    }
  }

  // Update employee
  Future<bool> updateEmployee(String id, Employee employee) async {
    try {
      final result = await _updateEmployeeUseCase(id, employee);

      return result.fold(
        (failure) {
          _errorMessage = _getFailureMessage(failure);

          AnalyticsService.trackEvent('employee_update_failed', {
            'failure_type': failure.runtimeType.toString(),
            'employee_id': id,
          });

          return false;
        },
        (updatedEmployee) {
          final index = _employees.indexWhere((e) => e.employeeId == id);
          if (index != -1) {
            _employees[index] = updatedEmployee;
            _applyFiltersAndSort();

            // Update selected employee if it's the same one
            if (_selectedEmployee?.employeeId == id) {
              _selectedEmployee = updatedEmployee;
            }

            AnalyticsService.trackEvent('employee_updated', {
              'employee_id': id,
              'employee_name': updatedEmployee.empName,
            });

            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to update employee';

      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {
          'action': 'update_employee',
          'employee_id': id,
        },
      );

      return false;
    }
  }

  // Delete employee
  Future<bool> deleteEmployee(String id) async {
    try {
      final result = await _deleteEmployeeUseCase(id);

      return result.fold(
        (failure) {
          _errorMessage = _getFailureMessage(failure);

          AnalyticsService.trackEvent('employee_delete_failed', {
            'failure_type': failure.runtimeType.toString(),
            'employee_id': id,
          });

          return false;
        },
        (_) {
          _employees.removeWhere((e) => e.employeeId == id);
          _filteredEmployees.removeWhere((e) => e.employeeId == id);

          // Clear selected employee if it was deleted
          if (_selectedEmployee?.employeeId == id) {
            _selectedEmployee = null;
          }

          AnalyticsService.trackEvent('employee_deleted', {
            'employee_id': id,
          });

          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to delete employee';

      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {
          'action': 'delete_employee',
          'employee_id': id,
        },
      );

      return false;
    }
  }

  // Search employees
  Future<void> searchEmployees(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredEmployees.clear();
      notifyListeners();
      return;
    }

    try {
      final result = await _searchEmployeesUseCase(query);

      result.fold(
        (failure) {
          _errorMessage = _getFailureMessage(failure);
          _filteredEmployees.clear();

          AnalyticsService.trackEvent('employee_search_failed', {
            'query': query,
            'failure_type': failure.runtimeType.toString(),
          });
        },
        (searchResults) {
          _filteredEmployees = searchResults;

          AnalyticsService.trackEvent('employees_searched', {
            'query': query,
            'results_count': searchResults.length,
          });
        },
      );
    } catch (e) {
      _errorMessage = 'Search failed';
      _filteredEmployees.clear();

      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {
          'action': 'search_employees',
          'query': query,
        },
      );
    }

    notifyListeners();
  }

  // Get employee by ID
  Future<void> getEmployeeById(String id) async {
    try {
      final result = await _getEmployeeByIdUseCase(id);

      result.fold(
        (failure) {
          _errorMessage = _getFailureMessage(failure);
          _selectedEmployee = null;

          AnalyticsService.trackEvent('employee_get_by_id_failed', {
            'employee_id': id,
            'failure_type': failure.runtimeType.toString(),
          });
        },
        (employee) {
          _selectedEmployee = employee;

          AnalyticsService.trackEvent('employee_selected', {
            'employee_id': id,
            'employee_name': employee.empName,
          });
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to get employee';
      _selectedEmployee = null;

      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {
          'action': 'get_employee_by_id',
          'employee_id': id,
        },
      );
    }

    notifyListeners();
  }

  // Apply sorting
  void applySorting(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    _sortAscending = ascending ?? !_sortAscending;
    _applyFiltersAndSort();

    AnalyticsService.trackEvent('employees_sorted', {
      'sort_by': sortBy,
      'ascending': _sortAscending,
    });

    notifyListeners();
  }

  // Apply filters
  void applyFilters(Map<String, dynamic> filters) {
    _filters = Map.from(filters);
    _applyFiltersAndSort();

    AnalyticsService.trackEvent('employees_filtered', {
      'filters': filters,
      'filtered_count': _filteredEmployees.length,
    });

    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _filters.clear();
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredEmployees.clear();
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Select employee
  void selectEmployee(Employee employee) {
    _selectedEmployee = employee;

    AnalyticsService.trackEvent('employee_selected', {
      'employee_id': employee.employeeId,
      'employee_name': employee.empName,
    });

    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedEmployee = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Private methods
  void _applyFiltersAndSort() {
    List<Employee> workingList = List.from(_employees);

    // Apply department filters
    if (_selectedDepartments.isNotEmpty) {
      workingList = workingList.where((employee) {
        return _selectedDepartments.contains(employee.department);
      }).toList();
    }

    // Apply designation filters
    if (_selectedDesignations.isNotEmpty) {
      workingList = workingList.where((employee) {
        return _selectedDesignations.contains(employee.empDesignation);
      }).toList();
    }

    // Apply experience range filter
    if (_experienceRange != null) {
      workingList = workingList.where((employee) {
        return employee.empExp >= _experienceRange!.start.round() &&
            employee.empExp <= _experienceRange!.end.round();
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      workingList = workingList.where((employee) {
        final query = _searchQuery.toLowerCase();
        return employee.empName.toLowerCase().contains(query) ||
            employee.empEmail.toLowerCase().contains(query) ||
            employee.employeeId.toLowerCase().contains(query) ||
            employee.empDesignation.toLowerCase().contains(query) ||
            employee.department.toLowerCase().contains(query);
      }).toList();
    }

    // Apply legacy filters for backward compatibility
    if (_filters.isNotEmpty) {
      workingList = workingList.where((employee) {
        bool matches = true;

        if (_filters.containsKey('department') &&
            _filters['department'] != null) {
          matches &= employee.department == _filters['department'];
        }

        if (_filters.containsKey('designation') &&
            _filters['designation'] != null) {
          matches &= employee.empDesignation == _filters['designation'];
        }

        if (_filters.containsKey('minExperience') &&
            _filters['minExperience'] != null) {
          matches &= employee.empExp >= (_filters['minExperience'] as int);
        }

        if (_filters.containsKey('maxExperience') &&
            _filters['maxExperience'] != null) {
          matches &= employee.empExp <= (_filters['maxExperience'] as int);
        }

        return matches;
      }).toList();
    }

    // Apply sorting
    workingList.sort((a, b) {
      dynamic aValue, bValue;

      switch (_sortBy) {
        case 'empName':
          aValue = a.empName.toLowerCase();
          bValue = b.empName.toLowerCase();
          break;
        case 'empEmail':
          aValue = a.empEmail.toLowerCase();
          bValue = b.empEmail.toLowerCase();
          break;
        case 'empDesignation':
          aValue = a.empDesignation.toLowerCase();
          bValue = b.empDesignation.toLowerCase();
          break;
        case 'department':
          aValue = a.department.toLowerCase();
          bValue = b.department.toLowerCase();
          break;
        case 'empExp':
          aValue = a.empExp;
          bValue = b.empExp;
          break;
        case 'joinDate':
          aValue = a.joinDate ?? DateTime(1900);
          bValue = b.joinDate ?? DateTime(1900);
          break;
        default:
          aValue = a.empName.toLowerCase();
          bValue = b.empName.toLowerCase();
      }

      int comparison = aValue.compareTo(bValue);
      return _sortAscending ? comparison : -comparison;
    });

    if (_searchQuery.isEmpty) {
      _filteredEmployees = workingList;
    }
  }

  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred. Please try again later.';
      case NetworkFailure _:
        return 'No internet connection. Please check your network.';
      case CacheFailure _:
        return 'Local storage error occurred.';
      case ValidationFailure _:
        return 'Invalid data provided.';
      case UnauthorizedFailure _:
        return 'You are not authorized to perform this action.';
      case NotFoundFailure _:
        return 'Requested employee not found.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  // Refresh data
  Future<void> refresh() => loadEmployees(refresh: true);

  // Load more for pagination
  Future<void> loadMore() => loadEmployees(refresh: false);

  // Alias for load more to match the screen's expectation
  Future<void> loadMoreEmployees() => loadMore();

  // Filter methods
  void toggleDepartmentFilter(String department) {
    if (_selectedDepartments.contains(department)) {
      _selectedDepartments.remove(department);
    } else {
      _selectedDepartments.add(department);
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  void toggleDesignationFilter(String designation) {
    if (_selectedDesignations.contains(designation)) {
      _selectedDesignations.remove(designation);
    } else {
      _selectedDesignations.add(designation);
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setExperienceFilter(RangeValues range) {
    _experienceRange = range;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearExperienceFilter() {
    _experienceRange = null;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedDepartments.clear();
    _selectedDesignations.clear();
    _experienceRange = null;
    _searchQuery = '';
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Sort methods
  void setSortBy(SortBy sortBy) {
    _currentSortBy = sortBy;
    _sortBy = sortBy.sortKey;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    _applyFiltersAndSort();
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
