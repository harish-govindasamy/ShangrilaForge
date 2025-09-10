import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  // Mock data
  final Map<String, dynamic> _mockUsers = {
    'admin@shangrila.com': {
      'userId': '1',
      'userName': 'Admin User',
      'employeeId': 'EMP001',
      'role': 'admin',
      'password': '',
      'new_password': '',
      'createdAt': '2024-01-01T00:00:00Z',
      'updatedAt': '2024-01-01T00:00:00Z',
      'createdBy': 'system',
      'updatedBy': 'system',
      'recordTracking': [],
    },
    'principal@shangrila.com': {
      'userId': '2',
      'userName': 'Principal User',
      'employeeId': 'EMP002',
      'role': 'principal',
      'password': '',
      'new_password': '',
      'createdAt': '2024-01-01T00:00:00Z',
      'updatedAt': '2024-01-01T00:00:00Z',
      'createdBy': 'system',
      'updatedBy': 'system',
      'recordTracking': [],
    },
    'employee@shangrila.com': {
      'userId': '3',
      'userName': 'Employee User',
      'employeeId': 'EMP003',
      'role': 'employee',
      'password': '',
      'new_password': '',
      'createdAt': '2024-01-01T00:00:00Z',
      'updatedAt': '2024-01-01T00:00:00Z',
      'createdBy': 'system',
      'updatedBy': 'system',
      'recordTracking': [],
    },
  };

  final Map<String, dynamic> _mockEmployees = {
    'admin@shangrila.com': {
      'employeeId': 'EMP001',
      'emp_name': 'Admin User',
      'emp_cemail': 'admin@shangrila.com',
      'emp_dob': '1990-01-01T00:00:00Z',
      'emp_address': '123 Admin Street',
      'emp_designation': 'System Administrator',
      'emp_exp': 5,
      'emp_bgp': 'A+',
      'emp_category': 'IT',
      'emp_cmob': '+1234567890',
      'joindate': '2024-01-01T00:00:00Z',
      'salary': '75000.00',
      'bankaccount': '1234567890',
      'ifsccode': 'SBIN0001234',
      'unique_identification_number': 'ADMIN001',
      'ssn_no': '123-45-6789',
      'emergencyname': 'Emergency Contact',
      'emergencyrelation': 'Spouse',
      'emergencyphone': '+1234567891',
      'gender': 'Male',
      'maritalStatus': 'Single',
      'parentName': 'Parent Name',
      'city': 'New York',
      'state': 'NY',
      'country': 'USA',
      'postalCode': '10001',
      'skills': ['Management', 'System Administration'],
      'recordTracking': [],
    },
    'principal@shangrila.com': {
      'employeeId': 'EMP002',
      'emp_name': 'Principal User',
      'emp_cemail': 'principal@shangrila.com',
      'emp_dob': '1985-05-15T00:00:00Z',
      'emp_address': '456 Principal Avenue',
      'emp_designation': 'Principal Engineer',
      'emp_exp': 8,
      'emp_bgp': 'B+',
      'emp_category': 'Management',
      'emp_cmob': '+1234567891',
      'joindate': '2024-01-01T00:00:00Z',
      'salary': '95000.00',
      'bankaccount': '2345678901',
      'ifsccode': 'SBIN0001235',
      'unique_identification_number': 'PRIN001',
      'ssn_no': '234-56-7890',
      'emergencyname': 'Emergency Contact',
      'emergencyrelation': 'Spouse',
      'emergencyphone': '+1234567892',
      'gender': 'Female',
      'maritalStatus': 'Married',
      'parentName': 'Parent Name',
      'city': 'Los Angeles',
      'state': 'CA',
      'country': 'USA',
      'postalCode': '90210',
      'skills': ['Engineering', 'Project Management'],
      'recordTracking': [],
    },
    'employee@shangrila.com': {
      'employeeId': 'EMP003',
      'emp_name': 'Employee User',
      'emp_cemail': 'employee@shangrila.com',
      'emp_dob': '1992-12-10T00:00:00Z',
      'emp_address': '789 Employee Road',
      'emp_designation': 'Software Engineer',
      'emp_exp': 3,
      'emp_bgp': 'O+',
      'emp_category': 'Engineering',
      'emp_cmob': '+1234567892',
      'joindate': '2024-01-01T00:00:00Z',
      'salary': '65000.00',
      'bankaccount': '3456789012',
      'ifsccode': 'SBIN0001236',
      'unique_identification_number': 'EMP001',
      'ssn_no': '345-67-8901',
      'emergencyname': 'Emergency Contact',
      'emergencyrelation': 'Parent',
      'emergencyphone': '+1234567893',
      'gender': 'Male',
      'maritalStatus': 'Single',
      'parentName': 'Parent Name',
      'city': 'Chicago',
      'state': 'IL',
      'country': 'USA',
      'postalCode': '60601',
      'skills': ['Flutter', 'Dart', 'Mobile Development'],
      'recordTracking': [],
    },
  };

  final Map<String, String> _mockPasswords = {
    'admin@shangrila.com': 'admin123',
    'principal@shangrila.com': 'principal123',
    'employee@shangrila.com': 'employee123',
  };

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (path == ApiEndpoints.login) {
      return _handleLogin(data) as Response<T>;
    } else if (path == ApiEndpoints.logout) {
      return _handleLogout() as Response<T>;
    } else if (path == ApiEndpoints.changePassword) {
      return _handleChangePassword(data) as Response<T>;
    } else if (path == ApiEndpoints.createEmployee) {
      return _handleCreateEmployee(data) as Response<T>;
    } else if (path == ApiEndpoints.createProject) {
      return _handleCreateProject(data) as Response<T>;
    } else if (path == ApiEndpoints.createTimesheet) {
      return _handleCreateTimesheet(data) as Response<T>;
    } else if (path == ApiEndpoints.createCustomer) {
      return _handleCreateCustomer(data) as Response<T>;
    }

    throw DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 404,
        data: {'error': 'Endpoint not found'},
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (path == '/auth/verify') {
      return _handleVerifyToken() as Response<T>;
    } else if (path == '/employees') {
      return _handleGetEmployees(queryParameters) as Response<T>;
    } else if (path.startsWith('/employees/')) {
      // Handle individual employee by ID
      final employeeId = path.split('/').last;
      return _handleGetEmployeeById(employeeId) as Response<T>;
    } else if (path == '/projects') {
      return _handleGetProjects(queryParameters) as Response<T>;
    } else if (path.startsWith('/projects/')) {
      // Handle individual project by ID
      final projectId = path.split('/').last;
      return _handleGetProjectById(projectId) as Response<T>;
    } else if (path == '/timesheets') {
      return _handleGetTimesheets(queryParameters) as Response<T>;
    } else if (path.startsWith('/timesheets/')) {
      // Handle individual timesheet by ID
      final timesheetId = path.split('/').last;
      return _handleGetTimesheetById(timesheetId) as Response<T>;
    } else if (path == '/customers') {
      return _handleGetCustomers(queryParameters) as Response<T>;
    } else if (path.startsWith('/customers/')) {
      // Handle individual customer by ID
      final customerId = path.split('/').last;
      return _handleGetCustomerById(customerId) as Response<T>;
    } else if (path == '/dashboard/summary') {
      return _handleGetDashboardSummary() as Response<T>;
    }

    throw DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 404,
        data: {'error': 'Endpoint not found'},
      ),
    );
  }

  Response _handleLogin(dynamic data) {
    final email = data['email'] as String;
    final password = data['password'] as String;

    if (_mockUsers.containsKey(email) && _mockPasswords[email] == password) {
      final userData = _mockUsers[email]!;
      final employeeData = _mockEmployees[email];

      return Response(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        statusCode: 200,
        data: {
          'token': 'mock_jwt_token_${userData['id']}',
          'user': userData,
          'employee': employeeData,
        },
      );
    } else {
      return Response(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        statusCode: 401,
        data: {'error': 'Invalid credentials'},
      );
    }
  }

  Response _handleLogout() {
    return Response(
      requestOptions: RequestOptions(path: ApiEndpoints.logout),
      statusCode: 200,
      data: {'message': 'Logged out successfully'},
    );
  }

  Response _handleChangePassword(dynamic data) {
    return Response(
      requestOptions: RequestOptions(path: ApiEndpoints.changePassword),
      statusCode: 200,
      data: {'message': 'Password changed successfully'},
    );
  }

  Response _handleVerifyToken() {
    return Response(
      requestOptions: RequestOptions(path: '/auth/verify'),
      statusCode: 200,
      data: {
        'user': _mockUsers['admin@shangrila.com'],
        'employee': _mockEmployees['admin@shangrila.com'],
      },
    );
  }

  Response _handleGetEmployees(Map<String, dynamic>? queryParameters) {
    List<Map<String, dynamic>> employees =
        _mockEmployees.values.map((e) => Map<String, dynamic>.from(e)).toList();

    // Handle search query
    if (queryParameters != null && queryParameters.containsKey('search')) {
      final searchQuery = queryParameters['search'].toString().toLowerCase();
      employees = employees.where((employee) {
        final name = employee['emp_name'].toString().toLowerCase();
        final email = employee['emp_cemail'].toString().toLowerCase();
        final designation =
            employee['emp_designation'].toString().toLowerCase();
        final employeeId = employee['employeeId'].toString().toLowerCase();

        return name.contains(searchQuery) ||
            email.contains(searchQuery) ||
            designation.contains(searchQuery) ||
            employeeId.contains(searchQuery);
      }).toList();
    }

    // Handle designation filter
    if (queryParameters != null && queryParameters.containsKey('designation')) {
      final designation = queryParameters['designation'].toString();
      employees = employees.where((employee) {
        return employee['emp_designation'].toString() == designation;
      }).toList();
    }

    return Response(
      requestOptions: RequestOptions(path: '/employees'),
      statusCode: 200,
      data: {
        'employees': employees,
        'data': employees, // Add both for compatibility
        'total': employees.length,
      },
    );
  }

  Response _handleGetEmployeeById(String employeeId) {
    final employee = _mockEmployees.values.firstWhere(
      (employee) => employee['employeeId'] == employeeId,
      orElse: () => {},
    );

    if (employee.isNotEmpty) {
      return Response(
        requestOptions: RequestOptions(path: '/employees/$employeeId'),
        statusCode: 200,
        data: employee,
      );
    } else {
      return Response(
        requestOptions: RequestOptions(path: '/employees/$employeeId'),
        statusCode: 404,
        data: {'error': 'Employee not found'},
      );
    }
  }

  Response _handleGetProjects(Map<String, dynamic>? queryParameters) {
    return Response(
      requestOptions: RequestOptions(path: '/projects'),
      statusCode: 200,
      data: {
        'projects': [
          {
            'projectId': '1',
            'job_name': 'Website Redesign',
            'customer_id': 'CUST001',
            'job_code': 'WEB001',
            'totalCost': 50000.0,
            'totalHours': 200.0,
            'status': 'inprogress',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-15T00:00:00Z',
            'createdBy': 'admin',
            'updatedBy': 'admin',
            'recordTracking': [],
          },
          {
            'projectId': '2',
            'job_name': 'Mobile App Development',
            'customer_id': 'CUST002',
            'job_code': 'MOB001',
            'totalCost': 75000.0,
            'totalHours': 300.0,
            'status': 'completed',
            'createdAt': '2023-09-01T00:00:00Z',
            'updatedAt': '2024-01-15T00:00:00Z',
            'createdBy': 'admin',
            'updatedBy': 'admin',
            'recordTracking': [],
          },
        ],
        'total': 2,
      },
    );
  }

  Response _handleGetProjectById(String projectId) {
    final projects = [
      {
        'projectId': '1',
        'job_name': 'Website Redesign',
        'customer_id': 'CUST001',
        'job_code': 'WEB001',
        'totalCost': 50000.0,
        'totalHours': 200.0,
        'status': 'inprogress',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-15T00:00:00Z',
        'createdBy': 'admin',
        'updatedBy': 'admin',
        'recordTracking': [],
      },
      {
        'projectId': '2',
        'job_name': 'Mobile App Development',
        'customer_id': 'CUST002',
        'job_code': 'MOB001',
        'totalCost': 75000.0,
        'totalHours': 300.0,
        'status': 'completed',
        'createdAt': '2023-09-01T00:00:00Z',
        'updatedAt': '2024-01-15T00:00:00Z',
        'createdBy': 'admin',
        'updatedBy': 'admin',
        'recordTracking': [],
      },
    ];

    final project = projects.firstWhere(
      (project) => project['projectId'] == projectId,
      orElse: () => {},
    );

    if (project.isNotEmpty) {
      return Response(
        requestOptions: RequestOptions(path: '/projects/$projectId'),
        statusCode: 200,
        data: project,
      );
    } else {
      return Response(
        requestOptions: RequestOptions(path: '/projects/$projectId'),
        statusCode: 404,
        data: {'error': 'Project not found'},
      );
    }
  }

  Response _handleGetTimesheets(Map<String, dynamic>? queryParameters) {
    List<Map<String, dynamic>> timesheets = [
      {
        'user_id': 'USER001',
        'employee_id': 'EMP001',
        'project_id': '1',
        'task_id': 'TASK001',
        'week_start_date': '2024-01-15T00:00:00Z',
        'week_end_date': '2024-01-30T00:00:00Z',
        'created_by': 'admin',
        'day_1_hours': 8.0,
        'day_2_hours': 8.0,
        'day_3_hours': 8.0,
        'day_4_hours': 8.0,
        'day_5_hours': 8.0,
        'day_6_hours': 0.0,
        'day_7_hours': 0.0,
        'day_8_hours': 0.0,
        'day_9_hours': 0.0,
        'day_10_hours': 0.0,
        'day_11_hours': 0.0,
        'day_12_hours': 0.0,
        'day_13_hours': 0.0,
        'day_14_hours': 0.0,
        'day_15_hours': 0.0,
        'day_16_hours': 0.0,
        'status': 'approved',
        'recordTracking': [],
      },
      {
        'user_id': 'USER002',
        'employee_id': 'EMP002',
        'project_id': '2',
        'task_id': 'TASK002',
        'week_start_date': '2024-01-15T00:00:00Z',
        'week_end_date': '2024-01-30T00:00:00Z',
        'created_by': 'admin',
        'day_1_hours': 7.5,
        'day_2_hours': 7.5,
        'day_3_hours': 7.5,
        'day_4_hours': 7.5,
        'day_5_hours': 7.5,
        'day_6_hours': 4.0,
        'day_7_hours': 4.0,
        'day_8_hours': 6.0,
        'day_9_hours': 6.0,
        'day_10_hours': 6.0,
        'day_11_hours': 0.0,
        'day_12_hours': 0.0,
        'day_13_hours': 0.0,
        'day_14_hours': 0.0,
        'day_15_hours': 0.0,
        'day_16_hours': 0.0,
        'status': 'submitted',
        'recordTracking': [],
      },
      {
        'user_id': 'USER003',
        'employee_id': 'EMP003',
        'project_id': '1',
        'task_id': 'TASK003',
        'week_start_date': '2024-01-22T00:00:00Z',
        'week_end_date': '2024-02-06T00:00:00Z',
        'created_by': 'employee',
        'day_1_hours': 8.0,
        'day_2_hours': 8.0,
        'day_3_hours': 8.0,
        'day_4_hours': 8.0,
        'day_5_hours': 8.0,
        'day_6_hours': 0.0,
        'day_7_hours': 0.0,
        'day_8_hours': 8.0,
        'day_9_hours': 8.0,
        'day_10_hours': 8.0,
        'day_11_hours': 8.0,
        'day_12_hours': 8.0,
        'day_13_hours': 0.0,
        'day_14_hours': 0.0,
        'day_15_hours': 0.0,
        'day_16_hours': 0.0,
        'status': 'draft',
        'recordTracking': [],
      },
    ];

    // Handle search query
    if (queryParameters != null && queryParameters.containsKey('search')) {
      final searchQuery = queryParameters['search'].toString().toLowerCase();
      timesheets = timesheets.where((timesheet) {
        final userId = timesheet['user_id'].toString().toLowerCase();
        final employeeId = timesheet['employee_id'].toString().toLowerCase();
        final projectId = timesheet['project_id'].toString().toLowerCase();
        final taskId = timesheet['task_id'].toString().toLowerCase();

        return userId.contains(searchQuery) ||
            employeeId.contains(searchQuery) ||
            projectId.contains(searchQuery) ||
            taskId.contains(searchQuery);
      }).toList();
    }

    // Handle status filter
    if (queryParameters != null && queryParameters.containsKey('status')) {
      final status = queryParameters['status'].toString().toLowerCase();
      timesheets = timesheets.where((timesheet) {
        return timesheet['status'].toString().toLowerCase() == status;
      }).toList();
    }

    // Handle employee filter
    if (queryParameters != null && queryParameters.containsKey('employee_id')) {
      final employeeId = queryParameters['employee_id'].toString();
      timesheets = timesheets.where((timesheet) {
        return timesheet['employee_id'].toString() == employeeId;
      }).toList();
    }

    // Handle project filter
    if (queryParameters != null && queryParameters.containsKey('project_id')) {
      final projectId = queryParameters['project_id'].toString();
      timesheets = timesheets.where((timesheet) {
        return timesheet['project_id'].toString() == projectId;
      }).toList();
    }

    return Response(
      requestOptions: RequestOptions(path: '/timesheets'),
      statusCode: 200,
      data: {
        'timesheets': timesheets,
        'data': timesheets, // Add both for compatibility
        'total': timesheets.length,
      },
    );
  }

  Response _handleGetTimesheetById(String timesheetId) {
    final timesheets = [
      {
        'timesheetId': '1',
        'user_id': 'USER001',
        'employee_id': 'EMP001',
        'project_id': '1',
        'task_id': 'TASK001',
        'week_start_date': '2024-01-15T00:00:00Z',
        'week_end_date': '2024-01-30T00:00:00Z',
        'created_by': 'admin',
        'day_1_hours': 8.0,
        'day_2_hours': 8.0,
        'day_3_hours': 8.0,
        'day_4_hours': 8.0,
        'day_5_hours': 8.0,
        'day_6_hours': 0.0,
        'day_7_hours': 0.0,
        'status': 'approved',
        'recordTracking': [],
      },
      {
        'timesheetId': '2',
        'user_id': 'USER002',
        'employee_id': 'EMP002',
        'project_id': '2',
        'task_id': 'TASK002',
        'week_start_date': '2024-01-15T00:00:00Z',
        'week_end_date': '2024-01-30T00:00:00Z',
        'created_by': 'admin',
        'day_1_hours': 7.5,
        'day_2_hours': 7.5,
        'day_3_hours': 7.5,
        'day_4_hours': 7.5,
        'day_5_hours': 7.5,
        'day_6_hours': 4.0,
        'day_7_hours': 4.0,
        'status': 'submitted',
        'recordTracking': [],
      },
    ];

    final timesheet = timesheets.firstWhere(
      (timesheet) => timesheet['timesheetId'] == timesheetId,
      orElse: () => {},
    );

    if (timesheet.isNotEmpty) {
      return Response(
        requestOptions: RequestOptions(path: '/timesheets/$timesheetId'),
        statusCode: 200,
        data: timesheet,
      );
    } else {
      return Response(
        requestOptions: RequestOptions(path: '/timesheets/$timesheetId'),
        statusCode: 404,
        data: {'error': 'Timesheet not found'},
      );
    }
  }

  Response _handleGetCustomers(Map<String, dynamic>? queryParameters) {
    List<Map<String, dynamic>> customers = [
      {
        'Customer_id': '1',
        'Cust_name': 'ABC Corporation',
        'Cust_code': 'ABC001',
        'Cust_email': 'contact@abccorp.com',
        'Cust_address': '123 Business St, City, State',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-15T00:00:00Z',
        'createdBy': 'admin',
        'updatedBy': 'admin',
        'recordTracking': [],
      },
      {
        'Customer_id': '2',
        'Cust_name': 'XYZ Industries',
        'Cust_code': 'XYZ001',
        'Cust_email': 'info@xyzind.com',
        'Cust_address': '456 Industrial Ave, City, State',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-15T00:00:00Z',
        'createdBy': 'admin',
        'updatedBy': 'admin',
        'recordTracking': [],
      },
    ];

    // Handle search query
    if (queryParameters != null && queryParameters.containsKey('search')) {
      final searchQuery = queryParameters['search'].toString().toLowerCase();
      customers = customers.where((customer) {
        final name = customer['Cust_name'].toString().toLowerCase();
        final email = customer['Cust_email'].toString().toLowerCase();
        final code = customer['Cust_code'].toString().toLowerCase();
        final customerId = customer['Customer_id'].toString().toLowerCase();

        return name.contains(searchQuery) ||
            email.contains(searchQuery) ||
            code.contains(searchQuery) ||
            customerId.contains(searchQuery);
      }).toList();
    }

    return Response(
      requestOptions: RequestOptions(path: '/customers'),
      statusCode: 200,
      data: {
        'customers': customers,
        'data': customers, // Add both for compatibility
        'total': customers.length,
      },
    );
  }

  Response _handleGetCustomerById(String customerId) {
    final customers = [
      {
        'Customer_id': '1',
        'Cust_name': 'ABC Corporation',
        'Cust_code': 'ABC001',
        'Cust_email': 'contact@abccorp.com',
        'Cust_address': '123 Business St, City, State',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-15T00:00:00Z',
        'createdBy': 'admin',
        'updatedBy': 'admin',
        'recordTracking': [],
      },
      {
        'Customer_id': '2',
        'Cust_name': 'XYZ Industries',
        'Cust_code': 'XYZ001',
        'Cust_email': 'info@xyzind.com',
        'Cust_address': '456 Industrial Ave, City, State',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-15T00:00:00Z',
        'createdBy': 'admin',
        'updatedBy': 'admin',
        'recordTracking': [],
      },
    ];

    final customer = customers.firstWhere(
      (customer) => customer['Customer_id'] == customerId,
      orElse: () => {},
    );

    if (customer.isNotEmpty) {
      return Response(
        requestOptions: RequestOptions(path: '/customers/$customerId'),
        statusCode: 200,
        data: customer,
      );
    } else {
      return Response(
        requestOptions: RequestOptions(path: '/customers/$customerId'),
        statusCode: 404,
        data: {'error': 'Customer not found'},
      );
    }
  }

  Response _handleGetDashboardSummary() {
    return Response(
      requestOptions: RequestOptions(path: '/dashboard/summary'),
      statusCode: 200,
      data: {
        'total_employees': 3,
        'total_projects': 2,
        'total_customers': 2,
        'total_hours': 15.5,
        'active_projects': 1,
        'pending_timesheets': 1,
        'completed_projects': 1,
        'total_revenue': 125000.0,
        'monthly_growth': 12.5,
      },
    );
  }

  Response _handleCreateEmployee(dynamic data) {
    return Response(
      requestOptions: RequestOptions(path: ApiEndpoints.createEmployee),
      statusCode: 201,
      data: data,
    );
  }

  Response _handleCreateProject(dynamic data) {
    return Response(
      requestOptions: RequestOptions(path: ApiEndpoints.createProject),
      statusCode: 201,
      data: data,
    );
  }

  Response _handleCreateTimesheet(dynamic data) {
    return Response(
      requestOptions: RequestOptions(path: ApiEndpoints.createTimesheet),
      statusCode: 201,
      data: data,
    );
  }

  Response _handleCreateCustomer(dynamic data) {
    return Response(
      requestOptions: RequestOptions(path: ApiEndpoints.createCustomer),
      statusCode: 201,
      data: data,
    );
  }
}
