import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/repositories/venue_repository.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

class GetVenuesForLocation {
  GetVenuesForLocation(this._venueRepository);

  final VenueRepository _venueRepository;

  Future<List<Venue>> call(LatLng location, {required int limit}) async {
    final venues = await _venueRepository.fetchNearbyVenues(location);
    return venues.take(limit).toList(growable: false);
  }
}
