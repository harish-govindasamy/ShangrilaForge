import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../shared/models/project_model.dart';

abstract class ProjectRepositoryInterface {
  // CRUD Operations
  Future<Either<Failure, List<Project>>> getAllProjects();
  Future<Either<Failure, List<Project>>> getActiveProjects();
  Future<Either<Failure, List<Project>>> getArchivedProjects();
  Future<Either<Failure, Project?>> getProjectById(String projectId);
  Future<Either<Failure, List<Project>>> getProjectsByCustomerId(
      String customerId);
  Future<Either<Failure, List<Project>>> getProjectsByEmployeeId(
      String employeeId);
  Future<Either<Failure, Project>> createProject(Project project);
  Future<Either<Failure, Project>> updateProject(Project project);
  Future<Either<Failure, bool>> archiveProject(
      String projectId, String archivedBy);
  Future<Either<Failure, bool>> restoreProject(
      String projectId, String restoredBy);
  Future<Either<Failure, bool>> deleteProject(
      String projectId); // Hard delete for admin

  // Job Code Management
  Future<Either<Failure, String>> generateJobCode(
      String customerId, String prefix);
  Future<Either<Failure, bool>> updateJobCode(
    String projectId,
    String newJobCode,
    String changedBy,
    String? reason,
  );
  Future<Either<Failure, List<JobCodeHistory>>> getJobCodeHistory(
      String projectId);

  // Employee Assignment
  Future<Either<Failure, bool>> assignEmployee(
      String projectId, String employeeId, String assignedBy);
  Future<Either<Failure, bool>> unassignEmployee(
      String projectId, String employeeId, String unassignedBy);
  Future<Either<Failure, bool>> assignMultipleEmployees(
    String projectId,
    List<String> employeeIds,
    String assignedBy,
  );

  // Status Management
  Future<Either<Failure, bool>> updateProjectStatus(
    String projectId,
    ProjectStatus status,
    String updatedBy,
    String? reason,
  );
  Future<Either<Failure, bool>> updateProjectPriority(
    String projectId,
    ProjectPriority priority,
    String updatedBy,
  );

  // Progress Tracking
  Future<Either<Failure, bool>> updateProjectHours(
      String projectId, double hours, String updatedBy);
  Future<Either<Failure, bool>> updateProjectCost(
      String projectId, double cost, String updatedBy);
  Future<Either<Failure, double>> getProjectProgress(String projectId);

  // Search and Filter
  Future<Either<Failure, List<Project>>> searchProjects(String query);
  Future<Either<Failure, List<Project>>> getProjectsByStatus(
      ProjectStatus status);
  Future<Either<Failure, List<Project>>> getProjectsByPriority(
      ProjectPriority priority);
  Future<Either<Failure, List<Project>>> getProjectsByDateRange(
      DateTime startDate, DateTime endDate);
  Future<Either<Failure, List<Project>>> getProjectsByTags(List<String> tags);

  // Analytics
  Future<Either<Failure, Map<String, dynamic>>> getProjectAnalytics();
  Future<Either<Failure, List<Project>>> getOverBudgetProjects();
  Future<Either<Failure, List<Project>>> getDelayedProjects();
  Future<Either<Failure, Map<ProjectStatus, int>>> getProjectStatusCounts();
  Future<Either<Failure, Map<ProjectPriority, int>>> getProjectPriorityCounts();

  // Export
  Future<Either<Failure, String>> exportProjectsToCSV(List<String> projectIds);
  Future<Either<Failure, List<Map<String, dynamic>>>> exportProjectsToJson(
      List<String> projectIds);

  // Tags Management
  Future<Either<Failure, bool>> addProjectTags(
      String projectId, List<String> tags, String updatedBy);
  Future<Either<Failure, bool>> removeProjectTags(
      String projectId, List<String> tags, String updatedBy);
  Future<Either<Failure, List<String>>> getAllProjectTags();

  // Metadata Management
  Future<Either<Failure, bool>> updateProjectMetadata(
    String projectId,
    Map<String, dynamic> metadata,
    String updatedBy,
  );

  // Validation
  Future<Either<Failure, bool>> isJobCodeUnique(
      String jobCode, String? excludeProjectId);
  Future<Either<Failure, bool>> canEmployeeBeAssigned(
      String employeeId, String projectId);
  Future<Either<Failure, bool>> canProjectBeDeleted(String projectId);

  // Batch Operations
  Future<Either<Failure, List<Project>>> batchUpdateProjectStatus(
    List<String> projectIds,
    ProjectStatus status,
    String updatedBy,
  );
  Future<Either<Failure, bool>> batchArchiveProjects(
      List<String> projectIds, String archivedBy);
  Future<Either<Failure, bool>> batchAssignEmployee(
    List<String> projectIds,
    String employeeId,
    String assignedBy,
  );
}
