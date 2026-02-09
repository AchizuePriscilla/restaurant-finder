enum FailureType { network, timeout, parsing, unknown }

class Failure implements Exception {
  const Failure({
    required this.type,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final FailureType type;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  factory Failure.network({
    String message = 'Network error.',
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return Failure(
      type: FailureType.network,
      message: message,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  factory Failure.timeout({
    String message = 'Request timed out.',
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return Failure(
      type: FailureType.timeout,
      message: message,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  factory Failure.parsing({
    String message = 'Failed to parse response.',
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return Failure(
      type: FailureType.parsing,
      message: message,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  factory Failure.unknown({
    String message = 'Unexpected error.',
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return Failure(
      type: FailureType.unknown,
      message: message,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    return 'Failure(type: $type, message: $message, cause: $cause)';
  }
}
