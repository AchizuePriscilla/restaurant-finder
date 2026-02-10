import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dartz/dartz.dart';
import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/providers/location_provider.dart';
import 'package:restaurant_finder/domain/repositories/venue_repository.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';
import 'package:restaurant_finder/main.dart';
import 'package:restaurant_finder/di/app_di.dart';

class FixedLocationProvider implements LocationProvider {
  FixedLocationProvider(this.location);

  final LatLng location;

  @override
  Stream<LatLng> locationStream() => Stream<LatLng>.value(location);
}

class FixedVenueRepository implements VenueRepository {
  FixedVenueRepository(this.venues);

  final List<Venue> venues;

  @override
  Future<Result<List<Venue>>> fetchNearbyVenues(LatLng location) async =>
      right(venues);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('favourites persist across restart', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final venue = Venue(
      id: 'venue_1',
      name: 'Sushi Place',
      description: 'Fresh nigiri and rolls',
      imageUrl: '',
      isFavourite: false,
    );
    final location = const LatLng(latitude: 60.17, longitude: 24.94);
    final di = AppDi.create(
      sharedPreferences: prefs,
      venueRepository: FixedVenueRepository([venue]),
      locationProvider: FixedLocationProvider(location),
    );
    addTearDown(di.dispose);

    await tester.pumpWidget(MainApp(di: di));
    await tester.pumpAndSettle();

    final addButton = find.byTooltip('Add favourite');
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove favourite'), findsOneWidget);

    final newPrefs = await SharedPreferences.getInstance();
    final nextDi = AppDi.create(
      sharedPreferences: newPrefs,
      venueRepository: FixedVenueRepository([venue]),
      locationProvider: FixedLocationProvider(location),
    );
    addTearDown(nextDi.dispose);
    await tester.pumpWidget(MainApp(di: nextDi));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Remove favourite'), findsOneWidget);
  });
}
