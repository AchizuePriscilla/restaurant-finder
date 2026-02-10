import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dartz/dartz.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/errors/failure.dart';
import 'package:restaurant_finder/domain/usecases/apply_favourites_to_venues.dart';
import 'package:restaurant_finder/domain/usecases/get_venues_for_location.dart';
import 'package:restaurant_finder/domain/usecases/toggle_favourite.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';
import 'package:restaurant_finder/presentation/bloc/venue_bloc.dart';
import 'package:restaurant_finder/presentation/bloc/venue_event.dart';
import 'package:restaurant_finder/presentation/pages/venue_page.dart';
import '../helpers/mocks.dart';

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

  testWidgets('shows error message when fetch venues fails', (tester) async {
    const location = LatLng(latitude: 60.17, longitude: 24.94);

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

    final bloc = VenueBloc(
      locationProvider: mockLocationProvider,
      getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
      applyFavouritesToVenues: ApplyFavouritesToVenues(mockFavouriteRepository),
      toggleFavouriteUseCase: ToggleFavouriteUseCase(mockFavouriteRepository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider<VenueBloc>.value(
        value: bloc,
        child: const MaterialApp(home: VenuePage()),
      ),
    );

    bloc.add(const LocationObservingStarted());
    await tester.pumpAndSettle();

    expect(find.text('Network error.'), findsOneWidget);
    expect(find.text('No venues nearby'), findsNothing);
  });

  testWidgets('renders venue list when venues exist', (tester) async {
    const location = LatLng(latitude: 60.17, longitude: 24.94);
    final venues = [
      const Venue(
        id: 'venue_1',
        name: 'Sushi Place',
        description: 'Fresh nigiri and rolls',
        imageUrl: '',
        isFavourite: true,
      ),
    ];

    when(() => mockLocationProvider.locationStream())
        .thenAnswer((_) => Stream.value(location));
    when(() => mockVenueRepository.fetchNearbyVenues(any()))
        .thenAnswer((_) async => right(venues));
    when(() => mockFavouriteRepository.getFavourites())
        .thenAnswer((_) async => const Right(<String>{'venue_1'}));

    final bloc = VenueBloc(
      locationProvider: mockLocationProvider,
      getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
      applyFavouritesToVenues: ApplyFavouritesToVenues(mockFavouriteRepository),
      toggleFavouriteUseCase: ToggleFavouriteUseCase(mockFavouriteRepository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider<VenueBloc>.value(
        value: bloc,
        child: const MaterialApp(home: VenuePage()),
      ),
    );
    bloc.add(const LocationObservingStarted());
    await tester.pumpAndSettle();

    expect(find.text('Sushi Place'), findsOneWidget);
    expect(find.byTooltip('Remove favourite'), findsOneWidget);
  });

  testWidgets('shows empty state when no venues', (tester) async {
    when(() => mockLocationProvider.locationStream())
        .thenAnswer((_) => const Stream.empty());

    final bloc = VenueBloc(
      locationProvider: mockLocationProvider,
      getVenuesForLocation: GetVenuesForLocation(mockVenueRepository),
      applyFavouritesToVenues: ApplyFavouritesToVenues(mockFavouriteRepository),
      toggleFavouriteUseCase: ToggleFavouriteUseCase(mockFavouriteRepository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider<VenueBloc>.value(
        value: bloc,
        child: const MaterialApp(home: VenuePage()),
      ),
    );

    expect(find.text('No venues nearby'), findsOneWidget);
  });
}
