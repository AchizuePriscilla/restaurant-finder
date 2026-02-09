import 'package:restaurant_finder/data/errors/api_exception.dart';
import 'package:restaurant_finder/domain/errors/failure.dart';

extension ApiExceptionTypeFailureMapping on ApiExceptionType {
  FailureType toFailureType() {
    return switch (this) {
      ApiExceptionType.network => FailureType.network,
      ApiExceptionType.timeout => FailureType.timeout,
      ApiExceptionType.parsing => FailureType.parsing,
      ApiExceptionType.unexpected => FailureType.unknown,
    };
  }
}
