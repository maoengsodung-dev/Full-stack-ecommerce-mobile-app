abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure({required super.message, this.errors});
}
