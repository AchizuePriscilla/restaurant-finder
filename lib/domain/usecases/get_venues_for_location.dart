import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/repositories/venue_repository.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

class GetVenuesForLocation {
  GetVenuesForLocation(this._venueRepository);

  final VenueRepository _venueRepository;

  Future<Result<List<Venue>>> call(
    LatLng location, {
    required int limit,
  }) async {
    final result = await _venueRepository.fetchNearbyVenues(location);
    return result.map(
      (venues) => venues.take(limit).toList(growable: false),
    );
  }
}
