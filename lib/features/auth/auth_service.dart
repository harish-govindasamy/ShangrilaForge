import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/employee_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  User? _currentUser;
  Employee? _currentEmployee;

  User? get currentUser => _currentUser;
  Employee? get currentEmployee => _currentEmployee;

  bool get isLoggedIn => _currentUser != null;

  UserRole get currentUserRole => _currentUser?.role ?? UserRole.employee;

  // Login
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        final employeeData = data['employee'] as Map<String, dynamic>?;

        // Set auth token
        await _apiService.setAuthToken(token);

        // Parse user data
        _currentUser = User.fromJson(userData);
        if (employeeData != null) {
          _currentEmployee = Employee.fromJson(employeeData);
        }

        // Save user data locally
        await _saveUserDataLocally();

        return AuthResult.success(_currentUser!);
      } else {
        return AuthResult.failure('Invalid credentials');
      }
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _clearUserData();
    }
  }

  // Change Password
  Future<AuthResult> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return AuthResult.success(_currentUser!);
      } else {
        return AuthResult.failure('Failed to change password');
      }
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // Check if user is logged in
  Future<bool> checkAuthStatus() async {
    try {
      final token = await _apiService.getAuthToken();
      if (token == null) return false;

      // Verify token with server
      final response = await _apiService.get('/auth/verify');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _currentUser = User.fromJson(data['user']);
        if (data['employee'] != null) {
          _currentEmployee = Employee.fromJson(data['employee']);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Load user data from local storage
  Future<void> loadUserDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConstants.userDataKey);
      final employeeDataString = prefs.getString(AppConstants.employeeDataKey);

      if (userDataString != null) {
        final userData = json.decode(userDataString);
        _currentUser = User.fromJson(userData);
      }

      if (employeeDataString != null) {
        final employeeData = json.decode(employeeDataString);
        _currentEmployee = Employee.fromJson(employeeData);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Save user data locally
  Future<void> _saveUserDataLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentUser != null) {
        await prefs.setString(
          AppConstants.userDataKey,
          json.encode(_currentUser!.toJson()),
        );
      }

      if (_currentEmployee != null) {
        await prefs.setString(
          AppConstants.employeeDataKey,
          json.encode(_currentEmployee!.toJson()),
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear user data
  Future<void> _clearUserData() async {
    _currentUser = null;
    _currentEmployee = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userDataKey);
    await prefs.remove(AppConstants.employeeDataKey);
    await prefs.remove(AppConstants.userRoleKey);
    
    await _apiService.clearAuthToken();
  }

  // Check if user has permission
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    switch (_currentUser!.role) {
      case UserRole.admin:
        return true; // Admin has all permissions
      case UserRole.principal:
        return permission != 'admin_only';
      case UserRole.employee:
        return permission == 'employee_only' || permission == 'read_only';
    }
  }

  // Check if user can access employee data
  bool canAccessEmployee(String employeeId) {
    if (_currentUser == null) return false;

    switch (_currentUser!.role) {
      case UserRole.admin:
        return true;
      case UserRole.principal:
        return true; // Principal can access all employees
      case UserRole.employee:
        return _currentEmployee?.employeeId == employeeId;
    }
  }

  // Check if user can access project
  bool canAccessProject(String projectId) {
    if (_currentUser == null) return false;

    switch (_currentUser!.role) {
      case UserRole.admin:
      case UserRole.principal:
        return true;
      case UserRole.employee:
        // Employee can only access assigned projects
        // This would need to be checked against project assignments
        return true; // Simplified for now
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(User user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(isSuccess: false, errorMessage: errorMessage);
  }
}
