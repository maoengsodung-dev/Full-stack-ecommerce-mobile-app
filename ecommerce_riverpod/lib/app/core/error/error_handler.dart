import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';


class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is ServerException) {
      return ServerFailure(message: error.message, statusCode: error.statusCode);
    } else if (error is CacheException) {
      return CacheFailure(message: error.message);
    } else if (error is ValidationException) {
      return ValidationFailure(message: error.message, errors: error.errors);
    } else if (error is UnauthorizedException) {
      return AuthFailure(message: error.message);
    } else {
      return ServerFailure(message: error.toString());
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Server error occurred ($statusCode)';
        Map<String, dynamic>? errors;

        if (data is Map) {
          if (data['message'] != null) {
            message = data['message'].toString();
          }
          if (data['debug'] is Map && data['debug']['message'] != null) {
            final debugMsg = data['debug']['message'].toString();
            if (debugMsg.isNotEmpty &&
                (message.toLowerCase().contains('server error') ||
                    message.isEmpty)) {
              message = debugMsg;
            }
          }
          if (data['errors'] is Map) {
            errors = Map<String, dynamic>.from(data['errors'] as Map);
            final firstValue = errors.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              message = firstValue.first.toString();
            } else if (firstValue is String) {
              message = firstValue;
            }
          }
        }

        if (statusCode == 401) {
          return AuthFailure(message: message, statusCode: statusCode);
        }
        if (statusCode == 422) {
          return ValidationFailure(message: message, errors: errors);
        }
        return ServerFailure(message: message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Unable to connect to the server. Please verify your network.',
        );
      default:
        return ServerFailure(message: error.message ?? 'An unexpected error occurred.');
    }
  }
}
