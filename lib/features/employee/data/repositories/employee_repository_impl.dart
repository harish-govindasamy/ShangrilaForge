import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/domain/repositories/employee_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/employee_model.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/monitoring/error_reporter.dart';
import '../../../../core/monitoring/analytics_service.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;
  final Connectivity _connectivity;

  EmployeeRepositoryImpl({
    ApiService? apiService,
    LocalStorageService? localStorageService,
    Connectivity? connectivity,
  })  : _apiService = apiService ?? ApiService(),
        _localStorageService = localStorageService ?? LocalStorageService(),
        _connectivity = connectivity ?? Connectivity();

  @override
  Future<Either<Failure, List<Employee>>> getEmployees() async {
    try {
      // First, try to get from local storage
      final localEmployees = await _localStorageService.getEmployees();

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final response = await _apiService.get('/employees');
          if (response.statusCode == 200) {
            final List<dynamic> data = response.data['data'] ?? response.data;
            final employees =
                data.map((json) => Employee.fromJson(json)).toList();

            // Save to local storage for offline access
            await _localStorageService.saveEmployees(employees);

            AnalyticsService.trackEvent('employees_fetched_online', {
              'count': employees.length,
            });

            return Right(employees);
          } else {
            return Left(ServerFailure(
              message: 'Failed to fetch employees: ${response.statusCode}',
            ));
          }
        } catch (e) {
          await ErrorReporter.reportError(
            e,
            StackTrace.current,
            context: {
              'action': 'fetch_employees_online',
              'fallback_to_local': localEmployees.isNotEmpty,
            },
          );

          if (localEmployees.isNotEmpty) {
            return Right(localEmployees);
          } else {
            return const Left(NetworkFailure(
                message: 'Network error and no local data available'));
          }
        }
      } else {
        if (localEmployees.isNotEmpty) {
          return Right(localEmployees);
        } else {
          return const Left(NetworkFailure(
              message: 'No internet connection and no local data available'));
        }
      }
    } catch (e) {
      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {'action': 'get_employees'},
      );

      return Left(
          CacheFailure(message: 'Failed to get employees: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Employee>> getEmployeeById(String id) async {
    try {
      // First check local storage
      final localEmployees = await _localStorageService.getEmployees();
      final localEmployee =
          localEmployees.where((e) => e.employeeId == id).firstOrNull;

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final response = await _apiService.get('/employees/$id');
          if (response.statusCode == 200) {
            final employee = Employee.fromJson(response.data);

            // Update local storage
            final updatedEmployees = localEmployees.map((e) {
              return e.employeeId == id ? employee : e;
            }).toList();

            if (!updatedEmployees.any((e) => e.employeeId == id)) {
              updatedEmployees.add(employee);
            }

            await _localStorageService.saveEmployees(updatedEmployees);

            return Right(employee);
          } else if (response.statusCode == 404) {
            return const Left(NotFoundFailure(message: 'Employee not found'));
          } else {
            if (localEmployee != null) {
              return Right(localEmployee);
            }
            return const Left(
                ServerFailure(message: 'Failed to fetch employee'));
          }
        } catch (e) {
          if (localEmployee != null) {
            return Right(localEmployee);
          }
          rethrow;
        }
      } else {
        if (localEmployee != null) {
          return Right(localEmployee);
        }
      }

      await ErrorReporter.reportError(
        Exception('Employee not found'),
        StackTrace.current,
        context: {'action': 'get_employee_by_id', 'employee_id': id},
      );

      return const Left(NotFoundFailure(message: 'Employee not found'));
    } catch (e) {
      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {'action': 'get_employee_by_id', 'employee_id': id},
      );

      return const Left(NotFoundFailure(message: 'Employee not found'));
    }
  }

  @override
  Future<Either<Failure, Employee>> createEmployee(Employee employee) async {
    try {
      // Save optimistically to local storage first
      final localEmployees = await _localStorageService.getEmployees();
      localEmployees.add(employee);
      await _localStorageService.saveEmployees(localEmployees);

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final response = await _apiService.post(
            '/employees',
            data: employee.toJson(),
          );

          if (response.statusCode == 201 || response.statusCode == 200) {
            final createdEmployee = Employee.fromJson(response.data);

            // Update local storage with server response
            final updatedEmployees = localEmployees.map((e) {
              return e.empName == employee.empName ? createdEmployee : e;
            }).toList();

            await _localStorageService.saveEmployees(updatedEmployees);

            AnalyticsService.trackEvent('employee_created', {
              'employee_id': createdEmployee.employeeId,
            });

            return Right(createdEmployee);
          } else {
            return Left(ServerFailure(
              message: 'Failed to create employee: ${response.statusCode}',
            ));
          }
        } catch (e) {
          await ErrorReporter.reportError(
            e,
            StackTrace.current,
            context: {
              'action': 'create_employee_online',
              'employee_name': employee.empName,
            },
          );

          // Return the optimistically saved employee
          return Right(employee);
        }
      } else {
        // Offline mode - return the optimistically saved employee
        return Right(employee);
      }
    } catch (e) {
      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {
          'action': 'create_employee',
          'employee_name': employee.empName
        },
      );

      return Left(
          CacheFailure(message: 'Failed to create employee: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Employee>> updateEmployee(
      String id, Employee employee) async {
    try {
      // Check if employee exists locally
      final localEmployees = await _localStorageService.getEmployees();
      final existingIndex =
          localEmployees.indexWhere((e) => e.employeeId == id);

      if (existingIndex == -1) {
        return const Left(NotFoundFailure(message: 'Employee not found'));
      }

      // Update optimistically in local storage
      localEmployees[existingIndex] = employee;
      await _localStorageService.saveEmployees(localEmployees);

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final response = await _apiService.put(
            '/employees/$id',
            data: employee.toJson(),
          );

          if (response.statusCode == 200) {
            final updatedEmployee = Employee.fromJson(response.data);

            // Update local storage with server response
            localEmployees[existingIndex] = updatedEmployee;
            await _localStorageService.saveEmployees(localEmployees);

            AnalyticsService.trackEvent('employee_updated', {
              'employee_id': id,
            });

            return Right(updatedEmployee);
          } else {
            return Left(ServerFailure(
              message: 'Failed to update employee: ${response.statusCode}',
            ));
          }
        } catch (e) {
          await ErrorReporter.reportError(
            e,
            StackTrace.current,
            context: {
              'action': 'update_employee_online',
              'employee_id': id,
            },
          );

          // Return the optimistically updated employee
          return Right(employee);
        }
      } else {
        // Offline mode - return the optimistically updated employee
        return Right(employee);
      }
    } catch (e) {
      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {'action': 'update_employee', 'employee_id': id},
      );

      return Left(
          CacheFailure(message: 'Failed to update employee: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEmployee(String id) async {
    try {
      // Remove from local storage first
      final localEmployees = await _localStorageService.getEmployees();
      localEmployees.removeWhere((e) => e.employeeId == id);
      await _localStorageService.saveEmployees(localEmployees);

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final response = await _apiService.delete('/employees/$id');

          if (response.statusCode == 200 || response.statusCode == 204) {
            AnalyticsService.trackEvent('employee_deleted', {
              'employee_id': id,
            });

            return const Right(null);
          } else {
            return Left(ServerFailure(
              message: 'Failed to delete employee: ${response.statusCode}',
            ));
          }
        } catch (e) {
          await ErrorReporter.reportError(
            e,
            StackTrace.current,
            context: {
              'action': 'delete_employee_online',
              'employee_id': id,
            },
          );

          // Employee already removed from local storage
          return const Right(null);
        }
      } else {
        // Offline mode - employee already removed from local storage
        return const Right(null);
      }
    } catch (e) {
      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {'action': 'delete_employee', 'employee_id': id},
      );

      return Left(
          CacheFailure(message: 'Failed to delete employee: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Employee>>> searchEmployees(String query) async {
    try {
      final localEmployees = await _localStorageService.getEmployees();

      // Local search
      final localResults = localEmployees.where((employee) {
        return employee.empName.toLowerCase().contains(query.toLowerCase()) ||
            employee.empEmail.toLowerCase().contains(query.toLowerCase()) ||
            employee.empDesignation
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            employee.department.toLowerCase().contains(query.toLowerCase());
      }).toList();

      // Check connectivity for online search
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final response = await _apiService.get(
            '/employees/search',
            queryParameters: {'q': query},
          );

          if (response.statusCode == 200) {
            final List<dynamic> data = response.data['data'] ?? response.data;
            final onlineResults =
                data.map((json) => Employee.fromJson(json)).toList();

            AnalyticsService.trackEvent('employees_searched_online', {
              'query': query,
              'results_count': onlineResults.length,
            });

            return Right(onlineResults);
          }
        } catch (e) {
          // Fall back to local search
          AnalyticsService.trackEvent('employee_search_fallback_to_local', {
            'query': query,
            'local_results_count': localResults.length,
          });
        }
      }

      return Right(localResults);
    } catch (e) {
      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {'action': 'search_employees', 'query': query},
      );

      return Left(
          CacheFailure(message: 'Failed to search employees: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncWithRemote() async {
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        return const Left(
            NetworkFailure(message: 'No internet connection for sync'));
      }

      // Get all employees from server
      final response = await _apiService.get('/employees');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final employees = data.map((json) => Employee.fromJson(json)).toList();

        // Save to local storage
        await _localStorageService.saveEmployees(employees);

        AnalyticsService.trackEvent('employees_synced', {
          'count': employees.length,
        });

        return const Right(null);
      } else {
        return const Left(ServerFailure(message: 'Failed to sync with remote'));
      }
    } catch (e) {
      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {'action': 'sync_with_remote'},
      );

      return Left(NetworkFailure(
          message: 'Failed to sync with remote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Employee>>> getEmployeesByIds(
      List<String> ids) async {
    try {
      final localEmployees = await _localStorageService.getEmployees();
      final filteredEmployees =
          localEmployees.where((e) => ids.contains(e.employeeId)).toList();

      return Right(filteredEmployees);
    } catch (e) {
      await ErrorReporter.reportError(
        e,
        StackTrace.current,
        context: {'action': 'get_employees_by_ids', 'ids': ids},
      );

      return Left(CacheFailure(
          message: 'Failed to get employees by ids: ${e.toString()}'));
    }
  }
}
