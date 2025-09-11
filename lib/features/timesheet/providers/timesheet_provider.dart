import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../services/timesheet_service.dart';
import '../../../shared/models/timesheet_model.dart';
import '../../../core/services/local_storage_service.dart';

class TimesheetProvider extends ChangeNotifier {
  final TimesheetService _timesheetService = TimesheetService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final Logger _logger = Logger('TimesheetProvider');

  List<Timesheet> _timesheets = [];
  Timesheet? _selectedTimesheet;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  TimesheetStatus? _selectedStatus;
  String? _selectedEmployeeId;
  String? _selectedProjectId;

  List<Timesheet> get timesheets => _timesheets;
  Timesheet? get selectedTimesheet => _selectedTimesheet;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TimesheetStatus? get selectedStatus => _selectedStatus;
  String? get selectedEmployeeId => _selectedEmployeeId;
  String? get selectedProjectId => _selectedProjectId;

  // Get all timesheets
  Future<void> loadTimesheets() async {
    _setLoading(true);
    _clearError();

    try {
      // First load from local storage
      _timesheets = await _localStorageService.getTimesheets();
      notifyListeners();

      // Then try to sync with API
      try {
        final apiTimesheets = await _timesheetService.getTimesheets();
        _timesheets = apiTimesheets;
        await _localStorageService.saveTimesheets(_timesheets);
        notifyListeners();
      } catch (apiError) {
        // API failed, but we have local data
        if (_timesheets.isEmpty) {
          rethrow;
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get timesheet by ID
  Future<void> loadTimesheetById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // First try local storage
      final localTimesheets = await _localStorageService.getTimesheets();
      _selectedTimesheet = localTimesheets.firstWhere(
        (t) => t.userId == id,
        orElse: () => throw Exception('Timesheet not found'),
      );
      notifyListeners();

      // Then try API
      try {
        _selectedTimesheet = await _timesheetService.getTimesheetById(id);
        notifyListeners();
      } catch (apiError) {
        // API failed, but we have local data
        if (_selectedTimesheet == null) {
          rethrow;
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create timesheet
  Future<bool> createTimesheet(Timesheet timesheet) async {
    _setLoading(true);
    _clearError();

    try {
      // Add to local storage first
      _timesheets.add(timesheet);
      await _localStorageService.saveTimesheets(_timesheets);
      notifyListeners();

      // Try to sync with API
      try {
        final newTimesheet = await _timesheetService.createTimesheet(timesheet);
        // Update with server response
        final index =
            _timesheets.indexWhere((t) => t.userId == timesheet.userId);
        if (index != -1) {
          _timesheets[index] = newTimesheet;
          await _localStorageService.saveTimesheets(_timesheets);
          notifyListeners();
        }
      } catch (apiError) {
        // API failed, but local save succeeded
        _logger.warning('API sync failed during timesheet creation: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update timesheet
  Future<bool> updateTimesheet(String id, Timesheet timesheet) async {
    _setLoading(true);
    _clearError();

    try {
      // Update local storage first
      final index = _timesheets.indexWhere((ts) => ts.userId == id);
      if (index != -1) {
        _timesheets[index] = timesheet;
        await _localStorageService.saveTimesheets(_timesheets);
      }
      if (_selectedTimesheet?.userId == id) {
        _selectedTimesheet = timesheet;
      }
      notifyListeners();

      // Try to sync with API
      try {
        final updatedTimesheet =
            await _timesheetService.updateTimesheet(id, timesheet);
        // Update with server response
        if (index != -1) {
          _timesheets[index] = updatedTimesheet;
          await _localStorageService.saveTimesheets(_timesheets);
        }
        if (_selectedTimesheet?.userId == id) {
          _selectedTimesheet = updatedTimesheet;
        }
        notifyListeners();
      } catch (apiError) {
        _logger.warning('API sync failed during timesheet update: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete timesheet
  Future<bool> deleteTimesheet(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Remove from local storage first
      _timesheets.removeWhere((ts) => ts.userId == id);
      await _localStorageService.saveTimesheets(_timesheets);
      if (_selectedTimesheet?.userId == id) {
        _selectedTimesheet = null;
      }
      notifyListeners();

      // Try to sync with API
      try {
        await _timesheetService.deleteTimesheet(id);
      } catch (apiError) {
        _logger.warning('API sync failed during timesheet deletion: $apiError');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Submit timesheet
  Future<bool> submitTimesheet(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Find timesheet and validate
      final index = _timesheets.indexWhere((ts) => ts.userId == id);
      if (index == -1) {
        throw Exception('Timesheet not found');
      }

      final currentTimesheet = _timesheets[index];
      if (currentTimesheet.status != TimesheetStatus.draft) {
        throw Exception('Can only submit draft timesheets');
      }

      // Update status locally first
      _timesheets[index] = _timesheets[index].copyWith(
        status: TimesheetStatus.submitted,
        updatedAt: DateTime.now(),
      );
      await _localStorageService.saveTimesheets(_timesheets);

      if (_selectedTimesheet?.userId == id) {
        _selectedTimesheet = _timesheets[index];
      }
      notifyListeners();

      // Try to sync with API
      try {
        final updatedTimesheet =
            await _timesheetService.submitTimesheet(id, 'Employee Name');
        _timesheets[index] = updatedTimesheet;
        await _localStorageService.saveTimesheets(_timesheets);
        if (_selectedTimesheet?.userId == id) {
          _selectedTimesheet = updatedTimesheet;
        }
        notifyListeners();
        _logger.info('Timesheet submitted successfully: $id');
      } catch (apiError) {
        _logger
            .warning('API sync failed during timesheet submission: $apiError');
        // Keep local changes even if API fails
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      _logger.severe('Failed to submit timesheet: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Approve timesheet
  Future<bool> approveTimesheet(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Find timesheet and validate
      final index = _timesheets.indexWhere((ts) => ts.userId == id);
      if (index == -1) {
        throw Exception('Timesheet not found');
      }

      final currentTimesheet = _timesheets[index];
      if (currentTimesheet.status != TimesheetStatus.submitted) {
        throw Exception('Can only approve submitted timesheets');
      }

      // Update status locally first
      _timesheets[index] = _timesheets[index].copyWith(
        status: TimesheetStatus.approved,
        updatedAt: DateTime.now(),
      );
      await _localStorageService.saveTimesheets(_timesheets);

      if (_selectedTimesheet?.userId == id) {
        _selectedTimesheet = _timesheets[index];
      }
      notifyListeners();

      // Try to sync with API
      try {
        final updatedTimesheet = await _timesheetService.approveTimesheet(id);
        _timesheets[index] = updatedTimesheet;
        await _localStorageService.saveTimesheets(_timesheets);
        if (_selectedTimesheet?.userId == id) {
          _selectedTimesheet = updatedTimesheet;
        }
        notifyListeners();
        _logger.info('Timesheet approved successfully: $id');
      } catch (apiError) {
        _logger.warning('API sync failed during timesheet approval: $apiError');
        // Keep local changes even if API fails
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      _logger.severe('Failed to approve timesheet: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reject timesheet
  Future<bool> rejectTimesheet(String id, {String? feedback}) async {
    _setLoading(true);
    _clearError();

    try {
      // Find timesheet and validate
      final index = _timesheets.indexWhere((ts) => ts.userId == id);
      if (index == -1) {
        throw Exception('Timesheet not found');
      }

      final currentTimesheet = _timesheets[index];
      if (currentTimesheet.status != TimesheetStatus.submitted) {
        throw Exception('Can only reject submitted timesheets');
      }

      // Update status locally first
      _timesheets[index] = _timesheets[index].copyWith(
        status: TimesheetStatus.rejected,
        updatedAt: DateTime.now(),
      );
      await _localStorageService.saveTimesheets(_timesheets);

      if (_selectedTimesheet?.userId == id) {
        _selectedTimesheet = _timesheets[index];
      }
      notifyListeners();

      // Try to sync with API
      try {
        final updatedTimesheet =
            await _timesheetService.rejectTimesheet(id, feedback ?? 'Rejected');
        _timesheets[index] = updatedTimesheet;
        await _localStorageService.saveTimesheets(_timesheets);
        if (_selectedTimesheet?.userId == id) {
          _selectedTimesheet = updatedTimesheet;
        }
        notifyListeners();
        _logger.info('Timesheet rejected successfully: $id');
      } catch (apiError) {
        _logger
            .warning('API sync failed during timesheet rejection: $apiError');
        // Keep local changes even if API fails
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      _logger.severe('Failed to reject timesheet: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search timesheets
  Future<void> searchTimesheets(String query) async {
    _searchQuery = query;
    notifyListeners();
  }

  // Get timesheets by employee
  Future<void> getTimesheetsByEmployee(String employeeId) async {
    _selectedEmployeeId = employeeId;
    _searchQuery = '';
    notifyListeners();
  }

  // Get timesheets by project
  Future<void> getTimesheetsByProject(String projectId) async {
    _selectedProjectId = projectId;
    _searchQuery = '';
    notifyListeners();
  }

  // Get timesheets by status
  Future<void> getTimesheetsByStatus(TimesheetStatus status) async {
    _selectedStatus = status;
    _searchQuery = '';
    notifyListeners();
  }

  // Get timesheets by date range
  Future<void> getTimesheetsByDateRange(
      DateTime startDate, DateTime endDate) async {
    _setLoading(true);
    _clearError();

    try {
      _timesheets =
          await _timesheetService.getTimesheetsByDateRange(startDate, endDate);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Set selected timesheet
  void setSelectedTimesheet(Timesheet? timesheet) {
    _selectedTimesheet = timesheet;
    notifyListeners();
  }

  // Clear selected timesheet
  void clearSelectedTimesheet() {
    _selectedTimesheet = null;
    notifyListeners();
  }

  // Get filtered timesheets
  List<Timesheet> getFilteredTimesheets() {
    List<Timesheet> filtered = _timesheets;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((timesheet) {
        return timesheet.userId
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            timesheet.projectId
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            timesheet.taskId.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered
          .where((timesheet) => timesheet.status == _selectedStatus)
          .toList();
    }

    if (_selectedEmployeeId != null) {
      filtered = filtered
          .where((timesheet) => timesheet.employeeId == _selectedEmployeeId)
          .toList();
    }

    if (_selectedProjectId != null) {
      filtered = filtered
          .where((timesheet) => timesheet.projectId == _selectedProjectId)
          .toList();
    }

    return filtered;
  }

  // Get timesheets count by status
  Map<TimesheetStatus, int> getTimesheetsCountByStatus() {
    final Map<TimesheetStatus, int> count = {};
    for (final timesheet in _timesheets) {
      count[timesheet.status] = (count[timesheet.status] ?? 0) + 1;
    }
    return count;
  }

  // Get total hours
  double getTotalHours() {
    return _timesheets.fold(
        0.0, (sum, timesheet) => sum + timesheet.totalHours);
  }

  // Get pending timesheets count
  int getPendingTimesheetsCount() {
    return _timesheets
        .where((timesheet) => timesheet.status == TimesheetStatus.submitted)
        .length;
  }

  // Get approved timesheets count
  int getApprovedTimesheetsCount() {
    return _timesheets
        .where((timesheet) => timesheet.status == TimesheetStatus.approved)
        .length;
  }

  // Get draft timesheets count
  int getDraftTimesheetsCount() {
    return _timesheets
        .where((timesheet) => timesheet.status == TimesheetStatus.draft)
        .length;
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
