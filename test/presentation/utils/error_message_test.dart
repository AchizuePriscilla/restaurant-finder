import 'package:flutter_test/flutter_test.dart';

import 'package:restaurant_finder/domain/errors/failure.dart';
import 'package:restaurant_finder/presentation/utils/error_message.dart';

void main() {
  test('returns Failure message when error is Failure', () {
    const failure = Failure(
      type: FailureType.network,
      message: 'Network error.',
    );
    expect(
      messageForError(failure, fallback: 'fallback'),
      'Network error.',
    );
  });

  test('returns fallback when error is not Failure', () {
    expect(
      messageForError(Exception(), fallback: 'Something went wrong'),
      'Something went wrong',
    );
  });
}
