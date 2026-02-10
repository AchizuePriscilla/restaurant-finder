import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_finder/data/datasources/venue_remote_data_source.dart';
import 'package:restaurant_finder/data/network/api_config.dart';
import 'package:restaurant_finder/data/network/dio_api_client.dart';
import 'package:restaurant_finder/data/providers/location_provider_impl.dart';
import 'package:restaurant_finder/data/repositories/favourite_repository_impl.dart';
import 'package:restaurant_finder/data/repositories/venue_repository_impl.dart';
import 'package:restaurant_finder/domain/repositories/favourite_repository.dart';
import 'package:restaurant_finder/domain/repositories/location_provider.dart';
import 'package:restaurant_finder/domain/repositories/venue_repository.dart';
import 'package:restaurant_finder/domain/usecases/apply_favourites_to_venues.dart';
import 'package:restaurant_finder/domain/usecases/get_venues_for_location.dart';
import 'package:restaurant_finder/domain/usecases/toggle_favourite.dart';

class AppDi {
  AppDi._({
    required Dio dio,
    required LocationProvider locationProvider,
    required GetVenuesForLocation getVenuesForLocation,
    required ApplyFavouritesToVenues applyFavouritesToVenues,
    required ToggleFavouriteUseCase toggleFavourite,
  })  : _dio = dio,
        _locationProvider = locationProvider,
        _getVenuesForLocation = getVenuesForLocation,
        _applyFavouritesToVenues = applyFavouritesToVenues,
        _toggleFavourite = toggleFavourite;

  static const ApiConfig defaultConfig = ApiConfig(
    baseUrl: 'https://restaurant-api.wolt.com/v1/pages/restaurants',
    timeout: Duration(seconds: 10),
  );

  final Dio _dio;
  final LocationProvider _locationProvider;
  final GetVenuesForLocation _getVenuesForLocation;
  final ApplyFavouritesToVenues _applyFavouritesToVenues;
  final ToggleFavouriteUseCase _toggleFavourite;

  LocationProvider get locationProvider => _locationProvider;
  GetVenuesForLocation get getVenuesForLocation => _getVenuesForLocation;
  ApplyFavouritesToVenues get applyFavouritesToVenues =>
      _applyFavouritesToVenues;
  ToggleFavouriteUseCase get toggleFavourite => _toggleFavourite;

  factory AppDi.create({
    required SharedPreferences sharedPreferences,
    ApiConfig apiConfig = defaultConfig,
    VenueRepository? venueRepository,
    FavouriteRepository? favouriteRepository,
    LocationProvider? locationProvider,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: apiConfig.baseUrl,
        connectTimeout: apiConfig.timeout,
        receiveTimeout: apiConfig.timeout,
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(
      buildLoggingInterceptor(),
    );

    final apiClient = DioApiClient(dio: dio);
    final remoteDataSource = VenueRemoteDataSourceImpl(client: apiClient);
    final resolvedFavouriteRepository =
        favouriteRepository ??
        FavouriteRepositoryImpl(sharedPreferences: sharedPreferences);
    final resolvedVenueRepository =
        venueRepository ??
        VenueRepositoryImpl(remoteDataSource: remoteDataSource);
    final resolvedLocationProvider = locationProvider ?? LocationProviderImpl();

    final getVenuesForLocation = GetVenuesForLocation(resolvedVenueRepository);
    final applyFavouritesToVenues = ApplyFavouritesToVenues(
      resolvedFavouriteRepository,
    );
    final toggleFavourite = ToggleFavouriteUseCase(resolvedFavouriteRepository);

    return AppDi._(
      dio: dio,
      locationProvider: resolvedLocationProvider,
      getVenuesForLocation: getVenuesForLocation,
      applyFavouritesToVenues: applyFavouritesToVenues,
      toggleFavourite: toggleFavourite,
    );
  }

  void dispose() {
    _dio.close(force: true);
  }
}
