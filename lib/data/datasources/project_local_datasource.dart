import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/project_model.dart';

abstract class ProjectLocalDataSource {
  Future<List<Project>> getAllProjects();
  Future<List<Project>> getActiveProjects();
  Future<List<Project>> getArchivedProjects();
  Future<Project?> getProjectById(String projectId);
  Future<void> cacheProject(Project project);
  Future<void> cacheProjects(List<Project> projects);
  Future<void> deleteProject(String projectId);
  Future<void> clearCache();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  static const String _projectsKey = 'cached_projects';
  static const String _lastSyncKey = 'projects_last_sync';

  @override
  Future<List<Project>> getAllProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getString(_projectsKey);
      
      if (projectsJson != null) {
        final List<dynamic> jsonList = json.decode(projectsJson);
        return jsonList.map((json) => Project.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load projects from local storage: $e');
    }
  }

  @override
  Future<List<Project>> getActiveProjects() async {
    final allProjects = await getAllProjects();
    return allProjects.where((project) => !project.isArchived).toList();
  }

  @override
  Future<List<Project>> getArchivedProjects() async {
    final allProjects = await getAllProjects();
    return allProjects.where((project) => project.isArchived).toList();
  }

  @override
  Future<Project?> getProjectById(String projectId) async {
    final allProjects = await getAllProjects();
    try {
      return allProjects.firstWhere((project) => project.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheProject(Project project) async {
    try {
      final allProjects = await getAllProjects();
      final index = allProjects.indexWhere((p) => p.projectId == project.projectId);
      
      if (index != -1) {
        allProjects[index] = project;
      } else {
        allProjects.add(project);
      }
      
      await cacheProjects(allProjects);
    } catch (e) {
      throw Exception('Failed to cache project: $e');
    }
  }

  @override
  Future<void> cacheProjects(List<Project> projects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = json.encode(projects.map((p) => p.toJson()).toList());
      
      await prefs.setString(_projectsKey, projectsJson);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to cache projects: $e');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      final allProjects = await getAllProjects();
      allProjects.removeWhere((project) => project.projectId == projectId);
      await cacheProjects(allProjects);
    } catch (e) {
      throw Exception('Failed to delete project from cache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_projectsKey);
      await prefs.remove(_lastSyncKey);
    } catch (e) {
      throw Exception('Failed to clear project cache: $e');
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey);
      
      if (lastSyncString != null) {
        return DateTime.parse(lastSyncString);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
