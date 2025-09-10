import 'package:flutter/foundation.dart';
import '../../shared/models/project_model.dart';
import '../../domain/usecases/project_usecases.dart';
import '../../core/errors/failures.dart';

enum ProjectLoadingState { idle, loading, loaded, error }

enum ProjectOperation { create, update, delete, archive, restore }

// Helper extension to get message from any failure type
extension FailureMessage on Failure {
  String get message {
    if (this is ServerFailure) return (this as ServerFailure).message;
    if (this is CacheFailure) return (this as CacheFailure).message;
    if (this is NetworkFailure) return (this as NetworkFailure).message;
    if (this is ValidationFailure) return (this as ValidationFailure).message;
    if (this is UnauthorizedFailure) {
      return (this as UnauthorizedFailure).message;
    }
    if (this is NotFoundFailure) return (this as NotFoundFailure).message;
    if (this is DatabaseFailure) return (this as DatabaseFailure).message;
    return 'Unknown error occurred';
  }
}

class EnhancedProjectProvider extends ChangeNotifier {
  final ProjectUseCases projectUseCases;

  EnhancedProjectProvider({required this.projectUseCases});

  // State Management
  ProjectLoadingState _loadingState = ProjectLoadingState.idle;
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  Project? _selectedProject;
  String _errorMessage = '';
  String _searchQuery = '';
  ProjectStatus? _statusFilter;
  ProjectPriority? _priorityFilter;
  bool _showArchived = false;
  String? _customerFilter;
  String? _employeeFilter;
  List<String> _tagFilters = [];

  // Analytics
  Map<String, dynamic> _analytics = {};
  List<Project> _overBudgetProjects = [];
  List<Project> _delayedProjects = [];
  Map<ProjectStatus, int> _statusCounts = {};
  Map<ProjectPriority, int> _priorityCounts = {};

  // Operations tracking
  final Map<String, bool> _operationStates = {};
  final Map<ProjectOperation, List<String>> _operationHistory = {
    ProjectOperation.create: [],
    ProjectOperation.update: [],
    ProjectOperation.delete: [],
    ProjectOperation.archive: [],
    ProjectOperation.restore: [],
  };

  // Getters
  ProjectLoadingState get loadingState => _loadingState;
  List<Project> get projects => _filteredProjects;
  List<Project> get allProjects => _projects;
  Project? get selectedProject => _selectedProject;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ProjectStatus? get statusFilter => _statusFilter;
  ProjectPriority? get priorityFilter => _priorityFilter;
  bool get showArchived => _showArchived;
  String? get customerFilter => _customerFilter;
  String? get employeeFilter => _employeeFilter;
  List<String> get tagFilters => _tagFilters;

  // Analytics getters
  Map<String, dynamic> get analytics => _analytics;
  List<Project> get overBudgetProjects => _overBudgetProjects;
  List<Project> get delayedProjects => _delayedProjects;
  Map<ProjectStatus, int> get statusCounts => _statusCounts;
  Map<ProjectPriority, int> get priorityCounts => _priorityCounts;

  // Operation state getters
  bool isOperationInProgress(String operationKey) =>
      _operationStates[operationKey] ?? false;
  List<String> getOperationHistory(ProjectOperation operation) =>
      _operationHistory[operation] ?? [];

  // Computed properties
  int get totalActiveProjects => _projects.where((p) => !p.isArchived).length;
  int get totalArchivedProjects => _projects.where((p) => p.isArchived).length;
  double get totalActiveHours => _projects
      .where((p) => !p.isArchived)
      .fold(0.0, (sum, p) => sum + p.totalHours);
  double get totalActiveCost => _projects
      .where((p) => !p.isArchived)
      .fold(0.0, (sum, p) => sum + p.totalCost);
  List<String> get allTags =>
      _projects.expand((p) => p.tags).toSet().toList()..sort();

