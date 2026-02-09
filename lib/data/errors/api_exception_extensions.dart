import '../../domain/errors/failure.dart';
import 'api_exception.dart';

extension ApiExceptionTypeFailureMapping on ApiExceptionType {
  FailureType toFailureType() {
    return switch (this) {
      ApiExceptionType.network => FailureType.network,
      ApiExceptionType.parsing => FailureType.parsing,
      ApiExceptionType.unexpected => FailureType.unknown,
    };
  }
}
