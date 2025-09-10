import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../repositories/employee_repository.dart';
import '../../../shared/models/employee_model.dart';

class GetEmployeesUseCase {
  final EmployeeRepository repository;

  const GetEmployeesUseCase(this.repository);

  Future<Either<Failure, List<Employee>>> call() async {
    return await repository.getEmployees();
  }
}

class GetEmployeeByIdUseCase {
  final EmployeeRepository repository;

  const GetEmployeeByIdUseCase(this.repository);

  Future<Either<Failure, Employee>> call(String id) async {
    return await repository.getEmployeeById(id);
  }
}

class CreateEmployeeUseCase {
  final EmployeeRepository repository;

  const CreateEmployeeUseCase(this.repository);

  Future<Either<Failure, Employee>> call(Employee employee) async {
    // Business logic validation
    final validationResult = _validateEmployee(employee);
    if (validationResult != null) {
      return Left(ValidationFailure(message: validationResult));
    }

    return await repository.createEmployee(employee);
  }

  String? _validateEmployee(Employee employee) {
    if (employee.empName.trim().isEmpty) {
      return 'Employee name is required';
    }

    if (employee.empEmail.trim().isEmpty) {
      return 'Employee email is required';
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(employee.empEmail)) {
      return 'Invalid email format';
    }

    if (employee.empDesignation.trim().isEmpty) {
      return 'Employee designation is required';
    }

    if (employee.empCmob.trim().isEmpty) {
      return 'Employee phone number is required';
    }

    return null;
  }
}

class UpdateEmployeeUseCase {
  final EmployeeRepository repository;

  const UpdateEmployeeUseCase(this.repository);

  Future<Either<Failure, Employee>> call(String id, Employee employee) async {
    return await repository.updateEmployee(id, employee);
  }
}

class DeleteEmployeeUseCase {
  final EmployeeRepository repository;

  const DeleteEmployeeUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteEmployee(id);
  }
}

class SearchEmployeesUseCase {
  final EmployeeRepository repository;

  const SearchEmployeesUseCase(this.repository);

  Future<Either<Failure, List<Employee>>> call(String query) async {
    if (query.trim().isEmpty) {
      return await repository.getEmployees();
    }
    return await repository.searchEmployees(query);
  }
}
