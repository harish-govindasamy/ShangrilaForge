import '../../data/datasources/project_local_datasource.dart';
import '../../data/datasources/project_remote_datasource.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/usecases/project_usecases.dart';
import '../../providers/enhanced_project_provider.dart';
import '../../features/employee/providers/enhanced_employee_provider.dart'
    as employee;
import '../../core/network/api_service.dart';
import '../../core/domain/usecases/employee_usecases.dart';
import '../../features/employee/data/repositories/employee_repository_impl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/services/local_storage_service.dart';

/// A factory class to create providers with their required dependencies
class ProviderFactory {
  /// Creates a properly initialized EnhancedProjectProvider with all required dependencies
  static EnhancedProjectProvider createEnhancedProjectProvider() {
    // Create the data sources
    final apiService = ApiService();
    final remoteDataSource =
        ProjectRemoteDataSourceImpl(apiService: apiService);
    final localDataSource = ProjectLocalDataSourceImpl();

    // Create the repository
    final repository = ProjectRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    // Create the use cases
    final projectUseCases = ProjectUseCases(repository: repository);

    // Create and return the provider
    return EnhancedProjectProvider(projectUseCases: projectUseCases);
  }

  /// Creates an EnhancedEmployeeProvider with its dependencies
  static employee.EnhancedEmployeeProvider createEnhancedEmployeeProvider() {
    // Create the repository
    final apiService = ApiService();
    final localStorageService = LocalStorageService();
    final connectivity = Connectivity();

    final repository = EmployeeRepositoryImpl(
      apiService: apiService,
      localStorageService: localStorageService,
      connectivity: connectivity,
    );

    // Create the use cases
    final getEmployeesUseCase = GetEmployeesUseCase(repository);
    final createEmployeeUseCase = CreateEmployeeUseCase(repository);
    final updateEmployeeUseCase = UpdateEmployeeUseCase(repository);
    final deleteEmployeeUseCase = DeleteEmployeeUseCase(repository);
    final searchEmployeesUseCase = SearchEmployeesUseCase(repository);
    final getEmployeeByIdUseCase = GetEmployeeByIdUseCase(repository);

    // Create and return the provider
    return employee.EnhancedEmployeeProvider(
      getEmployeesUseCase: getEmployeesUseCase,
      createEmployeeUseCase: createEmployeeUseCase,
      updateEmployeeUseCase: updateEmployeeUseCase,
      deleteEmployeeUseCase: deleteEmployeeUseCase,
      searchEmployeesUseCase: searchEmployeesUseCase,
      getEmployeeByIdUseCase: getEmployeeByIdUseCase,
    );
  }

  // Factory methods for other providers can be added here as needed
}
