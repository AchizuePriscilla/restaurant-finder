import '../../domain/errors/failure.dart';

String messageForError(Object error, {required String fallback}) {
  if (error is Failure) {
    return error.message;
  }
  return fallback;
}
