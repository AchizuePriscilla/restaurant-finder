enum ApiExceptionType {
  network,
  parsing,
  unexpected,
}

class ApiException implements Exception {
  ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.error,
  });

  final String message;
  final ApiExceptionType type;
  final int? statusCode;
  final Object? error;

  @override
  String toString() {
    return 'ApiException(type: $type, statusCode: $statusCode, message: $message, error: $error)';
  }
}
