import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/venue_remote_data_source.dart';
import '../../data/network/api_config.dart';
import '../../data/network/api_client.dart';
import '../../data/network/dio_api_client.dart';
import '../../data/providers/location_provider_impl.dart';
import '../../data/repositories/favourite_repository_impl.dart';
import '../../data/repositories/venue_repository_impl.dart';
import '../../domain/repositories/favourite_repository.dart';
import '../../domain/repositories/location_provider.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/usecases/get_venues_for_location.dart';
import '../../domain/usecases/toggle_favourite.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return const ApiConfig(
    baseUrl: 'https://restaurant-api.wolt.com/v1/pages/restaurants',
    timeout: Duration(seconds: 10),
  );
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.read(apiConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.timeout,
      receiveTimeout: config.timeout,
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.addAll([
    buildLoggingInterceptor(),
    ApiExceptionInterceptor(),
  ]);
  ref.onDispose(dio.close);
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return DioApiClient(dio: ref.read(dioProvider));
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final venueRemoteDataSourceProvider = Provider<VenueRemoteDataSource>((ref) {
  return VenueRemoteDataSourceImpl(
    client: ref.read(apiClientProvider),
  );
});

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
  (ref) => ToggleFavourite(ref.read(favouriteRepositoryProvider)),
);
