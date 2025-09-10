import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../../shared/models/employee_model.dart';
import '../../shared/models/project_model.dart';
import '../../shared/models/customer_model.dart';
import '../../shared/models/timesheet_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  static final Logger _logger = Logger('LocalStorageService');
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _employeesKey = 'employees';
  static const String _projectsKey = 'projects';
  static const String _customersKey = 'customers';
  static const String _timesheetsKey = 'timesheets';

  // Employee methods
  Future<List<Employee>> getEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeesJson = prefs.getString(_employeesKey);
      if (employeesJson != null) {
        final List<dynamic> employeesList = json.decode(employeesJson);
        return employeesList.map((json) => Employee.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error loading employees from local storage: $e');
      return [];
    }
  }

  Future<void> saveEmployees(List<Employee> employees) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeesJson =
          json.encode(employees.map((e) => e.toJson()).toList());
      await prefs.setString(_employeesKey, employeesJson);
    } catch (e) {
      _logger.severe('Error saving employees to local storage: $e');
    }
  }

  // Project methods
  Future<List<Project>> getProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getString(_projectsKey);
      if (projectsJson != null) {
        final List<dynamic> projectsList = json.decode(projectsJson);
        return projectsList.map((json) => Project.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error loading projects from local storage: $e');
      return [];
    }
  }

  Future<void> saveProjects(List<Project> projects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson =
          json.encode(projects.map((p) => p.toJson()).toList());
      await prefs.setString(_projectsKey, projectsJson);
    } catch (e) {
      _logger.severe('Error saving projects to local storage: $e');
    }
  }

  // Customer methods
  Future<List<Customer>> getCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customersJson = prefs.getString(_customersKey);
      if (customersJson != null) {
        final List<dynamic> customersList = json.decode(customersJson);
        return customersList.map((json) => Customer.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error loading customers from local storage: $e');
      return [];
    }
  }

  Future<void> saveCustomers(List<Customer> customers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customersJson =
          json.encode(customers.map((c) => c.toJson()).toList());
      await prefs.setString(_customersKey, customersJson);
    } catch (e) {
      _logger.severe('Error saving customers to local storage: $e');
    }
  }

  // Timesheet methods
  Future<List<Timesheet>> getTimesheets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timesheetsJson = prefs.getString(_timesheetsKey);
      if (timesheetsJson != null) {
        final List<dynamic> timesheetsList = json.decode(timesheetsJson);
        return timesheetsList.map((json) => Timesheet.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error loading timesheets from local storage: $e');
      return [];
    }
  }

  Future<void> saveTimesheets(List<Timesheet> timesheets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timesheetsJson =
          json.encode(timesheets.map((t) => t.toJson()).toList());
      await prefs.setString(_timesheetsKey, timesheetsJson);
    } catch (e) {
      _logger.severe('Error saving timesheets to local storage: $e');
    }
  }

  // Clear methods
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      _logger.severe('Error clearing local storage: $e');
    }
  }

  Future<void> clearEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_employeesKey);
    } catch (e) {
      _logger.severe('Error clearing employees from local storage: $e');
    }
  }

  Future<void> clearProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_projectsKey);
    } catch (e) {
      _logger.severe('Error clearing projects from local storage: $e');
    }
  }

  Future<void> clearCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_customersKey);
    } catch (e) {
      _logger.severe('Error clearing customers from local storage: $e');
    }
  }

  Future<void> clearTimesheets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_timesheetsKey);
    } catch (e) {
      _logger.severe('Error clearing timesheets from local storage: $e');
    }
  }
}
