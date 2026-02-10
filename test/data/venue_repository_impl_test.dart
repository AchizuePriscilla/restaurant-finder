import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:restaurant_finder/data/errors/api_exception.dart';
import 'package:restaurant_finder/data/repositories/venue_repository_impl.dart';
import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/errors/failure.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';
import '../helpers/mocks.dart';
import '../helpers/test_data.dart';

void main() {
  late MockVenueRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(const LatLng(latitude: 0, longitude: 0));
  });

  setUp(() {
    mockRemoteDataSource = MockVenueRemoteDataSource();
  });

  const location = LatLng(latitude: 60.17, longitude: 24.94);

  test('maps ApiException.parsing to Failure.parsing', () async {
    when(() => mockRemoteDataSource.fetchNearbyVenues(any())).thenThrow(
      ApiException(
        message: 'Invalid JSON',
        type: ApiExceptionType.parsing,
      ),
    );

    final repository = VenueRepositoryImpl(remoteDataSource: mockRemoteDataSource);

    final Result<List<Venue>> result =
        await repository.fetchNearbyVenues(location);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) {
        expect(failure.type, FailureType.parsing);
        expect(failure.message, 'Invalid JSON');
      },
      (_) => fail('Expected failure result'),
    );
  });

  test('maps timeout ApiException to Failure.timeout', () async {
    when(() => mockRemoteDataSource.fetchNearbyVenues(any())).thenThrow(
      ApiException(
        message: 'Request timed out',
        type: ApiExceptionType.timeout,
      ),
    );

    final repository = VenueRepositoryImpl(remoteDataSource: mockRemoteDataSource);

    final Result<List<Venue>> result =
        await repository.fetchNearbyVenues(location);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) {
        expect(failure.type, FailureType.timeout);
        expect(failure.message, 'Request timed out');
      },
      (_) => fail('Expected failure result'),
    );
  });

  test('maps generic exception to Failure.unknown', () async {
    when(() => mockRemoteDataSource.fetchNearbyVenues(any()))
        .thenThrow(Exception('network error'));

    final repository = VenueRepositoryImpl(remoteDataSource: mockRemoteDataSource);

    final Result<List<Venue>> result =
        await repository.fetchNearbyVenues(location);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) {
        expect(failure.type, FailureType.unknown);
        expect(failure.message, 'Failed to fetch venues.');
      },
      (_) => fail('Expected failure result'),
    );
  });

  test('returns domain venues mapped from data source items', () async {
    final items = [
      restaurantItemDto('v1', 'Sushi Place', 'Fresh fish', 'https://img.example.com/1.jpg'),
    ];
    when(() => mockRemoteDataSource.fetchNearbyVenues(any()))
        .thenAnswer((_) async => items);

    final repository = VenueRepositoryImpl(remoteDataSource: mockRemoteDataSource);
    final Result<List<Venue>> result = await repository.fetchNearbyVenues(location);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected success result'),
      (venues) {
        expect(venues.length, 1);
        final venue = venues.first;
        expect(venue.id, 'v1');
        expect(venue.name, 'Sushi Place');
        expect(venue.description, 'Fresh fish');
        expect(venue.imageUrl, 'https://img.example.com/1.jpg');
        expect(venue.isFavourite, isFalse);
      },
    );
    verify(() => mockRemoteDataSource.fetchNearbyVenues(location)).called(1);
  });
}
