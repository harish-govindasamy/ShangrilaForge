import '../../../core/network/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/employee_model.dart';

class EmployeeService {
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  EmployeeService._internal();

  final ApiService _apiService = ApiService();

  // Get all employees
  Future<List<Employee>> getEmployees() async {
    try {
      final response = await _apiService.get(ApiEndpoints.employees);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['employees'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch employees');
    } catch (e) {
      throw Exception('Error fetching employees: $e');
    }
  }

  // Get employee by ID
  Future<Employee> getEmployeeById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.employeeById(id));
      if (response.statusCode == 200) {
        return Employee.fromJson(response.data);
      }
      throw Exception('Failed to fetch employee');
    } catch (e) {
      throw Exception('Error fetching employee: $e');
    }
  }

  // Create new employee
  Future<Employee> createEmployee(Employee employee) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.createEmployee,
        data: employee.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Employee.fromJson(response.data);
      }
      throw Exception('Failed to create employee');
    } catch (e) {
      throw Exception('Error creating employee: $e');
    }
  }

  // Update employee
  Future<Employee> updateEmployee(String id, Employee employee) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateEmployee(id),
        data: employee.toJson(),
      );
      if (response.statusCode == 200) {
        return Employee.fromJson(response.data);
      }
      throw Exception('Failed to update employee');
    } catch (e) {
      throw Exception('Error updating employee: $e');
    }
  }

  // Delete employee
  Future<void> deleteEmployee(String id) async {
    try {
      final response =
          await _apiService.delete(ApiEndpoints.deleteEmployee(id));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete employee');
      }
    } catch (e) {
      throw Exception('Error deleting employee: $e');
    }
  }

  // Search employees
  Future<List<Employee>> searchEmployees(String query) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.employees,
        queryParameters: {'search': query},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['employees'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      throw Exception('Failed to search employees');
    } catch (e) {
      throw Exception('Error searching employees: $e');
    }
  }

  // Get employees by designation
  Future<List<Employee>> getEmployeesByDesignation(String designation) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.employees,
        queryParameters: {'designation': designation},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['employees'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch employees by designation');
    } catch (e) {
      throw Exception('Error fetching employees by designation: $e');
    }
  }
}
