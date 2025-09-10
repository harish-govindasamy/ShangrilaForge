import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../shared/models/project_model.dart';
import '../../data/repositories/project_repository_interface.dart';

class ProjectUseCases {
  final ProjectRepositoryInterface repository;

  ProjectUseCases({required this.repository});

  // Core CRUD Operations

  Future<Either<Failure, List<Project>>> getAllProjects() async {
    return await repository.getAllProjects();
  }

  Future<Either<Failure, List<Project>>> getActiveProjects() async {
    return await repository.getActiveProjects();
  }

  Future<Either<Failure, List<Project>>> getArchivedProjects() async {
    return await repository.getArchivedProjects();
  }

  Future<Either<Failure, Project?>> getProjectById(String projectId) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    return await repository.getProjectById(projectId);
  }

  Future<Either<Failure, Project>> createProject({
    required String jobName,
    required String customerId,
    required String createdBy,
    String? description,
    double? estimatedHours,
    ProjectPriority priority = ProjectPriority.medium,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? assignedEmployeeIds,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) async {
    // Validation
    if (jobName.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Job name cannot be empty'));
    }
    if (customerId.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Customer ID cannot be empty'));
    }
    if (createdBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Created by cannot be empty'));
    }

    // Generate job code
    final jobCodeResult = await repository.generateJobCode(customerId, 'JOB');
    return await jobCodeResult.fold(
      (failure) async => Left(failure),
      (jobCode) async {
        final now = DateTime.now();
        final projectId = 'proj_${now.millisecondsSinceEpoch}';

        final project = Project(
          projectId: projectId,
          jobName: jobName.trim(),
          customerId: customerId.trim(),
          jobCode: jobCode,
          description: description?.trim() ?? '',
          totalCost: 0.0,
          totalHours: 0.0,
          estimatedHours: estimatedHours ?? 0.0,
          status: ProjectStatus.active,
          priority: priority,
          createdAt: now,
          updatedAt: now,
          startDate: startDate,
          endDate: endDate,
          createdBy: createdBy.trim(),
          updatedBy: createdBy.trim(),
          assignedEmployeeIds: assignedEmployeeIds ?? [],
          jobCodeHistory: [
            JobCodeHistory(
              jobCode: jobCode,
              changedAt: now,
              changedBy: createdBy.trim(),
              reason: 'Initial job code creation',
              version: 1,
            ),
          ],
          isArchived: false,
          tags: tags ?? [],
          metadata: metadata ?? {},
          recordTracking: const [],
        );

        return await repository.createProject(project);
      },
    );
  }

  Future<Either<Failure, Project>> updateProject({
    required String projectId,
    required String updatedBy,
    String? jobName,
    String? description,
    double? estimatedHours,
    ProjectStatus? status,
    ProjectPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) async {
    // Validation
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (updatedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Updated by cannot be empty'));
    }

    final projectResult = await repository.getProjectById(projectId);
    return await projectResult.fold(
      (failure) async => Left(failure),
      (existingProject) async {
        if (existingProject == null) {
          return const Left(NotFoundFailure(message: 'Project not found'));
        }

        final updatedProject = existingProject.copyWith(
          jobName: jobName?.trim(),
          description: description?.trim(),
          estimatedHours: estimatedHours,
          status: status,
          priority: priority,
          startDate: startDate,
          endDate: endDate,
          tags: tags,
          metadata: metadata,
          updatedBy: updatedBy.trim(),
          updatedAt: DateTime.now(),
        );

        return await repository.updateProject(updatedProject);
      },
    );
  }

  Future<Either<Failure, bool>> archiveProject({
    required String projectId,
    required String archivedBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (archivedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Archived by cannot be empty'));
    }

    return await repository.archiveProject(projectId, archivedBy.trim());
  }

  Future<Either<Failure, bool>> restoreProject({
    required String projectId,
    required String restoredBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (restoredBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Restored by cannot be empty'));
    }

    return await repository.restoreProject(projectId, restoredBy.trim());
  }

  Future<Either<Failure, bool>> deleteProject({
    required String projectId,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }

    // Check if project can be deleted
    final canDeleteResult = await repository.canProjectBeDeleted(projectId);
    return await canDeleteResult.fold(
      (failure) async => Left(failure),
      (canDelete) async {
        if (!canDelete) {
          return const Left(ValidationFailure(
            message:
                'Project cannot be deleted - has active timesheets or dependencies',
          ));
        }
        return await repository.deleteProject(projectId);
      },
    );
  }

  // Job Code Management

  Future<Either<Failure, bool>> updateJobCode({
    required String projectId,
    required String newJobCode,
    required String changedBy,
    String? reason,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (newJobCode.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Job code cannot be empty'));
    }
    if (changedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Changed by cannot be empty'));
    }

    return await repository.updateJobCode(
      projectId,
      newJobCode.trim(),
      changedBy.trim(),
      reason?.trim(),
    );
  }

  Future<Either<Failure, List<JobCodeHistory>>> getJobCodeHistory(
      String projectId) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    return await repository.getJobCodeHistory(projectId);
  }

  // Employee Assignment

  Future<Either<Failure, bool>> assignEmployee({
    required String projectId,
    required String employeeId,
    required String assignedBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (employeeId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Employee ID cannot be empty'));
    }
    if (assignedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Assigned by cannot be empty'));
    }

    return await repository.assignEmployee(
        projectId, employeeId, assignedBy.trim());
  }

  Future<Either<Failure, bool>> unassignEmployee({
    required String projectId,
    required String employeeId,
    required String unassignedBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (employeeId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Employee ID cannot be empty'));
    }
    if (unassignedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Unassigned by cannot be empty'));
    }

    return await repository.unassignEmployee(
        projectId, employeeId, unassignedBy.trim());
  }

  Future<Either<Failure, bool>> assignMultipleEmployees({
    required String projectId,
    required List<String> employeeIds,
    required String assignedBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (employeeIds.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Employee IDs cannot be empty'));
    }
    if (assignedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Assigned by cannot be empty'));
    }

    // Validate all employee IDs are not empty
    if (employeeIds.any((id) => id.isEmpty)) {
      return const Left(
          ValidationFailure(message: 'All employee IDs must be valid'));
    }

    return await repository.assignMultipleEmployees(
        projectId, employeeIds, assignedBy.trim());
  }

  // Status and Priority Management

  Future<Either<Failure, bool>> updateProjectStatus({
    required String projectId,
    required ProjectStatus status,
    required String updatedBy,
    String? reason,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (updatedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Updated by cannot be empty'));
    }

    return await repository.updateProjectStatus(
        projectId, status, updatedBy.trim(), reason?.trim());
  }

  Future<Either<Failure, bool>> updateProjectPriority({
    required String projectId,
    required ProjectPriority priority,
    required String updatedBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (updatedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Updated by cannot be empty'));
    }

    return await repository.updateProjectPriority(
        projectId, priority, updatedBy.trim());
  }

  // Progress Tracking

  Future<Either<Failure, bool>> updateProjectHours({
    required String projectId,
    required double hours,
    required String updatedBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (hours < 0) {
      return const Left(ValidationFailure(message: 'Hours cannot be negative'));
    }
    if (updatedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Updated by cannot be empty'));
    }

    return await repository.updateProjectHours(
        projectId, hours, updatedBy.trim());
  }

  Future<Either<Failure, bool>> updateProjectCost({
    required String projectId,
    required double cost,
    required String updatedBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (cost < 0) {
      return const Left(ValidationFailure(message: 'Cost cannot be negative'));
    }
    if (updatedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Updated by cannot be empty'));
    }

    return await repository.updateProjectCost(
        projectId, cost, updatedBy.trim());
  }

  Future<Either<Failure, double>> getProjectProgress(String projectId) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    return await repository.getProjectProgress(projectId);
  }

  // Search and Filter

  Future<Either<Failure, List<Project>>> searchProjects(String query) async {
    if (query.trim().isEmpty) {
      return await repository.getAllProjects();
    }
    return await repository.searchProjects(query.trim());
  }

  Future<Either<Failure, List<Project>>> getProjectsByStatus(
      ProjectStatus status) async {
    return await repository.getProjectsByStatus(status);
  }

  Future<Either<Failure, List<Project>>> getProjectsByPriority(
      ProjectPriority priority) async {
    return await repository.getProjectsByPriority(priority);
  }

  Future<Either<Failure, List<Project>>> getProjectsByCustomer(
      String customerId) async {
    if (customerId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Customer ID cannot be empty'));
    }
    return await repository.getProjectsByCustomerId(customerId);
  }

  Future<Either<Failure, List<Project>>> getProjectsByEmployee(
      String employeeId) async {
    if (employeeId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Employee ID cannot be empty'));
    }
    return await repository.getProjectsByEmployeeId(employeeId);
  }

  Future<Either<Failure, List<Project>>> getProjectsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (startDate.isAfter(endDate)) {
      return const Left(
          ValidationFailure(message: 'Start date cannot be after end date'));
    }
    return await repository.getProjectsByDateRange(startDate, endDate);
  }

  Future<Either<Failure, List<Project>>> getProjectsByTags(
      List<String> tags) async {
    if (tags.isEmpty) {
      return await repository.getAllProjects();
    }
    // Filter out empty tags
    final validTags = tags
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) => tag.trim())
        .toList();
    if (validTags.isEmpty) {
      return await repository.getAllProjects();
    }
    return await repository.getProjectsByTags(validTags);
  }

  // Analytics and Reporting

  Future<Either<Failure, Map<String, dynamic>>> getProjectAnalytics() async {
    return await repository.getProjectAnalytics();
  }

  Future<Either<Failure, List<Project>>> getOverBudgetProjects() async {
    return await repository.getOverBudgetProjects();
  }

  Future<Either<Failure, List<Project>>> getDelayedProjects() async {
    return await repository.getDelayedProjects();
  }

  Future<Either<Failure, Map<ProjectStatus, int>>>
      getProjectStatusCounts() async {
    return await repository.getProjectStatusCounts();
  }

  Future<Either<Failure, Map<ProjectPriority, int>>>
      getProjectPriorityCounts() async {
    return await repository.getProjectPriorityCounts();
  }

  // Tag Management

  Future<Either<Failure, bool>> addProjectTags({
    required String projectId,
    required List<String> tags,
    required String updatedBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (tags.isEmpty) {
      return const Left(ValidationFailure(message: 'Tags cannot be empty'));
    }
    if (updatedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Updated by cannot be empty'));
    }

    // Filter out empty tags and trim
    final validTags = tags
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) => tag.trim())
        .toList();
    if (validTags.isEmpty) {
      return const Left(ValidationFailure(message: 'No valid tags provided'));
    }

    return await repository.addProjectTags(
        projectId, validTags, updatedBy.trim());
  }

  Future<Either<Failure, bool>> removeProjectTags({
    required String projectId,
    required List<String> tags,
    required String updatedBy,
  }) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (tags.isEmpty) {
      return const Left(ValidationFailure(message: 'Tags cannot be empty'));
    }
    if (updatedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Updated by cannot be empty'));
    }

    // Filter out empty tags and trim
    final validTags = tags
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) => tag.trim())
        .toList();
    if (validTags.isEmpty) {
      return const Left(ValidationFailure(message: 'No valid tags provided'));
    }

    return await repository.removeProjectTags(
        projectId, validTags, updatedBy.trim());
  }

  Future<Either<Failure, List<String>>> getAllProjectTags() async {
    return await repository.getAllProjectTags();
  }

  // Export Functions

  Future<Either<Failure, String>> exportProjectsToCSV({
    List<String>? projectIds,
  }) async {
    return await repository.exportProjectsToCSV(projectIds ?? []);
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> exportProjectsToJson({
    List<String>? projectIds,
  }) async {
    return await repository.exportProjectsToJson(projectIds ?? []);
  }

  // Batch Operations

  Future<Either<Failure, List<Project>>> batchUpdateProjectStatus({
    required List<String> projectIds,
    required ProjectStatus status,
    required String updatedBy,
  }) async {
    if (projectIds.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project IDs cannot be empty'));
    }
    if (updatedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Updated by cannot be empty'));
    }

    // Validate all project IDs are not empty
    if (projectIds.any((id) => id.isEmpty)) {
      return const Left(
          ValidationFailure(message: 'All project IDs must be valid'));
    }

    return await repository.batchUpdateProjectStatus(
        projectIds, status, updatedBy.trim());
  }

  Future<Either<Failure, bool>> batchArchiveProjects({
    required List<String> projectIds,
    required String archivedBy,
  }) async {
    if (projectIds.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project IDs cannot be empty'));
    }
    if (archivedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Archived by cannot be empty'));
    }

    // Validate all project IDs are not empty
    if (projectIds.any((id) => id.isEmpty)) {
      return const Left(
          ValidationFailure(message: 'All project IDs must be valid'));
    }

    return await repository.batchArchiveProjects(projectIds, archivedBy.trim());
  }

  Future<Either<Failure, bool>> batchAssignEmployee({
    required List<String> projectIds,
    required String employeeId,
    required String assignedBy,
  }) async {
    if (projectIds.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project IDs cannot be empty'));
    }
    if (employeeId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Employee ID cannot be empty'));
    }
    if (assignedBy.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Assigned by cannot be empty'));
    }

    // Validate all project IDs are not empty
    if (projectIds.any((id) => id.isEmpty)) {
      return const Left(
          ValidationFailure(message: 'All project IDs must be valid'));
    }

    return await repository.batchAssignEmployee(
        projectIds, employeeId, assignedBy.trim());
  }

  // Validation Helpers

  Future<Either<Failure, bool>> isJobCodeUnique({
    required String jobCode,
    String? excludeProjectId,
  }) async {
    if (jobCode.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Job code cannot be empty'));
    }
    return await repository.isJobCodeUnique(jobCode.trim(), excludeProjectId);
  }

  Future<Either<Failure, bool>> canEmployeeBeAssigned({
    required String employeeId,
    required String projectId,
  }) async {
    if (employeeId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Employee ID cannot be empty'));
    }
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    return await repository.canEmployeeBeAssigned(employeeId, projectId);
  }

  Future<Either<Failure, bool>> canProjectBeDeleted(String projectId) async {
    if (projectId.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Project ID cannot be empty'));
    }
    return await repository.canProjectBeDeleted(projectId);
  }
}
