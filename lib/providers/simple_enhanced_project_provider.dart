import 'package:flutter/material.dart';
import '../shared/models/project_model.dart';
import '../features/project/services/project_service.dart';

// To match the enum from enhanced_project_provider.dart
enum ProjectLoadingState { idle, loading, loaded, error }

enum ProjectOperation { create, update, delete, archive, restore }

class EnhancedProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  // State management
  ProjectLoadingState _loadingState = ProjectLoadingState.idle;
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  Project? _selectedProject;
  String _errorMessage = '';
  String _searchQuery = '';
  bool _hasReachedMax = false;

  // Filters
  ProjectStatus? _statusFilter;
  ProjectPriority? _priorityFilter;
  String? _customerFilter;
  bool _showArchived = false;
  String? _employeeFilter;
  List<String> _tagFilters = [];

  // Getters
  ProjectLoadingState get loadingState => _loadingState;
  List<Project> get projects =>
      _filteredProjects.isNotEmpty ? _filteredProjects : _projects;
  List<Project> get allProjects => _projects;
  Project? get selectedProject => _selectedProject;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasReachedMax => _hasReachedMax;
  bool get isLoading => _loadingState == ProjectLoadingState.loading;
  bool get isLoadingMore => _state == ProjectState.loadingMore;
  ProjectStatus? get statusFilter => _statusFilter;
  ProjectPriority? get priorityFilter => _priorityFilter;
  String? get customerFilter => _customerFilter;
  bool get showArchived => _showArchived;
  String? get employeeFilter => _employeeFilter;
  List<String> get tagFilters => _tagFilters;

  // For backward compatibility
  ProjectState _state = ProjectState.initial;
  ProjectState get state => _state;

  // Load projects
  Future<void> loadProjects({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _hasReachedMax = false;
      _projects.clear();
      _filteredProjects.clear();
    }

    _setLoadingState(ProjectLoadingState.loading);
    _clearError();

    try {
      final projects = await _projectService.getProjects();
      _projects = projects;
      _applyFiltersAndSort();
      _setLoadingState(ProjectLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load projects: $e');
      _setLoadingState(ProjectLoadingState.error);
    }
  }

  // Project selection
  void selectProjectById(String projectId) {
    try {
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
    } catch (e) {
      _setError('Failed to select project: $e');
    }
  }

  // Project archive/restore functions
  Future<bool> archiveProject({
    required String projectId,
    required String archivedBy,
  }) async {
    try {
      // Find existing project
      final index = _projects.indexWhere((p) => p.projectId == projectId);
      if (index == -1) {
        _setError('Project not found');
        return false;
      }

      final existingProject = _projects[index];
      final updatedProject = existingProject.copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
        updatedBy: archivedBy,
      );

      // In a real implementation, this would call a service method
      // For now, we'll just update our local state
      _projects[index] = updatedProject;
      if (_selectedProject?.projectId == projectId) {
        _selectedProject = updatedProject;
      }
      _applyFiltersAndSort();

      return true;
    } catch (e) {
      _setError('Failed to archive project: $e');
      return false;
    }
  }

  Future<bool> restoreProject({
    required String projectId,
    required String restoredBy,
  }) async {
    try {
      // Find existing project
      final index = _projects.indexWhere((p) => p.projectId == projectId);
      if (index == -1) {
        _setError('Project not found');
        return false;
      }

      final existingProject = _projects[index];
      final updatedProject = existingProject.copyWith(
        isArchived: false,
        updatedAt: DateTime.now(),
        updatedBy: restoredBy,
      );

      // In a real implementation, this would call a service method
      // For now, we'll just update our local state
      _projects[index] = updatedProject;
      if (_selectedProject?.projectId == projectId) {
        _selectedProject = updatedProject;
      }
      _applyFiltersAndSort();

      return true;
    } catch (e) {
      _setError('Failed to restore project: $e');
      return false;
    }
  }

  // Load more projects
  Future<void> loadMoreProjects() async {
    if (!canLoadMore) return;

    _setState(ProjectState.loadingMore);

    try {
      // Simulate pagination (in real app, this would fetch next page)
      await Future.delayed(const Duration(milliseconds: 500));
      _setState(ProjectState.loaded);
    } catch (e) {
      _setError('Failed to load more projects: $e');
      _setState(ProjectState.error);
    }
  }

  // Search
  void searchProjects(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  // Filters
  void setStatusFilter(ProjectStatus? status) {
    _statusFilter = status;
    _applyFiltersAndSort();
  }

  void setPriorityFilter(ProjectPriority? priority) {
    _priorityFilter = priority;
    _applyFiltersAndSort();
  }

  void setCustomerFilter(String? customerId) {
    _customerFilter = customerId;
    _applyFiltersAndSort();
  }

  void setShowArchived(bool showArchived) {
    _showArchived = showArchived;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setEmployeeFilter(String? employeeId) {
    _employeeFilter = employeeId;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setTagFilters(List<String> tags) {
    _tagFilters = tags;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    _customerFilter = null;
    _searchQuery = '';
    _showArchived = false;
    _employeeFilter = null;
    _tagFilters = [];
    _applyFiltersAndSort();
  }

  // Get projects by status
  Future<void> getProjectsByStatus(ProjectStatus status) async {
    _setState(ProjectState.loading);
    _clearError();

    try {
      final projects = await _projectService.getProjectsByStatus(status);
      _projects = projects;
      _applyFiltersAndSort();
      _setState(ProjectState.loaded);
    } catch (e) {
      _setError('Failed to load projects by status: $e');
      _setState(ProjectState.error);
    }
  }

  // CRUD operations
  Future<bool> createProject({
    required String jobName,
    required String customerId,
    required String createdBy,
    String? description,
    double? estimatedHours,
    ProjectPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? assignedEmployeeIds,
    List<String>? tags,
  }) async {
    try {
      // Generate a temporary project ID
      final projectId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      final project = Project(
        projectId: projectId,
        jobName: jobName,
        customerId: customerId,
        jobCode: '', // Will be generated by service
        description: description ?? '',
        totalCost: 0.0,
        totalHours: 0.0,
        estimatedHours: estimatedHours ?? 0.0,
        status: ProjectStatus.active,
        priority: priority ?? ProjectPriority.medium,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: createdBy,
        updatedBy: createdBy,
        startDate: startDate,
        endDate: endDate,
        assignedEmployeeIds: assignedEmployeeIds ?? [],
        tags: tags ?? [],
      );

      final created = await _projectService.createProject(project, customerId);
      _projects.add(created);
      _applyFiltersAndSort();
      return true;
    } catch (e) {
      _setError('Failed to create project: $e');
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
  }) async {
    try {
      // Find existing project
      final index = _projects.indexWhere((p) => p.projectId == projectId);
      if (index == -1) {
        _setError('Project not found');
        return false;
      }

      final existingProject = _projects[index];
      final updatedProject = existingProject.copyWith(
        jobName: jobName ?? existingProject.jobName,
        description: description ?? existingProject.description,
        estimatedHours: estimatedHours ?? existingProject.estimatedHours,
        status: status ?? existingProject.status,
        priority: priority ?? existingProject.priority,
        startDate: startDate,
        endDate: endDate,
        tags: tags ?? existingProject.tags,
        updatedAt: DateTime.now(),
        updatedBy: updatedBy,
      );

      final result =
          await _projectService.updateProject(projectId, updatedProject);
      _projects[index] = result;
      _applyFiltersAndSort();
      return true;
    } catch (e) {
      _setError('Failed to update project: $e');
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(projectId);
      _projects.removeWhere((p) => p.projectId == projectId);
      _applyFiltersAndSort();
      return true;
    } catch (e) {
      _setError('Failed to delete project: $e');
      return false;
    }
  }

  // Get project by ID
  Future<Project?> getProjectById(String projectId) async {
    try {
      return await _projectService.getProjectById(projectId);
    } catch (e) {
      _setError('Failed to get project: $e');
      return null;
    }
  }

  // Update project status
  Future<bool> updateProjectStatus(
      String projectId, ProjectStatus status) async {
    try {
      final updated =
          await _projectService.updateProjectStatus(projectId, status);
      final index = _projects.indexWhere((p) => p.projectId == projectId);
      if (index != -1) {
        _projects[index] = updated;
        _applyFiltersAndSort();
      }
      return true;
    } catch (e) {
      _setError('Failed to update project status: $e');
      return false;
    }
  }

  // Additional helper methods for compatibility
  void applySorting(String sortBy) {
    // Simple sorting implementation
    switch (sortBy) {
      case 'name':
        _projects.sort((a, b) => a.jobName.compareTo(b.jobName));
        break;
      case 'priority':
        _projects.sort((a, b) => a.priority.index.compareTo(b.priority.index));
        break;
      case 'status':
        _projects.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
      default:
        _projects.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    _applyFiltersAndSort();
  }

  // Private methods
  void _setState(ProjectState state) {
    _state = state;
    notifyListeners();
  }

  void _setLoadingState(ProjectLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }

  void _applyFiltersAndSort() {
    List<Project> filtered = List.from(_projects);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((project) {
        return project.jobName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            project.jobCode
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            project.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered =
          filtered.where((project) => project.status == _statusFilter).toList();
    }

    // Apply priority filter
    if (_priorityFilter != null) {
      filtered = filtered
          .where((project) => project.priority == _priorityFilter)
          .toList();
    }

    // Apply customer filter
    if (_customerFilter != null && _customerFilter!.isNotEmpty) {
      filtered = filtered
          .where((project) => project.customerId == _customerFilter)
          .toList();
    }

    // Apply archive filter
    filtered = filtered
        .where((project) => project.isArchived == _showArchived)
        .toList();

    // Apply employee filter
    if (_employeeFilter != null && _employeeFilter!.isNotEmpty) {
      filtered = filtered
          .where((project) =>
              project.assignedEmployeeIds.contains(_employeeFilter))
          .toList();
    }

    // Apply tag filters
    if (_tagFilters.isNotEmpty) {
      filtered = filtered
          .where(
              (project) => _tagFilters.any((tag) => project.tags.contains(tag)))
          .toList();
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _filteredProjects = filtered;
    notifyListeners();
  }

  // Pagination
  bool get canLoadMore =>
      !_hasReachedMax && _loadingState != ProjectLoadingState.loading;
}

// Keep this enum for backward compatibility
enum ProjectState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
}
