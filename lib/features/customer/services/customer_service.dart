import '../../../core/network/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/customer_model.dart';
import '../../project/services/project_service.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  final ApiService _apiService = ApiService();
  final ProjectService _projectService = ProjectService();

  // Get all customers
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _apiService.get(ApiEndpoints.customers);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['customers'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Customer.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch customers');
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }

  // Get customer by ID
  Future<Customer> getCustomerById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.customerById(id));
      if (response.statusCode == 200) {
        return Customer.fromJson(response.data);
      }
      throw Exception('Failed to fetch customer');
    } catch (e) {
      throw Exception('Error fetching customer: $e');
    }
  }

  // Create new customer with auto-incremented customer code
  Future<Customer> createCustomer(Customer customer) async {
    try {
      // Get existing customers to generate next customer code
      final existingCustomers = await getCustomers();
      final nextCustCode = _generateNextCustomerCode(existingCustomers);

      // Create customer with generated code
      final customerWithCode = customer.copyWith(
        custCode: nextCustCode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _apiService.post(
        ApiEndpoints.createCustomer,
        data: customerWithCode.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Customer.fromJson(response.data);
      }
      throw Exception('Failed to create customer');
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }

  // Update customer
  Future<Customer> updateCustomer(String id, Customer customer) async {
    try {
      final updatedCustomer = customer.copyWith(
        updatedAt: DateTime.now(),
      );

      final response = await _apiService.put(
        ApiEndpoints.updateCustomer(id),
        data: updatedCustomer.toJson(),
      );

      if (response.statusCode == 200) {
        return Customer.fromJson(response.data);
      }
      throw Exception('Failed to update customer');
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  // Delete customer with active project validation
  Future<void> deleteCustomer(String id) async {
    try {
      // Check if customer has active projects
      final hasActiveProjects = await _projectService.hasActiveProjects(id);

      if (hasActiveProjects) {
        throw Exception(
            'Cannot delete customer with active projects. Please archive customer instead.');
      }

      final response =
          await _apiService.delete(ApiEndpoints.deleteCustomer(id));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete customer');
      }
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }

  // Archive customer (soft delete) - preferred method for customers with projects
  Future<Customer> archiveCustomer(String id) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateCustomer(id),
        data: {
          'archived': true,
          'archivedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return Customer.fromJson(response.data);
      }
      throw Exception('Failed to archive customer');
    } catch (e) {
      throw Exception('Error archiving customer: $e');
    }
  }

  // Get active customers (non-archived)
  Future<List<Customer>> getActiveCustomers() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.customers,
        queryParameters: {'archived': 'false'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['customers'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Customer.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch active customers');
    } catch (e) {
      throw Exception('Error fetching active customers: $e');
    }
  }

  // Search customers
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.customers,
        queryParameters: {'search': query},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['customers'] ??
            response.data['data'] ??
            response.data;
        return data.map((json) => Customer.fromJson(json)).toList();
      }
      throw Exception('Failed to search customers');
    } catch (e) {
      throw Exception('Error searching customers: $e');
    }
  }

  // Get customer statistics for reporting
  Future<Map<String, dynamic>> getCustomerStatistics() async {
    try {
      final customers = await getCustomers();
      final activeCustomers = await getActiveCustomers();

      return {
        'total': customers.length,
        'active': activeCustomers.length,
        'archived': customers.length - activeCustomers.length,
      };
    } catch (e) {
      throw Exception('Error fetching customer statistics: $e');
    }
  }

  // Validate customer for project creation
  Future<bool> validateCustomerForProject(String customerId) async {
    try {
      await getCustomerById(customerId);
      // Check if customer is active (not archived)
      return true; // Customer exists and is accessible
    } catch (e) {
      return false; // Customer doesn't exist or is not accessible
    }
  }

  // Generate next customer code (CUST001, CUST002, etc.)
  String _generateNextCustomerCode(List<Customer> existingCustomers) {
    if (existingCustomers.isEmpty) {
      return 'CUST001';
    }

    int highestNumber = 0;
    for (final customer in existingCustomers) {
      final codeNumber = customer.custCode.replaceAll(RegExp(r'[^0-9]'), '');
      if (codeNumber.isNotEmpty) {
        final number = int.tryParse(codeNumber) ?? 0;
        if (number > highestNumber) {
          highestNumber = number;
        }
      }
    }

    final nextNumber = (highestNumber + 1).toString().padLeft(3, '0');
    return 'CUST$nextNumber';
  }

  // Check if customer code is unique
  Future<bool> isCustomerCodeUnique(String custCode) async {
    try {
      final customers = await getCustomers();
      return !customers.any((customer) => customer.custCode == custCode);
    } catch (e) {
      return false;
    }
  }
}
