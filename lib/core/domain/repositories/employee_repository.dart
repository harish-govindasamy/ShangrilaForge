import 'package:dartz/dartz.dart';
import '../../../shared/models/employee_model.dart';
import '../../errors/failures.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, List<Employee>>> getEmployees();
  Future<Either<Failure, Employee>> getEmployeeById(String id);
  Future<Either<Failure, Employee>> createEmployee(Employee employee);
  Future<Either<Failure, Employee>> updateEmployee(
      String id, Employee employee);
  Future<Either<Failure, void>> deleteEmployee(String id);
  Future<Either<Failure, List<Employee>>> searchEmployees(String query);
  Future<Either<Failure, void>> syncWithRemote();
  Future<Either<Failure, List<Employee>>> getEmployeesByIds(List<String> ids);
}
