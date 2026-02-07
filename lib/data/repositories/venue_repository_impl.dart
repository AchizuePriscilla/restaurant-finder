import '../../domain/entities/venue.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/value_objects/lat_lng.dart';
import '../datasources/venue_remote_data_source.dart';

class VenueRepositoryImpl implements VenueRepository {
  VenueRepositoryImpl({
    required VenueRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final VenueRemoteDataSource _remoteDataSource;

  @override
  Future<List<Venue>> fetchNearbyVenues(LatLng location) async {
    final dtos = await _remoteDataSource.fetchNearbyVenues(location);
    return dtos
        .map((dto) => dto.toDomain(isFavourite: false))
        .toList(growable: false);
  }
}
