import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/venue_remote_data_source.dart';
import '../../data/providers/location_provider_impl.dart';
import '../../data/repositories/favourite_repository_impl.dart';
import '../../data/repositories/venue_repository_impl.dart';
import '../../domain/repositories/favourite_repository.dart';
import '../../domain/repositories/location_provider.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/usecases/get_venues_for_location.dart';
import '../../domain/usecases/toggle_favourite.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden',
  );
});

final venueRemoteDataSourceProvider = Provider<VenueRemoteDataSource>(
  (ref) => VenueRemoteDataSourceImpl(
    client: ref.read(httpClientProvider),
  ),
);

final venueRepositoryProvider = Provider<VenueRepository>(
  (ref) => VenueRepositoryImpl(
    remoteDataSource: ref.read(venueRemoteDataSourceProvider),
  ),
);

final favouriteRepositoryProvider = Provider<FavouriteRepository>(
  (ref) => FavouriteRepositoryImpl(
    sharedPreferences: ref.read(sharedPreferencesProvider),
  ),
);

final locationProviderProvider = Provider<LocationProvider>(
  (ref) => LocationProviderImpl(),
);

final getVenuesForLocationProvider = Provider<GetVenuesForLocation>(
  (ref) => GetVenuesForLocation(
    ref.read(venueRepositoryProvider),
    ref.read(favouriteRepositoryProvider),
  ),
);

final toggleFavouriteProvider = Provider<ToggleFavourite>(
  (ref) => ToggleFavourite(
    ref.read(favouriteRepositoryProvider),
  ),
);