  // Load projects
  Future<void> loadProjects({bool forceRefresh = false}) async {
    if (_loadingState == ProjectLoadingState.loading && !forceRefresh) return;

    _setLoadingState(ProjectLoadingState.loading);
    _clearError();

    try {
      final result = await projectUseCases.getAllProjects();
      result.fold(
        (failure) => _setError(failure.message),
        (projects) {
          _projects = projects;
          _applyFilters();
          _setLoadingState(ProjectLoadingState.loaded);
        },
      );
    } catch (e) {
      _setError('Unexpected error occurred: $e');
      _setLoadingState(ProjectLoadingState.error);
    }

    notifyListeners();
  }

  // Load analytics
  Future<void> loadAnalytics() async {
    try {
      final analyticsResult = await projectUseCases.getProjectAnalytics();
      final overBudgetResult = await projectUseCases.getOverBudgetProjects();
      final delayedResult = await projectUseCases.getDelayedProjects();
      final statusCountsResult = await projectUseCases.getProjectStatusCounts();
      final priorityCountsResult =
          await projectUseCases.getProjectPriorityCounts();

      analyticsResult.fold(
        (failure) => _setError(failure.message),
        (analytics) => _analytics = analytics,
      );

      overBudgetResult.fold(
        (failure) => null,
        (projects) => _overBudgetProjects = projects,
      );

      delayedResult.fold(
        (failure) => null,
        (projects) => _delayedProjects = projects,
      );

      statusCountsResult.fold(
        (failure) => null,
        (counts) => _statusCounts = counts,
      );

      priorityCountsResult.fold(
        (failure) => null,
        (counts) => _priorityCounts = counts,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to load analytics: $e');
    }
  }

  // CRUD Operations

  Future<bool> createProject({
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
    final operationKey = 'create_${DateTime.now().millisecondsSinceEpoch}';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.createProject(
        jobName: jobName,
        customerId: customerId,
        createdBy: createdBy,
        description: description,
        estimatedHours: estimatedHours,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
        assignedEmployeeIds: assignedEmployeeIds,
        tags: tags,
        metadata: metadata,
      );

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (project) async {
          _projects.add(project);
          _addToOperationHistory(ProjectOperation.create, project.projectId);
          _applyFilters();
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to create project: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject({
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
    final operationKey = 'update_$projectId';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.updateProject(
        projectId: projectId,
        updatedBy: updatedBy,
        jobName: jobName,
        description: description,
        estimatedHours: estimatedHours,
        status: status,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
        tags: tags,
        metadata: metadata,
      );

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (updatedProject) async {
          final index = _projects.indexWhere((p) => p.projectId == projectId);
          if (index != -1) {
            _projects[index] = updatedProject;
            if (_selectedProject?.projectId == projectId) {
              _selectedProject = updatedProject;
            }
          }
          _addToOperationHistory(ProjectOperation.update, projectId);
          _applyFilters();
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to update project: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> archiveProject({
    required String projectId,
    required String archivedBy,
  }) async {
    final operationKey = 'archive_$projectId';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.archiveProject(
        projectId: projectId,
        archivedBy: archivedBy,
      );

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (success) async {
          if (success) {
            final index = _projects.indexWhere((p) => p.projectId == projectId);
            if (index != -1) {
              _projects[index] = _projects[index].copyWith(
                isArchived: true,
                updatedBy: archivedBy,
                updatedAt: DateTime.now(),
              );
              if (_selectedProject?.projectId == projectId) {
                _selectedProject = _projects[index];
              }
            }
            _addToOperationHistory(ProjectOperation.archive, projectId);
            _applyFilters();
          }
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _setError('Failed to archive project: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreProject({
    required String projectId,
    required String restoredBy,
  }) async {
    final operationKey = 'restore_$projectId';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.restoreProject(
        projectId: projectId,
        restoredBy: restoredBy,
      );

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (success) async {
          if (success) {
            final index = _projects.indexWhere((p) => p.projectId == projectId);
            if (index != -1) {
              _projects[index] = _projects[index].copyWith(
                isArchived: false,
                updatedBy: restoredBy,
                updatedAt: DateTime.now(),
              );
              if (_selectedProject?.projectId == projectId) {
                _selectedProject = _projects[index];
              }
            }
            _addToOperationHistory(ProjectOperation.restore, projectId);
            _applyFilters();
          }
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _setError('Failed to restore project: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject({
    required String projectId,
  }) async {
    final operationKey = 'delete_$projectId';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.deleteProject(projectId: projectId);

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (success) async {
          if (success) {
            _projects.removeWhere((p) => p.projectId == projectId);
            if (_selectedProject?.projectId == projectId) {
              _selectedProject = null;
            }
            _addToOperationHistory(ProjectOperation.delete, projectId);
            _applyFilters();
          }
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _setError('Failed to delete project: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  // Employee Assignment

  Future<bool> assignEmployee({
    required String projectId,
    required String employeeId,
    required String assignedBy,
  }) async {
    final operationKey = 'assign_${projectId}_$employeeId';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.assignEmployee(
        projectId: projectId,
        employeeId: employeeId,
        assignedBy: assignedBy,
      );

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (success) async {
          if (success) {
            final index = _projects.indexWhere((p) => p.projectId == projectId);
            if (index != -1) {
              final currentIds = _projects[index].assignedEmployeeIds.toSet();
              currentIds.add(employeeId);
              _projects[index] = _projects[index].copyWith(
                assignedEmployeeIds: currentIds.toList(),
                updatedBy: assignedBy,
                updatedAt: DateTime.now(),
              );
              if (_selectedProject?.projectId == projectId) {
                _selectedProject = _projects[index];
              }
            }
            _applyFilters();
          }
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _setError('Failed to assign employee: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> unassignEmployee({
    required String projectId,
    required String employeeId,
    required String unassignedBy,
  }) async {
    final operationKey = 'unassign_${projectId}_$employeeId';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.unassignEmployee(
        projectId: projectId,
        employeeId: employeeId,
        unassignedBy: unassignedBy,
      );

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (success) async {
          if (success) {
            final index = _projects.indexWhere((p) => p.projectId == projectId);
            if (index != -1) {
              final currentIds = _projects[index].assignedEmployeeIds.toList();
              currentIds.remove(employeeId);
              _projects[index] = _projects[index].copyWith(
                assignedEmployeeIds: currentIds,
                updatedBy: unassignedBy,
                updatedAt: DateTime.now(),
              );
              if (_selectedProject?.projectId == projectId) {
                _selectedProject = _projects[index];
              }
            }
            _applyFilters();
          }
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _setError('Failed to unassign employee: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  // Job Code Management

  Future<bool> updateJobCode({
    required String projectId,
    required String newJobCode,
    required String changedBy,
    String? reason,
  }) async {
    final operationKey = 'jobcode_$projectId';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.updateJobCode(
        projectId: projectId,
        newJobCode: newJobCode,
        changedBy: changedBy,
        reason: reason,
      );

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (success) async {
          if (success) {
            // Refresh the specific project to get updated job code history
            final projectResult =
                await projectUseCases.getProjectById(projectId);
            projectResult.fold(
              (failure) => null,
              (updatedProject) {
                if (updatedProject != null) {
                  final index =
                      _projects.indexWhere((p) => p.projectId == projectId);
                  if (index != -1) {
                    _projects[index] = updatedProject;
                    if (_selectedProject?.projectId == projectId) {
                      _selectedProject = updatedProject;
                    }
                  }
                }
              },
            );
            _applyFilters();
          }
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _setError('Failed to update job code: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  // Tag Management

  Future<bool> addProjectTags({
    required String projectId,
    required List<String> tags,
    required String updatedBy,
  }) async {
    final operationKey = 'addtags_$projectId';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.addProjectTags(
        projectId: projectId,
        tags: tags,
        updatedBy: updatedBy,
      );

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (success) async {
          if (success) {
            final index = _projects.indexWhere((p) => p.projectId == projectId);
            if (index != -1) {
              final currentTags = _projects[index].tags.toSet();
              currentTags.addAll(tags);
              _projects[index] = _projects[index].copyWith(
                tags: currentTags.toList(),
                updatedBy: updatedBy,
                updatedAt: DateTime.now(),
              );
              if (_selectedProject?.projectId == projectId) {
                _selectedProject = _projects[index];
              }
            }
            _applyFilters();
          }
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _setError('Failed to add project tags: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeProjectTags({
    required String projectId,
    required List<String> tags,
    required String updatedBy,
  }) async {
    final operationKey = 'removetags_$projectId';
    _setOperationState(operationKey, true);

    try {
      final result = await projectUseCases.removeProjectTags(
        projectId: projectId,
        tags: tags,
        updatedBy: updatedBy,
      );

      return await result.fold(
        (failure) async {
          _setError(failure.message);
          _setOperationState(operationKey, false);
          notifyListeners();
          return false;
        },
        (success) async {
          if (success) {
            final index = _projects.indexWhere((p) => p.projectId == projectId);
            if (index != -1) {
              final currentTags = _projects[index].tags.toSet();
              currentTags.removeAll(tags);
              _projects[index] = _projects[index].copyWith(
                tags: currentTags.toList(),
                updatedBy: updatedBy,
                updatedAt: DateTime.now(),
              );
              if (_selectedProject?.projectId == projectId) {
                _selectedProject = _projects[index];
              }
            }
            _applyFilters();
          }
          _setOperationState(operationKey, false);
          _clearError();
          notifyListeners();
          return success;
        },
      );
    } catch (e) {
      _setError('Failed to remove project tags: $e');
      _setOperationState(operationKey, false);
      notifyListeners();
      return false;
    }
  }

  // Filtering and Search

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(ProjectStatus? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void setPriorityFilter(ProjectPriority? priority) {
    _priorityFilter = priority;
    _applyFilters();
    notifyListeners();
  }

  void setShowArchived(bool showArchived) {
    _showArchived = showArchived;
    _applyFilters();
    notifyListeners();
  }

  void setCustomerFilter(String? customerId) {
    _customerFilter = customerId;
    _applyFilters();
    notifyListeners();
  }

  void setEmployeeFilter(String? employeeId) {
    _employeeFilter = employeeId;
    _applyFilters();
    notifyListeners();
  }

  void setTagFilters(List<String> tags) {
    _tagFilters = tags;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _priorityFilter = null;
    _showArchived = false;
    _customerFilter = null;
    _employeeFilter = null;
    _tagFilters = [];
    _applyFilters();
    notifyListeners();
  }

  // Selection

  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  void selectProjectById(String projectId) {
    _selectedProject = _projects.firstWhere(
      (p) => p.projectId == projectId,
      orElse: () => Project(
        projectId: '',
        jobName: '',
        customerId: '',
        jobCode: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: '',
        updatedBy: '',
      ),
    );
    if (_selectedProject?.projectId.isEmpty == true) {
      _selectedProject = null;
    }
    notifyListeners();
  }

  // Export

  Future<String?> exportToCSV({List<String>? projectIds}) async {
    try {
      final result =
          await projectUseCases.exportProjectsToCSV(projectIds: projectIds);
      return result.fold(
        (failure) {
          _setError(failure.message);
          notifyListeners();
          return null;
        },
        (csvData) => csvData,
      );
    } catch (e) {
      _setError('Failed to export CSV: $e');
      notifyListeners();
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> exportToJson(
      {List<String>? projectIds}) async {
    try {
      final result =
          await projectUseCases.exportProjectsToJson(projectIds: projectIds);
      return result.fold(
        (failure) {
          _setError(failure.message);
          notifyListeners();
          return null;
        },
        (jsonData) => jsonData,
      );
    } catch (e) {
      _setError('Failed to export JSON: $e');
      notifyListeners();
      return null;
    }
  }

  // Private helper methods

  void _applyFilters() {
    _filteredProjects = _projects.where((project) {
      // Archive filter
      if (!_showArchived && project.isArchived) return false;
      if (_showArchived && !project.isArchived) return false;

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!project.jobName.toLowerCase().contains(query) &&
            !project.jobCode.toLowerCase().contains(query) &&
            !project.description.toLowerCase().contains(query) &&
            !project.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Status filter
      if (_statusFilter != null && project.status != _statusFilter) {
        return false;
      }

      // Priority filter
      if (_priorityFilter != null && project.priority != _priorityFilter) {
        return false;
      }

      // Customer filter
      if (_customerFilter != null && project.customerId != _customerFilter) {
        return false;
      }

      // Employee filter
      if (_employeeFilter != null &&
          !project.assignedEmployeeIds.contains(_employeeFilter)) {
        return false;
      }

      // Tag filters
      if (_tagFilters.isNotEmpty &&
          !_tagFilters.any((tag) => project.tags.contains(tag))) {
        return false;
      }

      return true;
    }).toList();

    // Sort by priority (urgent first) then by updated date (newest first)
    _filteredProjects.sort((a, b) {
      // First sort by priority
      final priorityOrder = {
        ProjectPriority.urgent: 0,
        ProjectPriority.high: 1,
        ProjectPriority.medium: 2,
        ProjectPriority.low: 3,
      };
      final aPriority = priorityOrder[a.priority] ?? 4;
      final bPriority = priorityOrder[b.priority] ?? 4;

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      // Then sort by updated date (newest first)
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }

  void _setLoadingState(ProjectLoadingState state) {
    _loadingState = state;
  }

  void _setError(String message) {
    _errorMessage = message;
    _loadingState = ProjectLoadingState.error;
  }

  void _clearError() {
    _errorMessage = '';
  }

  void _setOperationState(String operationKey, bool inProgress) {
    _operationStates[operationKey] = inProgress;
  }

  void _addToOperationHistory(ProjectOperation operation, String projectId) {
    _operationHistory[operation]?.add(projectId);
    // Keep only last 100 operations per type
    if (_operationHistory[operation]!.length > 100) {
      _operationHistory[operation]!.removeAt(0);
    }
  }

  // Utility methods for UI

  List<Project> getProjectsByCustomer(String customerId) {
    return _projects
        .where((p) => p.customerId == customerId && !p.isArchived)
        .toList();
  }

  List<Project> getProjectsByEmployee(String employeeId) {
    return _projects
        .where(
            (p) => p.assignedEmployeeIds.contains(employeeId) && !p.isArchived)
        .toList();
  }

  Project? getProjectByJobCode(String jobCode) {
    try {
      return _projects.firstWhere((p) => p.jobCode == jobCode);
    } catch (e) {
      return null;
    }
  }

  double getEmployeeUtilization(String employeeId) {
    final employeeProjects = getProjectsByEmployee(employeeId);
    if (employeeProjects.isEmpty) {
      return 0.0;
    }

    final totalHours =
        employeeProjects.fold<double>(0.0, (sum, p) => sum + p.totalHours);
    final totalEstimated =
        employeeProjects.fold<double>(0.0, (sum, p) => sum + p.estimatedHours);

    return totalEstimated > 0
        ? (totalHours / totalEstimated * 100).clamp(0.0, 100.0)
        : 0.0;
  }

  List<Project> getHighPriorityProjects() {
    return _projects
        .where((p) =>
            !p.isArchived &&
            (p.priority == ProjectPriority.high ||
                p.priority == ProjectPriority.urgent))
        .toList();
  }

  List<Project> getRecentlyUpdatedProjects({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _projects
        .where((p) => !p.isArchived && p.updatedAt.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  void dispose() {
    _projects.clear();
    _filteredProjects.clear();
    _operationStates.clear();
    _operationHistory.clear();
    super.dispose();
  }
}
