import 'package:dio/dio.dart';
import '../../core/network/api_service.dart';
import '../../core/config/api_constants.dart';
import '../../shared/models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<Project>> getAllProjects();
  Future<List<Project>> getActiveProjects();
  Future<List<Project>> getArchivedProjects();
  Future<Project?> getProjectById(String projectId);
  Future<List<Project>> getProjectsByCustomerId(String customerId);
  Future<List<Project>> getProjectsByEmployeeId(String employeeId);
  Future<Project> createProject(Project project);
  Future<Project> updateProject(Project project);
  Future<void> deleteProject(String projectId);
  Future<List<Project>> searchProjects(String query);
  Future<List<Project>> getProjectsByStatus(ProjectStatus status);
  Future<List<Project>> getProjectsByPriority(ProjectPriority priority);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiService _apiService;

  ProjectRemoteDataSourceImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<List<Project>> getAllProjects() async {
    try {
      final response = await _apiService.get(ApiConstants.projects);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch projects: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to fetch projects: $e');
    }
  }

  @override
  Future<List<Project>> getActiveProjects() async {
    try {
      final response = await _apiService.get('${ApiConstants.projects}/active');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch active projects: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to fetch active projects: $e');
    }
  }

  @override
  Future<List<Project>> getArchivedProjects() async {
    try {
      final response = await _apiService.get('${ApiConstants.projects}/archived');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch archived projects: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to fetch archived projects: $e');
    }
  }

  @override
  Future<Project?> getProjectById(String projectId) async {
    try {
      final response = await _apiService.get('${ApiConstants.projectById}/$projectId');
      
      if (response.statusCode == 200) {
        return Project.fromJson(response.data['data'] ?? response.data);
      }
      
      if (response.statusCode == 404) {
        return null;
      }
      
      throw Exception('Failed to fetch project: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          return null;
        }
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to fetch project: $e');
    }
  }

  @override
  Future<List<Project>> getProjectsByCustomerId(String customerId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.projects}/customer/$customerId',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch projects by customer: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to fetch projects by customer: $e');
    }
  }

  @override
  Future<List<Project>> getProjectsByEmployeeId(String employeeId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.projects}/employee/$employeeId',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch projects by employee: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to fetch projects by employee: $e');
    }
  }

  @override
  Future<Project> createProject(Project project) async {
    try {
      final response = await _apiService.post(
        ApiConstants.projects,
        data: project.toJson(),
      );
      
      if (response.statusCode == 201) {
        return Project.fromJson(response.data['data'] ?? response.data);
      }
      
      throw Exception('Failed to create project: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to create project: $e');
    }
  }

  @override
  Future<Project> updateProject(Project project) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.projectById}/${project.projectId}',
        data: project.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Project.fromJson(response.data['data'] ?? response.data);
      }
      
      throw Exception('Failed to update project: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to update project: $e');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      final response = await _apiService.delete('${ApiConstants.projectById}/$projectId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete project: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to delete project: $e');
    }
  }

  @override
  Future<List<Project>> searchProjects(String query) async {
    try {
      final response = await _apiService.get(
        ApiConstants.projectSearch,
        queryParameters: {'q': query},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      
      throw Exception('Failed to search projects: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to search projects: $e');
    }
  }

  @override
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    try {
      final response = await _apiService.get(
        ApiConstants.projectsByStatus,
        queryParameters: {'status': status.name},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch projects by status: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to fetch projects by status: $e');
    }
  }

  @override
  Future<List<Project>> getProjectsByPriority(ProjectPriority priority) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.projects}/priority/${priority.name}',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch projects by priority: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Failed to fetch projects by priority: $e');
    }
  }
}
