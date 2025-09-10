import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../config/environment_config.dart';
import 'mock_api_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;
  final MockApiService _mockApiService = MockApiService();

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: EnvironmentConfig.connectTimeout,
      receiveTimeout: EnvironmentConfig.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to requests
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized access
          await _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _handleUnauthorized() async {
    await clearAuthToken();
    // Navigate to login screen
    // This will be handled by the auth service
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userTokenKey, token);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
  }

  Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.userTokenKey);
    return _authToken;
  }

  // Generic HTTP methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Use mock service in development mode
    if (EnvironmentConfig.isDevelopment) {
      try {
        return await _mockApiService.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
        );
      } catch (e) {
        // If mock service fails, try real API
        if (e is DioException && e.type == DioExceptionType.badResponse) {
          // Mock service doesn't support this endpoint, try real API
        } else {
          rethrow;
        }
      }
    }

    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Use mock service in development mode
    if (EnvironmentConfig.isDevelopment) {
      try {
        return await _mockApiService.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      } catch (e) {
        // If mock service fails, try real API
        if (e is DioException && e.type == DioExceptionType.badResponse) {
          // Mock service doesn't support this endpoint, try real API
        } else {
          rethrow;
        }
      }
    }

    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // File upload
  Future<Response<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
        ...?data,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // File download
  Future<Response> downloadFile(
    String path, {
    String? savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection and try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return Exception(AppConstants.unauthorizedErrorMessage);
        } else if (statusCode == 500) {
          return Exception(AppConstants.serverErrorMessage);
        } else {
          return Exception(AppConstants.serverErrorMessage);
        }
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      case DioExceptionType.connectionError:
        // Check if it's a DNS resolution error
        if (error.message?.contains('ERR_NAME_NOT_RESOLVED') == true) {
          return Exception('Cannot connect to server. Please check your internet connection or contact support if the problem persists.');
        }
        return Exception(AppConstants.networkErrorMessage);
      default:
        return Exception(AppConstants.unknownErrorMessage);
    }
  }
}
