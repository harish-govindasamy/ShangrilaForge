import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../services/project_service.dart';
import '../../../shared/models/project_model.dart';
import '../../../core/services/local_storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final Logger _logger = Logger('ProjectProvider');

  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  ProjectStatus? _selectedStatus;

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ProjectStatus? get selectedStatus => _selectedStatus;

  // Get all projects
  Future<void> loadProjects() async {
    _setLoading(true);
    _clearError();

    try {
      // First load from local storage
      _projects = await _localStorageService.getProjects();
      notifyListeners();

      // Then try to sync with API
      try {
        final apiProjects = await _projectService.getProjects();
        _projects = apiProjects;
        await _localStorageService.saveProjects(_projects);
        notifyListeners();
      } catch (apiError) {
        // API failed, but we have local data
        if (_projects.isEmpty) {
          rethrow;
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get project by ID
  Future<void> loadProjectById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // First try local storage
      final localProjects = await _localStorageService.getProjects();
      _selectedProject = localProjects.firstWhere(
        (proj) => proj.projectId == id,
        orElse: () => throw Exception('Project not found'),
      );
      notifyListeners();

      // Then try API
      try {
        _selectedProject = await _projectService.getProjectById(id);
        notifyListeners();
      } catch (apiError) {
        // API failed, but we have local data
        if (_selectedProject == null) {
          rethrow;
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create project
  Future<bool> createProject(Project project) async {
    _setLoading(true);
    _clearError();

    try {
      // Add to local storage first
      _projects.add(project);
      await _localStorageService.saveProjects(_projects);
      notifyListeners();

      // Try to sync with API
      try {
        final newProject =
            await _projectService.createProject(project, 'DEFAULT_CUSTOMER');
        // Update with server response
        final index =
            _projects.indexWhere((p) => p.projectId == project.projectId);
        if (index != -1) {
          _projects[index] = newProject;
          await _localStorageService.saveProjects(_projects);
          notifyListeners();
        }
      } catch (apiError) {
        // API failed, but local save succeeded
        _logger.warning('API sync failed during project creation: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update project
  Future<bool> updateProject(String id, Project project) async {
    _setLoading(true);
    _clearError();

    try {
      // Update locally first
      final index = _projects.indexWhere((proj) => proj.projectId == id);
      if (index != -1) {
        _projects[index] = project;
        await _localStorageService.saveProjects(_projects);
      }
      if (_selectedProject?.projectId == id) {
        _selectedProject = project;
      }
      notifyListeners();

      // Try to sync with API
      try {
        final updatedProject = await _projectService.updateProject(id, project);
        // Update with server response
        if (index != -1) {
          _projects[index] = updatedProject;
          await _localStorageService.saveProjects(_projects);
        }
        if (_selectedProject?.projectId == id) {
          _selectedProject = updatedProject;
        }
        notifyListeners();
      } catch (apiError) {
        _logger.warning('API sync failed during project update: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete project
  Future<bool> deleteProject(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Remove locally first
      _projects.removeWhere((proj) => proj.projectId == id);
      await _localStorageService.saveProjects(_projects);
      if (_selectedProject?.projectId == id) {
        _selectedProject = null;
      }
      notifyListeners();

      // Try to sync with API
      try {
        await _projectService.deleteProject(id);
      } catch (apiError) {
        _logger.warning('API sync failed during project deletion: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search projects
  Future<void> searchProjects(String query) async {
    _searchQuery = query;
    _setLoading(true);
    _clearError();

    try {
      if (query.isEmpty) {
        _projects = await _localStorageService.getProjects();
      } else {
        try {
          _projects = await _projectService.searchProjects(query);
        } catch (apiError) {
          // Fallback to local search
          final localProjects = await _localStorageService.getProjects();
          _projects = localProjects
              .where((proj) =>
                  proj.jobName.toLowerCase().contains(query.toLowerCase()) ||
                  proj.jobCode.toLowerCase().contains(query.toLowerCase()) ||
                  proj.projectId.toLowerCase().contains(query.toLowerCase()) ||
                  proj.customerId.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get projects by status
  Future<void> getProjectsByStatus(ProjectStatus status) async {
    _selectedStatus = status;
    _searchQuery = ''; // Clear search query when filtering by status
    _setLoading(true);
    _clearError();

    try {
      try {
        _projects = await _projectService.getProjectsByStatus(status);
      } catch (apiError) {
        // Fallback to local filtering
        final localProjects = await _localStorageService.getProjects();
        _projects =
            localProjects.where((proj) => proj.status == status).toList();
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Set selected project
  void setSelectedProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  // Get filtered projects
  List<Project> get filteredProjects {
    List<Project> filtered = _projects;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((project) =>
              project.jobName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              project.jobCode
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              project.projectId
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              project.customerId
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered
          .where((project) => project.status == _selectedStatus)
          .toList();
    }

    return filtered;
  }

  // Get unique statuses
  List<ProjectStatus> get uniqueStatuses {
    return ProjectStatus.values;
  }

  // Get projects count by status
  Map<ProjectStatus, int> getProjectsCountByStatus() {
    final Map<ProjectStatus, int> count = {};
    for (final project in _projects) {
      count[project.status] = (count[project.status] ?? 0) + 1;
    }
    return count;
  }

  // Get total cost
  double getTotalCost() {
    return _projects.fold(0.0, (sum, project) => sum + project.totalCost);
  }

  // Get total hours
  double getTotalHours() {
    return _projects.fold(0.0, (sum, project) => sum + project.totalHours);
  }

  // Get active projects count
  int getActiveProjectsCount() {
    return _projects
        .where((project) =>
            project.status == ProjectStatus.open ||
            project.status == ProjectStatus.inProgress)
        .length;
  }

  // Get completed projects count
  int getCompletedProjectsCount() {
    return _projects
        .where((project) => project.status == ProjectStatus.completed)
        .length;
  }

  // Update project status
  Future<bool> updateProjectStatus(String id, ProjectStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      // Update locally first
      final index = _projects.indexWhere((proj) => proj.projectId == id);
      if (index != -1) {
        final updatedProject = _projects[index].copyWith(status: status);
        _projects[index] = updatedProject;
        await _localStorageService.saveProjects(_projects);

        if (_selectedProject?.projectId == id) {
          _selectedProject = updatedProject;
        }
        notifyListeners();
      }

      // Try to sync with API
      try {
        // Note: This would typically call a specific API endpoint for status updates
        // For now, we'll use the general update method
        if (index != -1) {
          final updatedProject =
              await _projectService.updateProject(id, _projects[index]);
          _projects[index] = updatedProject;
          await _localStorageService.saveProjects(_projects);

          if (_selectedProject?.projectId == id) {
            _selectedProject = updatedProject;
          }
          notifyListeners();
        }
      } catch (apiError) {
        _logger
            .warning('API sync failed during project status update: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
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
