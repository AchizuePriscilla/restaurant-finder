import 'package:mocktail/mocktail.dart';

import 'package:restaurant_finder/data/datasources/venue_remote_data_source.dart';
import 'package:restaurant_finder/data/network/api_client.dart';
import 'package:restaurant_finder/domain/repositories/favourite_repository.dart';
import 'package:restaurant_finder/domain/providers/location_provider.dart';
import 'package:restaurant_finder/domain/repositories/venue_repository.dart';

class MockLocationProvider extends Mock implements LocationProvider {}

class MockVenueRepository extends Mock implements VenueRepository {}

class MockFavouriteRepository extends Mock implements FavouriteRepository {}

class MockApiClient extends Mock implements ApiClient {}

class MockVenueRemoteDataSource extends Mock implements VenueRemoteDataSource {}
