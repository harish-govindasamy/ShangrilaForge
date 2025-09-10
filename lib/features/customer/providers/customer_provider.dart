import 'package:flutter/material.dart';
import '../services/customer_service.dart';
import '../../../shared/models/customer_model.dart';
import '../../../core/services/local_storage_service.dart';
import 'package:logging/logging.dart';

class CustomerProvider extends ChangeNotifier {
  static final Logger _logger = Logger('CustomerProvider');
  final CustomerService _customerService = CustomerService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Get all customers
  Future<void> loadCustomers() async {
    _setLoading(true);
    _clearError();

    try {
      // First load from local storage
      _customers = await _localStorageService.getCustomers();
      notifyListeners();

      // Then try to sync with API
      try {
        final apiCustomers = await _customerService.getCustomers();
        _customers = apiCustomers;
        await _localStorageService.saveCustomers(_customers);
        notifyListeners();
      } catch (apiError) {
        // API failed, but we have local data
        if (_customers.isEmpty) {
          rethrow;
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get customer by ID
  Future<void> loadCustomerById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // First try local storage
      final localCustomers = await _localStorageService.getCustomers();
      _selectedCustomer = localCustomers.firstWhere(
        (cust) => cust.customerId == id,
        orElse: () => throw Exception('Customer not found'),
      );
      notifyListeners();

      // Then try API
      try {
        _selectedCustomer = await _customerService.getCustomerById(id);
        notifyListeners();
      } catch (apiError) {
        // API failed, but we have local data
        if (_selectedCustomer == null) {
          rethrow;
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create customer
  Future<bool> createCustomer(Customer customer) async {
    _setLoading(true);
    _clearError();

    try {
      // Add to local storage first
      _customers.add(customer);
      await _localStorageService.saveCustomers(_customers);
      notifyListeners();

      // Try to sync with API
      try {
        final newCustomer = await _customerService.createCustomer(customer);
        // Update with server response
        final index =
            _customers.indexWhere((c) => c.customerId == customer.customerId);
        if (index != -1) {
          _customers[index] = newCustomer;
          await _localStorageService.saveCustomers(_customers);
          notifyListeners();
        }
      } catch (apiError) {
        // API failed, but local save succeeded
        _logger.warning('API sync failed: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update customer
  Future<bool> updateCustomer(String id, Customer customer) async {
    _setLoading(true);
    _clearError();

    try {
      // Update locally first
      final index = _customers.indexWhere((cust) => cust.customerId == id);
      if (index != -1) {
        _customers[index] = customer;
        await _localStorageService.saveCustomers(_customers);
      }
      if (_selectedCustomer?.customerId == id) {
        _selectedCustomer = customer;
      }
      notifyListeners();

      // Try to sync with API
      try {
        final updatedCustomer =
            await _customerService.updateCustomer(id, customer);
        // Update with server response
        if (index != -1) {
          _customers[index] = updatedCustomer;
          await _localStorageService.saveCustomers(_customers);
        }
        if (_selectedCustomer?.customerId == id) {
          _selectedCustomer = updatedCustomer;
        }
        notifyListeners();
      } catch (apiError) {
        _logger.warning('API sync failed: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Remove locally first
      _customers.removeWhere((cust) => cust.customerId == id);
      await _localStorageService.saveCustomers(_customers);
      if (_selectedCustomer?.customerId == id) {
        _selectedCustomer = null;
      }
      notifyListeners();

      // Try to sync with API
      try {
        await _customerService.deleteCustomer(id);
      } catch (apiError) {
        _logger.warning('API sync failed: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search customers
  Future<void> searchCustomers(String query) async {
    _searchQuery = query;
    _setLoading(true);
    _clearError();

    try {
      if (query.isEmpty) {
        _customers = await _localStorageService.getCustomers();
      } else {
        try {
          _customers = await _customerService.searchCustomers(query);
        } catch (apiError) {
          // Fallback to local search
          final localCustomers = await _localStorageService.getCustomers();
          _customers = localCustomers
              .where((cust) =>
                  cust.custName.toLowerCase().contains(query.toLowerCase()) ||
                  cust.custEmail.toLowerCase().contains(query.toLowerCase()) ||
                  cust.custCode.toLowerCase().contains(query.toLowerCase()) ||
                  cust.customerId.toLowerCase().contains(query.toLowerCase()))
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

  // Set selected customer
  void setSelectedCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  // Get filtered customers
  List<Customer> get filteredCustomers {
    if (_searchQuery.isEmpty) {
      return _customers;
    }

    return _customers
        .where((customer) =>
            customer.custName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            customer.custEmail
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            customer.custCode
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            customer.customerId
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
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
