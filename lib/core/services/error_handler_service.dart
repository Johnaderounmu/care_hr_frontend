import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

enum ErrorType {
  network,
  authentication,
  authorization,
  validation,
  server,
  unknown,
}

class AppError {
  final String message;
  final ErrorType type;
  final int? statusCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError{message: $message, type: $type, statusCode: $statusCode}';
  }
}

class ErrorHandlerService {
  static final Logger _logger = Logger();

  static AppError handleError(dynamic error) {
    _logger.e('Error occurred', error: error);

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is AppError) {
      return error;
    }

    // Generic error handling
    return AppError(
      message: 'An unexpected error occurred',
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: StackTrace.current,
    );
  }

  static AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          message: 'Connection timeout. Please check your internet connection.',
          type: ErrorType.network,
          statusCode: error.response?.statusCode,
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return AppError(
          message: 'Unable to connect to the server. Please check your internet connection.',
          type: ErrorType.network,
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return AppError(
          message: 'Request was cancelled',
          type: ErrorType.unknown,
          originalError: error,
        );

      default:
        return AppError(
          message: 'Network error occurred',
          type: ErrorType.network,
          originalError: error,
        );
    }
  }

  static AppError _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    switch (statusCode) {
      case 400:
        return AppError(
          message: _extractErrorMessage(responseData) ?? 'Invalid request',
          type: ErrorType.validation,
          statusCode: statusCode,
          originalError: error,
        );

      case 401:
        return AppError(
          message: 'Authentication required. Please log in again.',
          type: ErrorType.authentication,
          statusCode: statusCode,
          originalError: error,
        );

      case 403:
        return AppError(
          message: 'You don\'t have permission to perform this action.',
          type: ErrorType.authorization,
          statusCode: statusCode,
          originalError: error,
        );

      case 404:
        return AppError(
          message: 'Requested resource not found.',
          type: ErrorType.server,
          statusCode: statusCode,
          originalError: error,
        );

      case 422:
        return AppError(
          message: _extractErrorMessage(responseData) ?? 'Validation failed',
          type: ErrorType.validation,
          statusCode: statusCode,
          originalError: error,
        );

      case 429:
        return AppError(
          message: 'Too many requests. Please try again later.',
          type: ErrorType.server,
          statusCode: statusCode,
          originalError: error,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return AppError(
          message: 'Server error. Please try again later.',
          type: ErrorType.server,
          statusCode: statusCode,
          originalError: error,
        );

      default:
        return AppError(
          message: 'An error occurred. Please try again.',
          type: ErrorType.server,
          statusCode: statusCode,
          originalError: error,
        );
    }
  }

  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Try different common error message fields
      return responseData['message'] ?? 
             responseData['error'] ?? 
             responseData['detail'] ??
             responseData['errors']?.toString();
    }
    return responseData?.toString();
  }

  static String getDisplayMessage(AppError error) {
    switch (error.type) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.authentication:
        return 'Please log in again to continue.';
      case ErrorType.authorization:
        return 'You don\'t have permission to perform this action.';
      case ErrorType.validation:
        return error.message;
      case ErrorType.server:
        return 'Server error. Please try again later.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
}