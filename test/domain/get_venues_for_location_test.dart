import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dartz/dartz.dart';
import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/errors/failure.dart';
import 'package:restaurant_finder/domain/usecases/get_venues_for_location.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';
import '../helpers/mocks.dart';
import '../helpers/test_data.dart';

void main() {
  late MockVenueRepository mockVenueRepository;

  setUpAll(() {
    registerFallbackValue(const LatLng(latitude: 0, longitude: 0));
  });

  setUp(() {
    mockVenueRepository = MockVenueRepository();
  });

  const location = LatLng(latitude: 60.17, longitude: 24.94);

  test('returns failure Result when repository fails', () async {
    when(() => mockVenueRepository.fetchNearbyVenues(any()))
        .thenAnswer(
          (_) async => Left(
            Failure.unknown(message: 'Network error.'),
          ),
        );

    final useCase = GetVenuesForLocation(mockVenueRepository);

    final result = await useCase(location, limit: 15);
    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) {
        expect(failure.type, FailureType.unknown);
        expect(failure.message, 'Network error.');
      },
      (_) => fail('Expected failure result'),
    );
  });

  test('returns first 15 venues when repository returns more', () async {
    final venues = List<Venue>.generate(20, (index) => venueEntity('v$index'));
    when(() => mockVenueRepository.fetchNearbyVenues(any()))
        .thenAnswer((_) async => right(venues));

    final useCase = GetVenuesForLocation(mockVenueRepository);
    final Result<List<Venue>> result = await useCase(location, limit: 15);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected success result'),
      (list) {
        expect(list.length, 15);
        expect(list.first.id, 'v0');
        expect(list.last.id, 'v14');
      },
    );
    verify(() => mockVenueRepository.fetchNearbyVenues(location)).called(1);
  });

  test('returns all venues when repository returns 15 or fewer', () async {
    final venues = List<Venue>.generate(12, (index) => venueEntity('v$index'));
    when(() => mockVenueRepository.fetchNearbyVenues(any()))
        .thenAnswer((_) async => right(venues));

    final useCase = GetVenuesForLocation(mockVenueRepository);
    final Result<List<Venue>> result = await useCase(location, limit: 15);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected success result'),
      (list) {
        expect(list.length, 12);
      },
    );
    verify(() => mockVenueRepository.fetchNearbyVenues(location)).called(1);
  });

  test('returns venues from repository in order', () async {
    final venues = [venueEntity('a'), venueEntity('b'), venueEntity('c')];
    when(() => mockVenueRepository.fetchNearbyVenues(any()))
        .thenAnswer((_) async => right(venues));

    final useCase = GetVenuesForLocation(mockVenueRepository);
    final Result<List<Venue>> result = await useCase(location, limit: 15);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected success result'),
      (list) {
        expect(list.map((venue) => venue.id).toList(), ['a', 'b', 'c']);
      },
    );
    verify(() => mockVenueRepository.fetchNearbyVenues(location)).called(1);
  });
}
