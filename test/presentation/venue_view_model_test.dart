import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dartz/dartz.dart';
import 'package:restaurant_finder/domain/errors/failure.dart';
import 'package:restaurant_finder/domain/usecases/apply_favourites_to_venues.dart';
import 'package:restaurant_finder/domain/usecases/get_venues_for_location.dart';
import 'package:restaurant_finder/domain/usecases/toggle_favourite.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';
import 'package:restaurant_finder/presentation/bloc/venue_bloc.dart';
import 'package:restaurant_finder/presentation/bloc/venue_event.dart';
import 'package:restaurant_finder/presentation/state/venue_state.dart';
import '../helpers/mocks.dart';
import '../helpers/test_data.dart';

void main() {
  late MockLocationProvider mockLocationProvider;
  late MockVenueRepository mockVenueRepository;
  late MockFavouriteRepository mockFavouriteRepository;

  setUpAll(() {
    registerFallbackValue(const LatLng(latitude: 0, longitude: 0));
  });

  setUp(() {
    mockLocationProvider = MockLocationProvider();
    mockVenueRepository = MockVenueRepository();
    mockFavouriteRepository = MockFavouriteRepository();
  });

  blocTest<VenueBloc, VenueState>(
    'fetch venues failure sets error message and loading false',
    build: () {
      const location = LatLng(latitude: 1, longitude: 1);
      when(() => mockLocationProvider.locationStream())
          .thenAnswer((_) => Stream.value(location));
      when(() => mockVenueRepository.fetchNearbyVenues(any()))
          .thenAnswer(
            (_) async => Left(
              Failure.unknown(message: 'Network error.'),
            ),
          );
      when(() => mockFavouriteRepository.getFavourites())
          .thenAnswer((_) async => const Right(<String>{}));

      return VenueBloc(
        locationProvider: mockLocationProvider,
        getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
        applyFavouritesToVenues:
            ApplyFavouritesToVenues(mockFavouriteRepository),
        toggleFavouriteUseCase:
            ToggleFavouriteUseCase(mockFavouriteRepository),
      );
    },
    act: (bloc) => bloc.add(const LocationObservingStarted()),
    wait: Duration.zero,
    expect: () => [
      isA<VenueState>().having(
        (state) => state.isLoading,
        'isLoading',
        true,
      ),
      isA<VenueState>()
          .having(
            (state) => state.isLoading,
            'isLoading',
            false,
          )
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            'Network error.',
          )
          .having(
            (state) => state.venues.length,
            'venues length',
            0,
          ),
    ],
  );

  blocTest<VenueBloc, VenueState>(
    'timeout failure results in timeout error message from bloc',
    build: () {
      const location = LatLng(latitude: 1, longitude: 1);
      when(() => mockLocationProvider.locationStream())
          .thenAnswer((_) => Stream.value(location));
      when(() => mockVenueRepository.fetchNearbyVenues(any()))
          .thenAnswer(
            (_) async => Left(
              Failure.timeout(message: 'Request timed out.'),
            ),
          );
      when(() => mockFavouriteRepository.getFavourites())
          .thenAnswer((_) async => const Right(<String>{}));

      return VenueBloc(
        locationProvider: mockLocationProvider,
        getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
        applyFavouritesToVenues:
            ApplyFavouritesToVenues(mockFavouriteRepository),
        toggleFavouriteUseCase:
            ToggleFavouriteUseCase(mockFavouriteRepository),
      );
    },
    act: (bloc) => bloc.add(const LocationObservingStarted()),
    wait: Duration.zero,
    expect: () => [
      isA<VenueState>().having(
        (state) => state.isLoading,
        'isLoading',
        true,
      ),
      isA<VenueState>()
          .having(
            (state) => state.isLoading,
            'isLoading',
            false,
          )
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            'Request timed out.',
          )
          .having(
            (state) => state.venues.length,
            'venues length',
            0,
          ),
    ],
  );

  blocTest<VenueBloc, VenueState>(
    'toggle favourite failure sets error message',
    build: () {
      const location = LatLng(latitude: 1, longitude: 1);
      when(() => mockLocationProvider.locationStream())
          .thenAnswer((_) => Stream.value(location));
      when(() => mockVenueRepository.fetchNearbyVenues(any()))
          .thenAnswer((_) async => right([venueEntity('a')]));
      when(() => mockFavouriteRepository.getFavourites())
          .thenAnswer((_) async => const Right(<String>{}));
      when(() => mockFavouriteRepository.toggleFavourite(any()))
          .thenAnswer(
            (_) async => Left(
              Failure.unknown(message: 'Storage error.'),
            ),
          );

      return VenueBloc(
        locationProvider: mockLocationProvider,
        getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
        applyFavouritesToVenues:
            ApplyFavouritesToVenues(mockFavouriteRepository),
        toggleFavouriteUseCase:
            ToggleFavouriteUseCase(mockFavouriteRepository),
      );
    },
    act: (bloc) async {
      bloc.add(const LocationObservingStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ToggleFavouriteVenue('a'));
    },
    wait: Duration.zero,
    verify: (bloc) {
      expect(bloc.state.errorMessage, 'Storage error.');
      expect(bloc.state.venues.first.isFavourite, isFalse);
    },
  );

  group('location stream handling', () {
    const location = LatLng(latitude: 1, longitude: 1);
    late StreamController<LatLng> controller;
    var callCount = 0;

    blocTest<VenueBloc, VenueState>(
      'error message is cleared after successful fetch',
      setUp: () {
        controller = StreamController<LatLng>();
        callCount = 0;
      },
      build: () {
        when(() => mockLocationProvider.locationStream())
            .thenAnswer((_) => controller.stream);

        when(() => mockVenueRepository.fetchNearbyVenues(any()))
            .thenAnswer((_) async {
          if (callCount == 0) {
            callCount++;
            return Left(
              Failure.unknown(message: 'Network error.'),
            );
          }
          return right([venueEntity('a')]);
        });

        when(() => mockFavouriteRepository.getFavourites())
            .thenAnswer((_) async => const Right(<String>{}));

        return VenueBloc(
          locationProvider: mockLocationProvider,
          getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
          applyFavouritesToVenues:
              ApplyFavouritesToVenues(mockFavouriteRepository),
          toggleFavouriteUseCase:
              ToggleFavouriteUseCase(mockFavouriteRepository),
        );
      },
      act: (bloc) async {
        bloc.add(const LocationObservingStarted());

        // First emission -> failure
        controller.add(location);
        await Future<void>.delayed(Duration.zero);

        // Second emission -> success
        controller.add(location);
      },
      wait: Duration.zero,
      tearDown: () => controller.close(),
      verify: (bloc) {
        expect(bloc.state.errorMessage, isNull);
        expect(bloc.state.venues, isNotEmpty);
      },
    );
  });

  blocTest<VenueBloc, VenueState>(
    'duplicate LocationObservingStarted does not resubscribe location stream',
    build: () {
      const location = LatLng(latitude: 60.17, longitude: 24.94);
      final venues = [venueEntity('a')];
      when(() => mockLocationProvider.locationStream())
          .thenAnswer((_) => Stream.value(location));
      when(() => mockVenueRepository.fetchNearbyVenues(any()))
          .thenAnswer((_) async => right(venues));
      when(() => mockFavouriteRepository.getFavourites())
          .thenAnswer((_) async => const Right(<String>{}));

      return VenueBloc(
        locationProvider: mockLocationProvider,
        getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
        applyFavouritesToVenues:
            ApplyFavouritesToVenues(mockFavouriteRepository),
        toggleFavouriteUseCase:
            ToggleFavouriteUseCase(mockFavouriteRepository),
      );
    },
    act: (bloc) async {
      bloc.add(const LocationObservingStarted());
      bloc.add(const LocationObservingStarted());
    },
    wait: Duration.zero,
    verify: (_) {
      verify(() => mockLocationProvider.locationStream()).called(1);
    },
  );

  blocTest<VenueBloc, VenueState>(
    'first location emission loads then sets venues',
    build: () {
      const location = LatLng(latitude: 60.17, longitude: 24.94);
      final venues = [venueEntity('a'), venueEntity('b')];
      when(() => mockLocationProvider.locationStream())
          .thenAnswer((_) => Stream.value(location));
      when(() => mockVenueRepository.fetchNearbyVenues(any()))
          .thenAnswer((_) async => right(venues));
      when(() => mockFavouriteRepository.getFavourites())
          .thenAnswer((_) async => const Right(<String>{}));

      return VenueBloc(
        locationProvider: mockLocationProvider,
        getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
        applyFavouritesToVenues:
            ApplyFavouritesToVenues(mockFavouriteRepository),
        toggleFavouriteUseCase:
            ToggleFavouriteUseCase(mockFavouriteRepository),
      );
    },
    act: (bloc) => bloc.add(const LocationObservingStarted()),
    wait: Duration.zero,
    expect: () => [
      isA<VenueState>().having(
        (state) => state.isLoading,
        'isLoading',
        true,
      ),
      isA<VenueState>()
          .having(
            (state) => state.isLoading,
            'isLoading',
            false,
          )
          .having(
            (state) => state.venues.length,
            'venues length',
            2,
          )
          .having(
            (state) => state.currentLocation,
            'currentLocation',
            const LatLng(latitude: 60.17, longitude: 24.94),
          ),
    ],
    verify: (_) {
      verify(
        () => mockVenueRepository
            .fetchNearbyVenues(const LatLng(latitude: 60.17, longitude: 24.94)),
      ).called(1);
      verify(() => mockFavouriteRepository.getFavourites()).called(1);
    },
  );

  blocTest<VenueBloc, VenueState>(
    'toggleFavourite calls use case and updates state',
    build: () {
      const location = LatLng(latitude: 3, longitude: 3);
      when(() => mockLocationProvider.locationStream())
          .thenAnswer((_) => Stream.value(location));
      when(() => mockVenueRepository.fetchNearbyVenues(any()))
          .thenAnswer(
            (_) async => right(
              [venueEntity('a'), venueEntity('b')],
            ),
          );
      when(() => mockFavouriteRepository.getFavourites())
          .thenAnswer((_) async => const Right(<String>{}));
      when(() => mockFavouriteRepository.toggleFavourite(any()))
          .thenAnswer((_) async => const Right(null));

      return VenueBloc(
        locationProvider: mockLocationProvider,
        getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
        applyFavouritesToVenues:
            ApplyFavouritesToVenues(mockFavouriteRepository),
        toggleFavouriteUseCase:
            ToggleFavouriteUseCase(mockFavouriteRepository),
      );
    },
    act: (bloc) async {
      bloc.add(const LocationObservingStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ToggleFavouriteVenue('a'));
      await Future<void>.delayed(Duration.zero);
    },
    wait: Duration.zero,
    verify: (bloc) {
      final updated = bloc.state.venues;
      expect(
        updated.firstWhere((venue) => venue.id == 'a').isFavourite,
        isTrue,
      );
      expect(
        updated.firstWhere((venue) => venue.id == 'b').isFavourite,
        isFalse,
      );
      verify(() => mockFavouriteRepository.toggleFavourite('a')).called(1);
    },
  );

  blocTest<VenueBloc, VenueState>(
    'location stream error sets error message',
    build: () {
      when(() => mockLocationProvider.locationStream()).thenAnswer(
        (_) => Stream.error(Exception('location error')),
      );

      return VenueBloc(
        locationProvider: mockLocationProvider,
        getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
        applyFavouritesToVenues:
            ApplyFavouritesToVenues(mockFavouriteRepository),
        toggleFavouriteUseCase:
            ToggleFavouriteUseCase(mockFavouriteRepository),
      );
    },
    act: (bloc) => bloc.add(const LocationObservingStarted()),
    wait: Duration.zero,
    verify: (bloc) {
      expect(bloc.state.errorMessage, 'Location stream error.');
      expect(bloc.state.isLoading, isFalse);
    },
  );

  blocTest<VenueBloc, VenueState>(
    'stale fetch protection keeps latest location result',
    build: () {
      const locationA = LatLng(latitude: 1, longitude: 1);
      const locationB = LatLng(latitude: 2, longitude: 2);

      when(() => mockLocationProvider.locationStream())
          .thenAnswer((_) => Stream.fromIterable([locationA, locationB]));
      when(() => mockVenueRepository.fetchNearbyVenues(locationA))
          .thenAnswer((_) async => right([venueEntity('a1')]));
      when(() => mockVenueRepository.fetchNearbyVenues(locationB))
          .thenAnswer((_) async => right([venueEntity('b1')]));
      when(() => mockFavouriteRepository.getFavourites())
          .thenAnswer((_) async => const Right(<String>{}));

      return VenueBloc(
        locationProvider: mockLocationProvider,
        getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
        applyFavouritesToVenues:
            ApplyFavouritesToVenues(mockFavouriteRepository),
        toggleFavouriteUseCase:
            ToggleFavouriteUseCase(mockFavouriteRepository),
      );
    },
    act: (bloc) => bloc.add(const LocationObservingStarted()),
    wait: Duration.zero,
    verify: (bloc) {
      final state = bloc.state;
      expect(
        state.currentLocation,
        const LatLng(latitude: 2, longitude: 2),
      );
      expect(state.venues.first.id, 'b1');
    },
  );
}
