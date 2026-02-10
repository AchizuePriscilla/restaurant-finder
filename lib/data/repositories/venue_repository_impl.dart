import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:restaurant_finder/data/datasources/venue_remote_data_source.dart';
import 'package:restaurant_finder/data/errors/api_exception.dart';
import 'package:restaurant_finder/data/errors/api_exception_extensions.dart';
import 'package:restaurant_finder/data/mapper/restaurant_item_mapper.dart';
import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/errors/failure.dart';
import 'package:restaurant_finder/domain/repositories/venue_repository.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

class VenueRepositoryImpl implements VenueRepository {
  VenueRepositoryImpl({required VenueRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final VenueRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Venue>>> fetchNearbyVenues(LatLng location) async {
    try {
      final items = await _remoteDataSource.fetchNearbyVenues(location);
      final venues = items
          .map((item) => item.toDomain(isFavourite: false))
          .toList(growable: false);
      return right(venues);
    } on ApiException catch (error, stackTrace) {
      return left(
        Failure(
          type: error.type.toFailureType(),
          message: error.message,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } catch (error, stackTrace) {
      return left(
        Failure.unknown(
          message: 'Failed to fetch venues.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
