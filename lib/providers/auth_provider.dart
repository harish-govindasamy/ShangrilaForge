import 'package:flutter/material.dart';
import '../shared/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  String? _token;
  String? _error;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      _user = User(
        userId: '1',
        userName: 'John Doe',
        employeeId: 'EMP001',
        role: UserRole.employee,
        password: '',
        newPassword: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
        updatedBy: 'system',
      );
      _isAuthenticated = true;
      _token = 'mock_token';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _isAuthenticated = false;
    _token = null;
    notifyListeners();
  }

  Future<bool> register(String userName, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful registration
      _user = User(
        userId: '1',
        userName: userName,
        employeeId: 'EMP001',
        role: UserRole.employee,
        password: '',
        newPassword: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
        updatedBy: 'system',
      );
      _isAuthenticated = true;
      _token = 'mock_token';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkAuth() async {
    // TODO: Check if token is valid and get user info
    await Future.delayed(const Duration(milliseconds: 500));

    // For now, always return false to show login screen
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
