import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/employee_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  Employee? _employee;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  Employee? get employee => _employee;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  UserRole get userRole => _user?.role ?? UserRole.employee;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _user = _authService.currentUser;
    _employee = _authService.currentEmployee;
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email, password);
      
      if (result.isSuccess) {
        _user = result.user;
        _employee = _authService.currentEmployee;
        notifyListeners();
        return true;
      } else {
        _setError(result.errorMessage ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _user = null;
      _employee = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.changePassword(currentPassword, newPassword);
      
      if (result.isSuccess) {
        _user = result.user;
        notifyListeners();
        return true;
      } else {
        _setError(result.errorMessage ?? 'Password change failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final isAuthenticated = await _authService.checkAuthStatus();
      
      if (isAuthenticated) {
        _user = _authService.currentUser;
        _employee = _authService.currentEmployee;
        notifyListeners();
        return true;
      } else {
        _user = null;
        _employee = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool hasPermission(String permission) {
    return _authService.hasPermission(permission);
  }

  bool canAccessEmployee(String employeeId) {
    return _authService.canAccessEmployee(employeeId);
  }

  bool canAccessProject(String projectId) {
    return _authService.canAccessProject(projectId);
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
