import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dartz/dartz.dart';
import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/errors/failure.dart';
import 'package:restaurant_finder/domain/usecases/toggle_favourite.dart';
import '../helpers/mocks.dart';

void main() {
  late MockFavouriteRepository mockFavouriteRepository;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockFavouriteRepository = MockFavouriteRepository();
  });

  test('returns failure Result when repository fails', () async {
    when(() => mockFavouriteRepository.toggleFavourite(any()))
        .thenAnswer(
          (_) async => Left(
            Failure.unknown(message: 'Storage error.'),
          ),
        );

    final useCase = ToggleFavouriteUseCase(mockFavouriteRepository);
    final Result<void> result = await useCase('venue_1');

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) {
        expect(failure.type, FailureType.unknown);
        expect(failure.message, 'Storage error.');
      },
      (_) => fail('Expected failure result'),
    );
  });

  test('calls repository toggleFavourite with venue id and returns Result', () async {
    when(() => mockFavouriteRepository.toggleFavourite(any()))
        .thenAnswer((_) async => const Right(null));

    final useCase = ToggleFavouriteUseCase(mockFavouriteRepository);
    final Result<void> result = await useCase('venue_1');

    verify(() => mockFavouriteRepository.toggleFavourite('venue_1')).called(1);
    expect(result.isRight(), isTrue);
  });
}
