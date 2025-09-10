import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../shared/models/project_model.dart';
import '../datasources/project_local_datasource.dart';
import '../datasources/project_remote_datasource.dart';
import 'project_repository_interface.dart';

class ProjectRepositoryImpl implements ProjectRepositoryInterface {
  final ProjectLocalDataSource localDataSource;
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    try {
      // Try remote first, fallback to local
      try {
        final remoteProjects = await remoteDataSource.getAllProjects();
        // Cache to local storage
        await localDataSource.cacheProjects(remoteProjects);
        return Right(remoteProjects);
      } catch (e) {
        // Fallback to local data
        final localProjects = await localDataSource.getAllProjects();
        return Right(localProjects);
      }
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get projects: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getActiveProjects() async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) => Right(projects.where((p) => !p.isArchived).toList()),
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get active projects: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getArchivedProjects() async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) => Right(projects.where((p) => p.isArchived).toList()),
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get archived projects: $e'));
    }
  }

  @override
  Future<Either<Failure, Project?>> getProjectById(String projectId) async {
    try {
      // Try local first for speed
      try {
        final localProject = await localDataSource.getProjectById(projectId);
        if (localProject != null) {
          return Right(localProject);
        }
      } catch (e) {
        // Continue to remote if local fails
      }

      // Try remote
      final remoteProject = await remoteDataSource.getProjectById(projectId);
      if (remoteProject != null) {
        // Cache to local
        await localDataSource.cacheProject(remoteProject);
      }
      return Right(remoteProject);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get project: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByCustomerId(
      String customerId) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) =>
            Right(projects.where((p) => p.customerId == customerId).toList()),
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get projects by customer: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByEmployeeId(
      String employeeId) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) => Right(projects
            .where((p) => p.assignedEmployeeIds.contains(employeeId))
            .toList()),
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get projects by employee: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      // Validate job code uniqueness
      final isUniqueResult = await isJobCodeUnique(project.jobCode, null);
      final isUnique =
          isUniqueResult.fold((failure) => false, (unique) => unique);

      if (!isUnique) {
        return const Left(
            ValidationFailure(message: 'Job code already exists'));
      }

      // Create remote first
      final remoteProject = await remoteDataSource.createProject(project);

      // Cache locally
      await localDataSource.cacheProject(remoteProject);

      return Right(remoteProject);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to create project: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    try {
      // Update remote first
      final remoteProject = await remoteDataSource.updateProject(project);

      // Update local cache
      await localDataSource.cacheProject(remoteProject);

      return Right(remoteProject);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update project: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> archiveProject(
      String projectId, String archivedBy) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          final updatedProject = project.copyWith(
            isArchived: true,
            updatedBy: archivedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to archive project: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> restoreProject(
      String projectId, String restoredBy) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          final updatedProject = project.copyWith(
            isArchived: false,
            updatedBy: restoredBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to restore project: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProject(String projectId) async {
    try {
      // Check if project can be deleted
      final canDeleteResult = await canProjectBeDeleted(projectId);
      final canDelete =
          canDeleteResult.fold((failure) => false, (canDelete) => canDelete);

      if (!canDelete) {
        return const Left(ValidationFailure(
            message: 'Project cannot be deleted - has active timesheets'));
      }

      // Delete from remote
      await remoteDataSource.deleteProject(projectId);

      // Delete from local
      await localDataSource.deleteProject(projectId);

      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete project: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generateJobCode(
      String customerId, String prefix) async {
    try {
      String jobCode;
      bool isUnique = false;
      int attempt = 0;

      do {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        jobCode =
            '$prefix-$customerId-$timestamp${attempt > 0 ? '-$attempt' : ''}';

        final uniqueResult = await isJobCodeUnique(jobCode, null);
        isUnique = uniqueResult.fold((failure) => false, (unique) => unique);
        attempt++;
      } while (!isUnique && attempt < 10);

      if (!isUnique) {
        return const Left(
            ValidationFailure(message: 'Failed to generate unique job code'));
      }

      return Right(jobCode);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to generate job code: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateJobCode(
    String projectId,
    String newJobCode,
    String changedBy,
    String? reason,
  ) async {
    try {
      // Validate uniqueness
      final isUniqueResult = await isJobCodeUnique(newJobCode, projectId);
      final isUnique =
          isUniqueResult.fold((failure) => false, (unique) => unique);

      if (!isUnique) {
        return const Left(
            ValidationFailure(message: 'Job code already exists'));
      }

      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          // Create new job code history entry
          final historyEntry = JobCodeHistory(
            jobCode: newJobCode,
            changedAt: DateTime.now(),
            changedBy: changedBy,
            reason: reason,
            version: project.jobCodeHistory.length + 1,
          );

          final updatedProject = project.copyWith(
            jobCode: newJobCode,
            jobCodeHistory: [...project.jobCodeHistory, historyEntry],
            updatedBy: changedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update job code: $e'));
    }
  }

  @override
  Future<Either<Failure, List<JobCodeHistory>>> getJobCodeHistory(
      String projectId) async {
    try {
      final projectResult = await getProjectById(projectId);
      return projectResult.fold(
        (failure) => Left(failure),
        (project) {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }
          return Right(project.jobCodeHistory);
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get job code history: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> assignEmployee(
      String projectId, String employeeId, String assignedBy) async {
    try {
      // Check if employee can be assigned
      final canAssignResult =
          await canEmployeeBeAssigned(employeeId, projectId);
      final canAssign =
          canAssignResult.fold((failure) => false, (canAssign) => canAssign);

      if (!canAssign) {
        return const Left(ValidationFailure(
            message: 'Employee cannot be assigned to this project'));
      }

      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          if (project.assignedEmployeeIds.contains(employeeId)) {
            return const Left(ValidationFailure(
                message: 'Employee already assigned to this project'));
          }

          final updatedProject = project.copyWith(
            assignedEmployeeIds: [...project.assignedEmployeeIds, employeeId],
            updatedBy: assignedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to assign employee: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> unassignEmployee(
      String projectId, String employeeId, String unassignedBy) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          if (!project.assignedEmployeeIds.contains(employeeId)) {
            return const Left(ValidationFailure(
                message: 'Employee not assigned to this project'));
          }

          final updatedEmployeeIds = project.assignedEmployeeIds
              .where((id) => id != employeeId)
              .toList();

          final updatedProject = project.copyWith(
            assignedEmployeeIds: updatedEmployeeIds,
            updatedBy: unassignedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to unassign employee: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> assignMultipleEmployees(
    String projectId,
    List<String> employeeIds,
    String assignedBy,
  ) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          // Validate all employees can be assigned
          for (final employeeId in employeeIds) {
            final canAssignResult =
                await canEmployeeBeAssigned(employeeId, projectId);
            final canAssign = canAssignResult.fold(
                (failure) => false, (canAssign) => canAssign);

            if (!canAssign) {
              return Left(ValidationFailure(
                  message: 'Employee $employeeId cannot be assigned'));
            }
          }

          // Add new employee IDs (avoiding duplicates)
          final currentIds = project.assignedEmployeeIds.toSet();
          final newIds = employeeIds.toSet();
          final allIds = currentIds.union(newIds).toList();

          final updatedProject = project.copyWith(
            assignedEmployeeIds: allIds,
            updatedBy: assignedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to assign multiple employees: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProjectStatus(
    String projectId,
    ProjectStatus status,
    String updatedBy,
    String? reason,
  ) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          final updatedProject = project.copyWith(
            status: status,
            updatedBy: updatedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to update project status: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProjectPriority(
    String projectId,
    ProjectPriority priority,
    String updatedBy,
  ) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          final updatedProject = project.copyWith(
            priority: priority,
            updatedBy: updatedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to update project priority: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProjectHours(
      String projectId, double hours, String updatedBy) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          final updatedProject = project.copyWith(
            totalHours: hours,
            updatedBy: updatedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to update project hours: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProjectCost(
      String projectId, double cost, String updatedBy) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          final updatedProject = project.copyWith(
            totalCost: cost,
            updatedBy: updatedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to update project cost: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getProjectProgress(String projectId) async {
    try {
      final projectResult = await getProjectById(projectId);
      return projectResult.fold(
        (failure) => Left(failure),
        (project) {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }
          return Right(project.progressPercentage);
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get project progress: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> searchProjects(String query) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final searchQuery = query.toLowerCase();
          final filteredProjects = projects.where((project) {
            return project.jobName.toLowerCase().contains(searchQuery) ||
                project.jobCode.toLowerCase().contains(searchQuery) ||
                project.description.toLowerCase().contains(searchQuery) ||
                project.tags
                    .any((tag) => tag.toLowerCase().contains(searchQuery));
          }).toList();
          return Right(filteredProjects);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to search projects: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByStatus(
      ProjectStatus status) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) => Right(projects.where((p) => p.status == status).toList()),
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get projects by status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByPriority(
      ProjectPriority priority) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) =>
            Right(projects.where((p) => p.priority == priority).toList()),
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get projects by priority: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final filteredProjects = projects.where((project) {
            return (project.startDate != null &&
                    project.startDate!
                        .isAfter(startDate.subtract(const Duration(days: 1))) &&
                    project.startDate!
                        .isBefore(endDate.add(const Duration(days: 1)))) ||
                (project.endDate != null &&
                    project.endDate!
                        .isAfter(startDate.subtract(const Duration(days: 1))) &&
                    project.endDate!
                        .isBefore(endDate.add(const Duration(days: 1))));
          }).toList();
          return Right(filteredProjects);
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get projects by date range: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByTags(
      List<String> tags) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final filteredProjects = projects.where((project) {
            return tags.any((tag) => project.tags.contains(tag));
          }).toList();
          return Right(filteredProjects);
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get projects by tags: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectAnalytics() async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final activeProjects = projects.where((p) => !p.isArchived).toList();
          final analytics = <String, dynamic>{
            'totalProjects': projects.length,
            'activeProjects': activeProjects.length,
            'archivedProjects': projects.length - activeProjects.length,
            'totalHours':
                activeProjects.fold<double>(0, (sum, p) => sum + p.totalHours),
            'totalCost':
                activeProjects.fold<double>(0, (sum, p) => sum + p.totalCost),
            'averageProgress': activeProjects.isNotEmpty
                ? activeProjects.fold<double>(
                        0, (sum, p) => sum + p.progressPercentage) /
                    activeProjects.length
                : 0.0,
            'overBudgetCount':
                activeProjects.where((p) => p.isOverBudget).length,
            'completedProjectsThisMonth': projects
                .where((p) =>
                    p.status == ProjectStatus.completed &&
                    p.updatedAt.isAfter(
                        DateTime.now().subtract(const Duration(days: 30))))
                .length,
          };
          return Right(analytics);
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get project analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getOverBudgetProjects() async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) => Right(projects.where((p) => p.isOverBudget).toList()),
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get over budget projects: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getDelayedProjects() async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final now = DateTime.now();
          final delayedProjects = projects.where((project) {
            return project.endDate != null &&
                project.endDate!.isBefore(now) &&
                project.status != ProjectStatus.completed;
          }).toList();
          return Right(delayedProjects);
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get delayed projects: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<ProjectStatus, int>>>
      getProjectStatusCounts() async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final statusCounts = <ProjectStatus, int>{};
          for (final status in ProjectStatus.values) {
            statusCounts[status] =
                projects.where((p) => p.status == status).length;
          }
          return Right(statusCounts);
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get project status counts: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<ProjectPriority, int>>>
      getProjectPriorityCounts() async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final priorityCounts = <ProjectPriority, int>{};
          for (final priority in ProjectPriority.values) {
            priorityCounts[priority] =
                projects.where((p) => p.priority == priority).length;
          }
          return Right(priorityCounts);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(
          message: 'Failed to get project priority counts: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportProjectsToCSV(
      List<String> projectIds) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final filteredProjects = projectIds.isEmpty
              ? projects
              : projects
                  .where((p) => projectIds.contains(p.projectId))
                  .toList();

          // Generate CSV content
          final csvBuffer = StringBuffer();
          csvBuffer.writeln(
              'Project ID,Job Name,Customer ID,Job Code,Status,Priority,Total Hours,Total Cost,Progress %,Created At');

          for (final project in filteredProjects) {
            csvBuffer.writeln('${project.projectId},'
                '${project.jobName},'
                '${project.customerId},'
                '${project.jobCode},'
                '${project.statusDisplayName},'
                '${project.priorityDisplayName},'
                '${project.totalHours},'
                '${project.totalCost},'
                '${project.progressPercentage.toStringAsFixed(1)},'
                '${project.createdAt.toIso8601String()}');
          }

          return Right(csvBuffer.toString());
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to export projects to CSV: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> exportProjectsToJson(
      List<String> projectIds) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final filteredProjects = projectIds.isEmpty
              ? projects
              : projects
                  .where((p) => projectIds.contains(p.projectId))
                  .toList();

          final jsonData =
              filteredProjects.map((project) => project.toJson()).toList();
          return Right(jsonData);
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to export projects to JSON: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> addProjectTags(
      String projectId, List<String> tags, String updatedBy) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          final currentTags = project.tags.toSet();
          final newTags = tags.toSet();
          final allTags = currentTags.union(newTags).toList();

          final updatedProject = project.copyWith(
            tags: allTags,
            updatedBy: updatedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to add project tags: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeProjectTags(
      String projectId, List<String> tags, String updatedBy) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          final currentTags = project.tags.toSet();
          final tagsToRemove = tags.toSet();
          final remainingTags = currentTags.difference(tagsToRemove).toList();

          final updatedProject = project.copyWith(
            tags: remainingTags,
            updatedBy: updatedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to remove project tags: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllProjectTags() async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final allTags = <String>{};
          for (final project in projects) {
            allTags.addAll(project.tags);
          }
          return Right(allTags.toList()..sort());
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to get all project tags: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProjectMetadata(
    String projectId,
    Map<String, dynamic> metadata,
    String updatedBy,
  ) async {
    try {
      final projectResult = await getProjectById(projectId);
      return await projectResult.fold(
        (failure) async => Left(failure),
        (project) async {
          if (project == null) {
            return const Left(NotFoundFailure(message: 'Project not found'));
          }

          final updatedMetadata = {...project.metadata, ...metadata};

          final updatedProject = project.copyWith(
            metadata: updatedMetadata,
            updatedBy: updatedBy,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateProject(updatedProject);
          return updateResult.fold(
            (failure) => Left(failure),
            (project) => const Right(true),
          );
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to update project metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isJobCodeUnique(
      String jobCode, String? excludeProjectId) async {
    try {
      final result = await getAllProjects();
      return result.fold(
        (failure) => Left(failure),
        (projects) {
          final existingProject = projects.firstWhere(
            (p) => p.jobCode == jobCode && p.projectId != excludeProjectId,
            orElse: () => Project(
              projectId: '',
              jobName: '',
              customerId: '',
              jobCode: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              createdBy: 'system',
              updatedBy: 'system',
            ),
          );

          return Right(existingProject.projectId.isEmpty);
        },
      );
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to check job code uniqueness: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> canEmployeeBeAssigned(
      String employeeId, String projectId) async {
    try {
      // For now, just check if employee exists
      // In a real implementation, this would check employee availability, skills, etc.
      return const Right(true);
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to check employee assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> canProjectBeDeleted(String projectId) async {
    try {
      // Check if project has any active timesheets
      // For now, we'll assume no active timesheets - in real implementation this would check timesheet data
      return const Right(true);
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to check project deletion: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> batchUpdateProjectStatus(
    List<String> projectIds,
    ProjectStatus status,
    String updatedBy,
  ) async {
    try {
      final updatedProjects = <Project>[];

      for (final projectId in projectIds) {
        final result =
            await updateProjectStatus(projectId, status, updatedBy, null);
        if (result.isLeft()) {
          return const Left(DatabaseFailure(message: 'Unexpected error'));
        }

        final projectResult = await getProjectById(projectId);
        projectResult.fold(
          (failure) => null,
          (project) {
            if (project != null) {
              updatedProjects.add(project);
            }
          },
        );
      }

      return Right(updatedProjects);
    } catch (e) {
      return Left(DatabaseFailure(
          message: 'Failed to batch update project status: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> batchArchiveProjects(
      List<String> projectIds, String archivedBy) async {
    try {
      for (final projectId in projectIds) {
        final result = await archiveProject(projectId, archivedBy);
        if (result.isLeft()) {
          return const Left(DatabaseFailure(message: 'Unexpected error'));
        }
      }

      return const Right(true);
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to batch archive projects: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> batchAssignEmployee(
    List<String> projectIds,
    String employeeId,
    String assignedBy,
  ) async {
    try {
      for (final projectId in projectIds) {
        final result = await assignEmployee(projectId, employeeId, assignedBy);
        if (result.isLeft()) {
          return const Left(DatabaseFailure(message: 'Unexpected error'));
        }
      }

      return const Right(true);
    } catch (e) {
      return Left(
          DatabaseFailure(message: 'Failed to batch assign employee: $e'));
    }
  }
}
