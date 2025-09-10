import '../../../core/network/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/email_notification_service.dart';
import '../../../shared/models/project_model.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final ApiService _apiService = ApiService();
  final EmailNotificationService _emailService = EmailNotificationService();

  // Get all projects
  Future<List<Project>> getProjects() async {
    try {
      final response = await _apiService.get(ApiEndpoints.projects);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['projects'] ?? response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch projects');
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  // Get project by ID
  Future<Project> getProjectById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.projectById(id));
      if (response.statusCode == 200) {
        return Project.fromJson(response.data);
      }
      throw Exception('Failed to fetch project');
    } catch (e) {
      throw Exception('Error fetching project: $e');
    }
  }

  // Create new project with job code generation and email notification
  Future<Project> createProject(Project project, String customerCode) async {
    try {
      // Get existing projects to generate unique job code
      final existingProjects = await getProjects();
      final existingJobCodes = existingProjects.map((p) => p.jobCode).toList();

      // Generate initial job code based on customer
      final jobCode =
          Project.generateInitialJobCode(customerCode, existingJobCodes);

      // Ensure uniqueness
      if (!Project.isJobCodeUnique(jobCode, existingJobCodes)) {
        throw Exception('Unable to generate unique job code');
      }

      // Create project with generated job code
      final projectWithJobCode = project.copyWith(jobCode: jobCode);

      final response = await _apiService.post(
        ApiEndpoints.createProject,
        data: projectWithJobCode.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final createdProject = Project.fromJson(response.data);

        // Send email notification to admin about new project
        await _emailService.sendProjectCreatedEmail(
          'admin@shangrilaengineers.com', // This should come from config
          createdProject.jobName,
          createdProject.jobCode,
        );

        return createdProject;
      }
      throw Exception('Failed to create project');
    } catch (e) {
      throw Exception('Error creating project: $e');
    }
  }

  // Update project with job code versioning
  Future<Project> updateProject(String id, Project project) async {
    try {
      // Get current project to generate next version
      final currentProject = await getProjectById(id);

      // Generate next job code version for updates
      final nextJobCode = currentProject.generateNextJobCodeVersion();

      // Get existing projects to ensure uniqueness
      final existingProjects = await getProjects();
      final existingJobCodes = existingProjects.map((p) => p.jobCode).toList();

      // Ensure the new version is unique
      if (!Project.isJobCodeUnique(nextJobCode, existingJobCodes)) {
        throw Exception('Unable to generate unique job code version');
      }

      // Update project with new version
      final updatedProject = project.copyWith(
        jobCode: nextJobCode,
        updatedAt: DateTime.now(),
      );

      final response = await _apiService.put(
        ApiEndpoints.updateProject(id),
        data: updatedProject.toJson(),
      );

      if (response.statusCode == 200) {
        return Project.fromJson(response.data);
      }
      throw Exception('Failed to update project');
    } catch (e) {
      throw Exception('Error updating project: $e');
    }
  }

  // Delete project with validation
  Future<void> deleteProject(String id) async {
    try {
      // Get project to check if it can be deleted
      final project = await getProjectById(id);

      if (!project.canBeDeleted) {
        throw Exception(
            'Cannot delete project with status: ${project.status.name}. Only Open projects can be deleted.');
      }

      final response = await _apiService.delete(ApiEndpoints.deleteProject(id));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete project');
      }
    } catch (e) {
      throw Exception('Error deleting project: $e');
    }
  }

  // Get projects by status
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.projectByStatus(status.name),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch projects by status');
    } catch (e) {
      throw Exception('Error fetching projects by status: $e');
    }
  }

  // Get projects accessible for timesheet entry (excluding completed)
  Future<List<Project>> getAccessibleProjectsForTimesheet() async {
    try {
      final allProjects = await getProjects();
      return allProjects
          .where((project) => project.isAccessibleForTimesheet)
          .toList();
    } catch (e) {
      throw Exception('Error fetching accessible projects: $e');
    }
  }

  // Search projects
  Future<List<Project>> searchProjects(String query) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.projects,
        queryParameters: {'search': query},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      throw Exception('Failed to search projects');
    } catch (e) {
      throw Exception('Error searching projects: $e');
    }
  }

  // Get projects by customer
  Future<List<Project>> getProjectsByCustomer(String customerId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.projects,
        queryParameters: {'customer_id': customerId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch projects by customer');
    } catch (e) {
      throw Exception('Error fetching projects by customer: $e');
    }
  }

  // Update project status with validation
  Future<Project> updateProjectStatus(String id, ProjectStatus status) async {
    try {
      final currentProject = await getProjectById(id);

      // Generate next job code version for status updates
      final nextJobCode = currentProject.generateNextJobCodeVersion();

      final response = await _apiService.put(
        ApiEndpoints.updateProject(id),
        data: {
          'status': status.name,
          'job_code': nextJobCode,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return Project.fromJson(response.data);
      }
      throw Exception('Failed to update project status');
    } catch (e) {
      throw Exception('Error updating project status: $e');
    }
  }

  // Get project statistics for reporting
  Future<Map<String, dynamic>> getProjectStatistics() async {
    try {
      final projects = await getProjects();

      return {
        'total': projects.length,
        'open': projects.where((p) => p.status == ProjectStatus.open).length,
        'inProgress':
            projects.where((p) => p.status == ProjectStatus.inProgress).length,
        'completed':
            projects.where((p) => p.status == ProjectStatus.completed).length,
        'totalCost': projects.fold<double>(0, (sum, p) => sum + p.totalCost),
        'totalHours': projects.fold<double>(0, (sum, p) => sum + p.totalHours),
      };
    } catch (e) {
      throw Exception('Error fetching project statistics: $e');
    }
  }

  // Check if customer has active projects (for deletion validation)
  Future<bool> hasActiveProjects(String customerId) async {
    try {
      final projects = await getProjectsByCustomer(customerId);
      return projects
          .any((project) => project.status != ProjectStatus.completed);
    } catch (e) {
      throw Exception('Error checking active projects: $e');
    }
  }
}
