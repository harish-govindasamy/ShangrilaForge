import '../../../core/network/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/user_model.dart';
import 'package:logging/logging.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  static final Logger _logger = Logger('UserService');
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _apiService = ApiService();

  // Get all users (Admin only)
  Future<List<User>> getUsers() async {
    try {
      final response = await _apiService.get(ApiEndpoints.users);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['users'] ?? response.data['data'] ?? response.data;
        return data.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch users');
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Get user by ID
  Future<User> getUserById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.userById(id));
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Failed to fetch user');
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Create user (Admin only - linked to employee)
  Future<User> createUser(User user) async {
    try {
      // Check user count limit (200 users max)
      final existingUsers = await getUsers();
      if (existingUsers.length >= 200) {
        throw Exception(
            'User limit reached (200). Admin will be notified via email.');
      }

      final response = await _apiService.post(
        ApiEndpoints.createUser,
        data: user.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdUser = User.fromJson(response.data);

        // Send email notification with credentials
        await _sendCredentialsEmail(createdUser);

        return createdUser;
      }
      throw Exception('Failed to create user');
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  // Update user
  Future<User> updateUser(String id, User user) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateUser(id),
        data: user.toJson(),
      );
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Failed to update user');
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Delete user (Admin only)
  Future<bool> deleteUser(String id) async {
    try {
      final response = await _apiService.delete(ApiEndpoints.deleteUser(id));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // Reset password (Admin only)
  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.resetPassword,
        data: {
          'userId': userId,
          'new_password': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error resetting password: $e');
    }
  }

  // Change password (User own)
  Future<bool> changePassword(
      String userId, String oldPassword, String newPassword) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.changePassword,
        data: {
          'userId': userId,
          'password': oldPassword,
          'new_password': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }

  // Get users by role
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.users,
        queryParameters: {'role': role.name},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['users'] ?? response.data['data'] ?? response.data;
        return data.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch users by role');
    } catch (e) {
      throw Exception('Error fetching users by role: $e');
    }
  }

  // Check user permissions based on RBAC
  bool hasPermission(UserRole userRole, String permission) {
    switch (userRole) {
      case UserRole.admin:
        return true; // Admin has all permissions
      case UserRole.principal:
        return ![
          'delete_employee',
          'delete_project',
          'delete_customer',
          'manage_users',
          'system_settings'
        ].contains(permission);
      case UserRole.employee:
        return [
          'view_own_profile',
          'edit_own_profile',
          'view_assigned_projects',
          'create_timesheet',
          'edit_own_timesheet',
          'view_own_timesheet'
        ].contains(permission);
    }
  }

  // Send credentials email (mock implementation)
  Future<void> _sendCredentialsEmail(User user) async {
    // This would integrate with actual email service
    _logger.info(
        'Sending credentials email to ${user.userName} at employee email');
    // Implementation would use email service like SendGrid, AWS SES, etc.
  }
}
