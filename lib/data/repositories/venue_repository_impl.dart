import 'dart:async';

import '../../domain/entities/venue.dart';
import '../../domain/errors/failure.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/value_objects/lat_lng.dart';
import '../datasources/venue_remote_data_source.dart';
import '../errors/api_exception.dart';
import '../errors/api_exception_extensions.dart';
import '../mapper/restaurant_item_mapper.dart';

class VenueRepositoryImpl implements VenueRepository {
  VenueRepositoryImpl({required VenueRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final VenueRemoteDataSource _remoteDataSource;

  @override
  Future<List<Venue>> fetchNearbyVenues(LatLng location) async {
    try {
      final items = await _remoteDataSource.fetchNearbyVenues(location);
      return items
          .map((item) => item.toDomain(isFavourite: false))
          .toList(growable: false);
    } on ApiException catch (error, stackTrace) {
      throw Failure(
        type: error.type.toFailureType(),
        message: error.message,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      throw Failure.unknown(
        message: 'Failed to fetch venues.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
