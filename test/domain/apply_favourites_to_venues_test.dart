import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dartz/dartz.dart';
import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/errors/failure.dart';
import 'package:restaurant_finder/domain/usecases/apply_favourites_to_venues.dart';
import '../helpers/mocks.dart';
import '../helpers/test_data.dart';

void main() {
  late MockFavouriteRepository mockFavouriteRepository;

  setUp(() {
    mockFavouriteRepository = MockFavouriteRepository();
  });

  test('returns failure Result when getFavourites fails', () async {
    final venues = [venueEntity('a')];
    when(() => mockFavouriteRepository.getFavourites())
        .thenAnswer(
          (_) async => Left(
            Failure.unknown(message: 'Storage error'),
          ),
        );

    final useCase = ApplyFavouritesToVenues(mockFavouriteRepository);

    final result = await useCase(venues);
    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) {
        expect(failure.type, FailureType.unknown);
        expect(failure.message, 'Storage error');
      },
      (_) => fail('Expected failure result'),
    );
  });

  test('marks venues as favourite when id is in favourites set', () async {
    final venues = [venueEntity('a'), venueEntity('id1'), venueEntity('b')];
    when(() => mockFavouriteRepository.getFavourites())
        .thenAnswer((_) async => const Right({'id1'}));

    final useCase = ApplyFavouritesToVenues(mockFavouriteRepository);
    final Result<List<Venue>> result = await useCase(venues);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected success result'),
      (venuesWithFavs) {
        expect(
          venuesWithFavs.firstWhere((v) => v.id == 'a').isFavourite,
          isFalse,
        );
        expect(
          venuesWithFavs.firstWhere((v) => v.id == 'id1').isFavourite,
          isTrue,
        );
        expect(
          venuesWithFavs.firstWhere((v) => v.id == 'b').isFavourite,
          isFalse,
        );
      },
    );
    verify(() => mockFavouriteRepository.getFavourites()).called(1);
  });

  test('all venues have isFavourite false when favourites set is empty', () async {
    final venues = [venueEntity('a'), venueEntity('b')];
    when(() => mockFavouriteRepository.getFavourites())
        .thenAnswer((_) async => const Right(<String>{}));

    final useCase = ApplyFavouritesToVenues(mockFavouriteRepository);
    final Result<List<Venue>> result = await useCase(venues);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected success result'),
      (venuesWithFavs) {
        expect(venuesWithFavs.every((v) => !v.isFavourite), isTrue);
      },
    );
    verify(() => mockFavouriteRepository.getFavourites()).called(1);
  });

  test('returns Right with empty list when venues list is empty', () async {
    when(() => mockFavouriteRepository.getFavourites())
        .thenAnswer((_) async => const Right(<String>{}));

    final useCase = ApplyFavouritesToVenues(mockFavouriteRepository);
    final Result<List<Venue>> result = await useCase([]);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected success result'),
      (venuesWithFavs) {
        expect(venuesWithFavs, isEmpty);
      },
    );
    verify(() => mockFavouriteRepository.getFavourites()).called(1);
  });
}
