import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {
  final String message;
  final int? statusCode;

  const ServerFailure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class ValidationFailure extends Failure {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required this.message,
    this.fieldErrors,
  });

  @override
  List<Object> get props => [message, fieldErrors ?? {}];
}

class UnauthorizedFailure extends Failure {
  final String message;

  const UnauthorizedFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class NotFoundFailure extends Failure {
  final String message;

  const NotFoundFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class DatabaseFailure extends Failure {
  final String message;

  const DatabaseFailure({required this.message});

  @override
  List<Object> get props => [message];
}
